import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gms_flutter/BLoC/States.dart';
import 'package:gms_flutter/Models/AboutUsModel.dart';
import 'package:gms_flutter/Models/ArticlesModel.dart';
import 'package:gms_flutter/Models/DietPlanModel.dart';
import 'package:gms_flutter/Models/EventModel.dart';
import 'package:gms_flutter/Models/FAQModel.dart';
import 'package:gms_flutter/Models/SubscriptionsHistoryModel.dart';
import 'package:gms_flutter/Models/WorkoutModel.dart';
import 'package:gms_flutter/Models/HealthInfoModel.dart';
import 'package:gms_flutter/Models/LoginModel.dart';
import 'package:gms_flutter/Models/NotificationsModel.dart';
import 'package:gms_flutter/Models/PrivateCoachModel.dart';
import 'package:gms_flutter/Models/ProfileModel.dart';
import 'package:gms_flutter/Models/ClassesModel.dart';
import 'package:gms_flutter/Models/ProgramModel.dart';
import 'package:gms_flutter/Models/SessionsModel.dart';
import 'package:gms_flutter/Models/WorkoutProgressModel.dart';
import 'package:gms_flutter/Modules/ForgotPassword/ResetPassword.dart';
import 'package:gms_flutter/Modules/ForgotPassword/VerifyCode.dart';
import 'package:gms_flutter/Remote/Dio_Linker.dart';
import 'package:gms_flutter/Remote/End_Points.dart';
import 'package:gms_flutter/Remote/FCM.dart';
import 'package:gms_flutter/Shared/Components.dart';
import 'package:gms_flutter/Shared/SecureStorage.dart';
import 'package:gms_flutter/Shared/SharedPrefHelper.dart';
import 'package:gms_flutter/main.dart';

import '../Modules/Base.dart';
import '../Modules/Login.dart';

class Manager extends Cubit<BLoCStates> {
  Manager() : super(InitialState());

  static Manager get(BuildContext context) => BlocProvider.of(context);

  void updateState() {
    emit(UpdateNewState());
  }

  final int paginationSize = 5;

  late Login_Model loginModel;

  void login(Map<String, dynamic> data) {
    emit(LoadingState());
    Dio_Linker.postData(url: LOGIN, data: data)
        .then((value) async {
          loginModel = Login_Model.fromJson(value.data);
          FirebaseMessagingService.registerUserToken();
          SharedPrefHelper.saveUserData(
            UserModel.fromJson(value.data['message']),
          );
          await TokenStorage.writeAccessToken(loginModel.accessToken);
          await TokenStorage.writeRefreshToken(loginModel.refreshToken);
          await TokenStorage.writeRoles(loginModel.accessToken);
          MyApp.navigatorKey.currentState?.pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => Base()),
            (route) => false,
          );
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  void logout() async {
    emit(LoadingState());
    await Dio_Linker.postData(url: LOGOUT)
        .then((value) async {
          emit(SuccessState());
          performLogout();
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  void performLogout() async {
    await SharedPrefHelper.clear();
    await TokenStorage.deleteAccessToken();
    await TokenStorage.deleteRefreshToken();
    Future.delayed(Duration(milliseconds: 50), () {
      final navigator = MyApp.navigatorKey.currentState;
      if (navigator != null) {
        ReusableComponents.showToast(
          'login Required to continue',
          background: Colors.red,
        );
        navigator.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => Login()),
          (route) => false,
        );
      }
    });
  }

  String? message;

  void forgotPassword(Map<String, dynamic> data) {
    emit(LoadingState());
    Dio_Linker.postData(url: FORGOTPASSWORD, data: data)
        .then((value) {
          emit(SuccessState());
          final navigator = MyApp.navigatorKey.currentState;
          if (navigator != null) {
            ReusableComponents.showToast(
              'verification code was sent to: ${data['email']}',
              background: Colors.green,
            );
            navigator.pushReplacement(
              MaterialPageRoute(builder: (_) => VerifyCode(data['email'])),
            );
          }
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  void verifyCode(Map<String, dynamic> data) {
    emit(LoadingState());
    Dio_Linker.postData(url: VERIFYCODE, data: data)
        .then((value) {
          emit(SuccessState());
          final navigator = MyApp.navigatorKey.currentState;
          if (navigator != null) {
            ReusableComponents.showToast(
              'code verified',
              background: Colors.green,
            );
            navigator.pushReplacement(
              MaterialPageRoute(
                builder: (_) => ResetPassword(data['email'], data['code']),
              ),
            );
          }
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  void resetForgotPassword(Map<String, dynamic> data) {
    emit(LoadingState());
    Dio_Linker.putData(url: RESETFORGOTPASSWORD, data: data)
        .then((value) {
          emit(SuccessState());
          final navigator = MyApp.navigatorKey.currentState;
          if (navigator != null) {
            ReusableComponents.showToast(
              'password updated',
              background: Colors.green,
            );
            navigator.pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => Login()),
              (route) => false,
            );
          }
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  String handleDioError(dynamic error) {
    if (error is DioException) {
      // Timeouts
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout) {
        return 'Request timeout, try again';
      }
      final response = error.response;
      if (response != null) {
        final data = response.data;
        // message: String
        if (data is Map && data['message'] != null) {
          return data['message'].toString();
        }
        if (data is Map) {
          return data.values.join('\n');
        }
        return 'Error code (${response.statusCode})';
      }
      // Network issue
      if (error.type == DioExceptionType.connectionError) {
        return 'No internet connection or server unreachable';
      }
    }
    return 'Unexpected error, try again later';
  }

  List<ClassesModel> userClasses = [];

  void getUserClasses() {
    emit(LoadingState());
    Dio_Linker.getData(url: USERCLASSES)
        .then((value) {
          userClasses = ClassesModel.parseClassesList(value.data);
          emit(SuccessState());
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  List<SessionsModel> userSessionsModel = [];

  void userSessions() {
    emit(LoadingState());
    Dio_Linker.getData(url: USERSESSIONS)
        .then((value) {
          userSessionsModel = SessionsModel.parseSessionsList(value.data);
          emit(SuccessState());
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  List<DietPlanModel> userDiets = [];

  void userDietPlans() {
    emit(LoadingState());
    Dio_Linker.getData(url: USERDIETPLANS)
        .then((value) {
          userDiets = DietPlanModel.parseList(value.data);
          emit(SuccessState());
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  List<PrivateCoachModel> userPrivateCoaches = [];

  void userCoaches() {
    emit(LoadingState());
    Dio_Linker.getData(
          url: USERPRIVATECOACHES + SharedPrefHelper.getString('id').toString(),
        )
        .then((value) {
          userPrivateCoaches = PrivateCoachModel.parseList(
            value.data['message'],
          );
          emit(SuccessState());
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  List<HealthInfoModel> userHealthInfos = [];

  void userHealthInfo({startDate, endDate}) {
    emit(LoadingState());
    Dio_Linker.getData(
          url: USERHEALTHINFO,
          data: {
            'userId': SharedPrefHelper.getString('id'),
            'startDate': startDate,
            'endDate': endDate,
          },
        )
        .then((value) {
          userHealthInfos = HealthInfoModel.parseList(value.data);
          emit(SuccessState());
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  void logHealthInfo(Map<String, dynamic> data) {
    emit(LoadingState());
    Dio_Linker.postData(url: LOGHEALTHINFO, data: data)
        .then((value) {
          userHealthInfo();
          ReusableComponents.showToast(
            'Record added successfully',
            background: Colors.green,
          );
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  List<WorkoutModel> userFavorites = [];

  void getUserFavorites() {
    emit(LoadingState());
    Dio_Linker.getData(url: GETUSERFAVORITES)
        .then((value) {
          userFavorites = WorkoutModel.fromJsonList(value.data);
          emit(SuccessState());
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  void getUserProfile() {
    emit(LoadingState());
    Dio_Linker.getData(url: USERPROFILE)
        .then((value) {
          SharedPrefHelper.saveUserData(
            UserModel.fromJson(value.data['message']),
          );
          emit(SuccessState());
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  List<NotificationModel> userNotifications = [];

  void getNotifications() {
    emit(LoadingState());
    Dio_Linker.getData(url: USERNOTIFICATION)
        .then((value) {
          userNotifications = NotificationModel.fromJsonList(value.data);
          emit(SuccessState());
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  Future<void> changeAppTheme() async {
    final darkMode = !(SharedPrefHelper.getBool('appTheme') ?? true);
    await SharedPrefHelper.saveBool('appTheme', darkMode);
    emit(UpdateNewState());
  }

  void changeAppNotification() async {
    final appNotifications =
        !(SharedPrefHelper.getBool('appNotifications') ?? true);
    await SharedPrefHelper.saveBool('appNotifications', appNotifications);
    emit(UpdateNewState());
  }

  void changePassword(Map<String, dynamic> data) {
    emit(LoadingState());
    Dio_Linker.putData(url: CHANGEPASSWORD, data: data)
        .then((value) {
          emit(SuccessState());
          final navigator = MyApp.navigatorKey.currentState;
          if (navigator != null) {
            ReusableComponents.showToast(
              'password Updated',
              background: Colors.green,
            );
            navigator.pushReplacement(
              MaterialPageRoute(builder: (context) => Base()),
            );
          }
        })
        .catchError((error) {
          print(error);
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  ArticlesModel articles = ArticlesModel(
    count: 0,
    totalPages: 0,
    currentPage: 0,
    articles: [],
  );

  Future<void> getArticles(int page, String wikiType) async {
    if (page == 0) {
      emit(LoadingState());
    }
    return Dio_Linker.getData(
          url: GETARTICLES,
          params: {'page': page, 'size': paginationSize, 'wiki': wikiType},
        )
        .then((value) {
          final newData = ArticlesModel.fromJson(value.data['message']);
          if (page == 0) {
            articles = newData;
          } else {
            articles.articles.addAll(newData.articles);
          }
          emit(SuccessState());
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  void updateProfile(Map<String, dynamic> data) {
    emit(LoadingState());
    Dio_Linker.putData(
          url: UPDATEPROFILE + SharedPrefHelper.getString('id').toString(),
          data: data,
        )
        .then((value) {
          getUserProfile();
          emit(SuccessState());
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  Future<void> updateProfileImage(FormData data) async {
    emit(LoadingState());
    Dio_Linker.putData(url: UPLOADPROFILEIMAGE, data: data)
        .then((value) {
          getUserProfile();
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  void addClassFeedback(Map<String, dynamic> data) {
    emit(LoadingState());
    Dio_Linker.postData(url: ADDCLASSFEEDBACK, data: data)
        .then((value) {
          getUserClasses();
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  void deleteClassFeedback(String classId) {
    emit(LoadingState());
    Dio_Linker.deleteData(
          url: DELETECLASSFEEDBACK,
          data: {
            'userId': SharedPrefHelper.getString('id'),
            'classId': classId,
          },
        )
        .then((value) {
          getUserClasses();
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  void addSessionFeedback(Map<String, dynamic> data) {
    emit(LoadingState());
    Dio_Linker.postData(url: ADDSESSIONFEEDBACK, data: data)
        .then((value) {
          userSessions();
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  void deleteSessionFeedback(String sessionId) {
    emit(LoadingState());
    Dio_Linker.deleteData(
          url: DELETESESSIONFEEDBACK,
          data: {
            'userId': SharedPrefHelper.getString('id'),
            'sessionId': sessionId,
          },
        )
        .then((value) {
          userSessions();
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  void updateSessionRate(Map<String, dynamic> data) {
    emit(LoadingState());
    Dio_Linker.postData(url: UPDATESESSIONRATE, data: data)
        .then((value) {
          userSessions();
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  void deleteDietFeedback(String dietId) {
    emit(LoadingState());
    Dio_Linker.deleteData(
          url: DELETEDIETFEEDBACK,
          data: {'userId': SharedPrefHelper.getString('id'), 'dietId': dietId},
        )
        .then((value) {
          userDietPlans();
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  void addDietFeedback(Map<String, dynamic> data) {
    emit(LoadingState());
    Dio_Linker.postData(url: ADDDIETFEEDBACK, data: data)
        .then((value) {
          userDietPlans();
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  void updateDietRate(Map<String, dynamic> data) {
    emit(LoadingState());
    Dio_Linker.postData(url: UPDATEDIETRATE, data: data)
        .then((value) {
          userDietPlans();
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  List<ProgramModel> classPrograms = [];

  void getClassPrograms(classId) {
    emit(LoadingState());
    Dio_Linker.getData(url: GETCLASSPROGRAMS + classId)
        .then((value) {
          classPrograms = ProgramModel.parseList(value.data['message']);
          emit(SuccessState());
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  void updatePrivateCoachRate(Map<String, dynamic> data) {
    emit(LoadingState());
    Dio_Linker.postData(url: UPDATECOACHRATE, data: data)
        .then((value) {
          userCoaches();
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  void deleteHealthRecord(recordId, {startDate, endDate}) {
    emit(LoadingState());
    Dio_Linker.deleteData(url: DELETEHEALTHRECORD + recordId)
        .then((value) {
          userHealthInfo(startDate: startDate, endDate: endDate);
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  void deleteFavoriteRecord(String workoutId) {
    emit(LoadingState());
    Dio_Linker.deleteData(url: DELETEFROMFAVORITE + workoutId)
        .then((value) {
          getUserFavorites();
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  void addToFavorite(String workoutId) {
    emit(LoadingState());
    Dio_Linker.postData(url: ADDTOFAVORITE + workoutId)
        .then((value) {
          getUserFavorites();
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  List<SubscriptionsHistoryModel> userSubscriptionsHistory = [];

  void getUserSubscriptionsHistory() {
    emit(LoadingState());
    Dio_Linker.getData(
          url:
              GETSUBSCRIPTIONSHISTORY +
              SharedPrefHelper.getString('id').toString(),
        )
        .then((value) {
          userSubscriptionsHistory = SubscriptionsHistoryModel.parseList(
            value.data['message'],
          );
          emit(SuccessState());
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  List<FAQModel> faqList = [];

  void getFAQs() {
    emit(LoadingState());
    Dio_Linker.getData(url: GETFAQS)
        .then((value) {
          faqList = FAQModel.parseList(value.data);
          emit(SuccessState());
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  AboutUsModel? aboutUsModel;

  void getAboutUs() {
    emit(LoadingState());
    Dio_Linker.getData(url: GETABOUTUS)
        .then((value) {
          aboutUsModel = AboutUsModel.fromJson(value.data['message']);
          emit(SuccessState());
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  void deleteNotification(String notificationId) {
    emit(LoadingState());
    Dio_Linker.deleteData(url: DELETENOTIFICATION + notificationId)
        .then((value) {
          getNotifications();
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  void logWorkoutProgress(Map<String, dynamic> data) {
    emit(LoadingState());
    Dio_Linker.postData(url: LOGWORKOUTPROGRESS, data: data)
        .then((value) {
          getWorkoutProgress(data['program_workout_id']);
          ReusableComponents.showToast(
            'Record added successfully',
            background: Colors.green,
          );
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  List<WorkoutProgressModel> workoutProgresses = [];

  void getWorkoutProgress(program_workout_id, {startDate, endDate}) {
    emit(LoadingState());
    Dio_Linker.getData(
          url: GETWORKOUTPROGRESS,
          data: {
            'userId': SharedPrefHelper.getString('id'),
            'program_workout_id': program_workout_id,
            'startDate': startDate,
            'endDate': endDate,
          },
        )
        .then((value) {
          workoutProgresses = WorkoutProgressModel.parseList(value.data);
          emit(SuccessState());
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  void deleteWorkoutProgress(
    String recordId,
    program_workout_id, {
    startDate,
    endDate,
  }) {
    emit(LoadingState());
    Dio_Linker.deleteData(url: DELETEWORKOUTPROGRESS + recordId)
        .then((value) {
          getWorkoutProgress(
            program_workout_id,
            startDate: startDate,
            endDate: endDate,
          );
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  GetClassesModel classes = GetClassesModel(
    count: 0,
    totalPages: 1,
    currentPage: 0,
    items: [],
  );

  Future<void> getClasses(int page) async {
    if (page == 0) {
      emit(LoadingState());
    }
    return Dio_Linker.getData(
          url: GETALLCLASSES,
          params: {'page': page, 'size': paginationSize},
        )
        .then((value) {
          final newData = GetClassesModel.fromJson(value.data['message']);
          if (page == 0) {
            classes = newData;
          } else {
            classes.items.addAll(newData.items);
          }

          emit(SuccessState());
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  GetSessionsModel sessions = GetSessionsModel(
    count: 0,
    totalPages: 1,
    currentPage: 0,
    items: [],
  );

  Future<void> getSessions(int page) async {
    emit(LoadingState());
    return Dio_Linker.getData(
          url: GETALLSESSIONS,
          params: {'page': page, 'size': paginationSize},
        )
        .then((value) {
          sessions = GetSessionsModel.fromJson(value.data['message']);
          emit(SuccessState());
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  GetEventsModel events = GetEventsModel(
    count: 0,
    totalPages: 1,
    currentPage: 0,
    items: [],
  );

  Future<void> getEvents(int page) async {
    emit(LoadingState());
    return Dio_Linker.getData(
          url: GETALLEVENTS,
          params: {'page': page, 'size': paginationSize},
        )
        .then((value) {
          events = GetEventsModel.fromJson(value.data['message']);
          emit(SuccessState());
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  List<EventModel> userEvents = [];

  Future<void> getUserEvents() async {
    emit(LoadingState());
    return Dio_Linker.getData(
          url: GETUSEREVENTS + SharedPrefHelper.getString('id').toString(),
        )
        .then((value) {
          userEvents = EventModel.parseList(value.data);
          emit(SuccessState());
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  Future<void> saveFCM(Map<String, dynamic> data) async {
    emit(LoadingState());
    return Dio_Linker.postData(url: SAVEFCM, data: data)
        .then((value) {
          emit(SuccessState());
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  Future<void> subscribeToEvent(int eventId) async {
    emit(LoadingState());
    return Dio_Linker.postData(url: SUBSCRIBETOEVENT + eventId.toString())
        .then((value) {
          getUserEvents();
          final navigator = MyApp.navigatorKey.currentState;
          if (navigator != null) {
            ReusableComponents.showToast(
              'subscribed Successfully',
              background: Colors.green,
            );
          }
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  Future<void> unSubscribeFromEvent(int eventId) async {
    emit(LoadingState());
    return Dio_Linker.deleteData(url: UNSUBSCRIBEFROMEVENT + eventId.toString())
        .then((value) {
          getUserEvents();
          final navigator = MyApp.navigatorKey.currentState;
          if (navigator != null) {
            ReusableComponents.showToast(
              'subscribe removed Successfully',
              background: Colors.green,
            );
          }
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  List<ProgramModel> userPrograms = [];

  Future<void> getUserPrograms() async {
    emit(LoadingState());
    return Dio_Linker.getData(url: GETUSERPROGRAMS)
        .then((value) {
          userPrograms = ProgramModel.parseList(value.data);
          emit(SuccessState());
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  void updateProgramRate(Map<String, dynamic> data) {
    emit(LoadingState());
    Dio_Linker.postData(url: UPDATEPROGRAMRATE, data: data)
        .then((value) {
          getUserPrograms();
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  void addProgramFeedback(Map<String, dynamic> data) {
    emit(LoadingState());
    Dio_Linker.postData(url: ADDPROGRAMFEEDBACK, data: data)
        .then((value) {
          getUserPrograms();
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  void deleteProgramFeedback(Map<String, dynamic> data) {
    emit(LoadingState());
    Dio_Linker.deleteData(url: DELETEPROGRAMFEEDBACK, data: data)
        .then((value) {
          getUserPrograms();
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  List<ClassesModel> coachClasses = [];

  Future<void> getCoachClasses() async {
    emit(LoadingState());
    return Dio_Linker.getData(
          url: GETCOACHCLASSES + SharedPrefHelper.getString('id').toString(),
        )
        .then((value) {
          coachClasses = ClassesModel.parseList(value.data['message']);
          emit(SuccessState());
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  List<SessionsModel> coachSessions = [];

  Future<void> getCoachSessions() async {
    emit(LoadingState());
    return Dio_Linker.getData(
          url: GETCOACHSESSIONS + SharedPrefHelper.getString('id').toString(),
        )
        .then((value) {
          coachSessions = SessionsModel.parseList(value.data['message']);
          emit(SuccessState());
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  List<DietPlanModel> coachDiets = [];

  Future<void> getCoachDiets() async {
    emit(LoadingState());
    return Dio_Linker.getData(
          url: GETCOACHDIETS + SharedPrefHelper.getString('id').toString(),
        )
        .then((value) {
          coachDiets = DietPlanModel.parseNestedList(value.data['message']);
          emit(SuccessState());
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }

  List<PrivateCoachModel> coachTrainees = [];

  Future<void> getCoachTrainees() async {
    emit(LoadingState());
    return Dio_Linker.getData(
          url: GETCOACHUSERS + SharedPrefHelper.getString('id').toString(),
        )
        .then((value) {
          coachTrainees = PrivateCoachModel.parseList(value.data['message']);
          emit(SuccessState());
        })
        .catchError((error) {
          String errorMessage = handleDioError(error);
          emit(ErrorState(errorMessage));
        });
  }
}

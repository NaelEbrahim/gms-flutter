import 'ProfileModel.dart';

class SessionsModel {
  final int? id;
  final String? title;
  final String? description;
  final int? classId;
  final UserModel coach;
  final double? rate;
  final List<SessionScheduleModel> days;
  final String? createdAt;
  final String? startTime;
  final String? endTime;
  final int? maxNumber;
  final int? subscribersCount;
  final List<dynamic>? feedbacks;
  final String? myFeedback;
  final String? joinedAt;
  final String? className;
  final String? classImage;

  SessionsModel({
    this.id,
    this.title,
    this.description,
    this.classId,
    required this.coach,
    this.rate,
    required this.days,
    this.createdAt,
    this.startTime,
    this.endTime,
    this.maxNumber,
    this.subscribersCount,
    this.feedbacks,
    this.myFeedback,
    this.joinedAt,
    this.className,
    this.classImage,
  });

  static List<SessionsModel> parseSessionsList(List<dynamic> jsonList) {
    return jsonList.map((e) => SessionsModel.fromJson(e)).toList();
  }

  factory SessionsModel.fromJson(Map<String, dynamic> json) {
    return SessionsModel(
      id: json['id'] as int?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      classId: json['classId'] as int?,
      coach: UserModel.fromJson(json['coach']),
      rate: (json['rate'] as num?)?.toDouble(),
      days: (json['schedules'] as List)
          .map((e) => SessionScheduleModel.fromJson(e))
          .toList(),
      createdAt: json['createdAt'] as String?,
      startTime: json['startTime'] as String?,
      endTime: json['endTime'] as String?,
      maxNumber: json['maxNumber'] as int?,
      subscribersCount: json['subscribersCount'] as int?,
      myFeedback: json['myFeedBack'] as String?,
      joinedAt: json['joinedAt'] as String?,
      className: json['className'] as String?,
      classImage: json['classImage'] as String?,
    );
  }

  static List<SessionsModel> parseList(List<dynamic> jsonList) {
    return jsonList.map((e) => SessionsModel.fromNestedJson(e)).toList();
  }

  factory SessionsModel.fromNestedJson(Map<String, dynamic> json) {
    return SessionsModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      classId: json['classId'],
      coach: UserModel.fromJson(json['coach']),
      rate: (json['rate'] as num).toDouble(),
      days: (json['schedules'] as List)
          .map((e) => SessionScheduleModel.fromJson(e))
          .toList(),
      createdAt: json['createdAt'] as String?,
      maxNumber: json['maxNumber'],
      subscribersCount: json['subscribersCount'],
      className: json['className'],
      classImage: json['classImage'],
    );
  }

}

class SessionScheduleModel {
  final String day;
  final String startTime;
  final String endTime;

  SessionScheduleModel({
    required this.day,
    required this.startTime,
    required this.endTime,
  });

  factory SessionScheduleModel.fromJson(Map<String, dynamic> json) {
    return SessionScheduleModel(
      day: json['day'],
      startTime: json['startTime'],
      endTime: json['endTime'],
    );
  }
}

class GetSessionsModel {
  final int count;
  final int totalPages;
  final int currentPage;
  final List<SessionsModel> items;

  GetSessionsModel({
    required this.count,
    required this.totalPages,
    required this.currentPage,
    required this.items,
  });

  factory GetSessionsModel.fromJson(Map<String, dynamic> json) {
    return GetSessionsModel(
      count: json['count'],
      totalPages: json['totalPages'],
      currentPage: json['currentPage'],
      items: SessionsModel.parseList(json['sessions']),
    );
  }
}

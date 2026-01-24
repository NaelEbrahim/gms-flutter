import 'ProfileModel.dart';

class SessionsModel {
  final int? id;
  final String? title;
  final String? description;
  final int? classId;
  final ProfileDataModel coach;
  final double? rate;
  final List<String>? days;
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
    this.days,
    this.createdAt,
    this.startTime,
    this.endTime,
    this.maxNumber,
    this.subscribersCount,
    this.feedbacks,
    this.myFeedback,
    this.joinedAt,
    this.className,
    this.classImage
  });

  static List<SessionsModel> parseSessionsList(jsonList) {
    List<SessionsModel> userSessions = [];
    if (jsonList != null && (jsonList as List).isNotEmpty) {
      for (var element in jsonList) {
        userSessions.add(SessionsModel.fromJson(element));
      }
      return userSessions;
    }
    return [];
  }

  factory SessionsModel.fromJson(Map<String, dynamic> json) {
    return SessionsModel(
      id: json['id'] as int?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      classId: json['classId'] as int?,
      coach: ProfileDataModel.fromJson(json['coach']),
      rate: (json['rate'] as num?)?.toDouble(),
      days: (json['days'] as List?)?.map((e) => e as String).toList(),
      createdAt: json['createdAt'] as String?,
      startTime: json['startTime'] as String?,
      endTime: json['endTime'] as String?,
      maxNumber: json['maxNumber'] as int?,
      subscribersCount: json['subscribersCount'] as int?,
      feedbacks: json['feedbacks'] as List<dynamic>?,
      myFeedback: json['myFeedBack'] as String?,
      joinedAt: json['joinedAt'] as String?,
      className: json['className'] as String?,
      classImage: json['classImage'] as String?
    );
  }
}

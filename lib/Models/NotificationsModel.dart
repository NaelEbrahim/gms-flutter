import 'package:gms_flutter/Shared/Components.dart';

class NotificationModel {
  final int id;
  final String title;
  final String content;
  final String sendAt;

  NotificationModel({
    required this.id,
    required this.title,
    required this.content,
    required this.sendAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      sendAt: ReusableComponents.formatDateTime(json['sendAt'])
    );
  }
  static List<NotificationModel> fromJsonList(List<dynamic> list) {
    return list.map((e) => NotificationModel.fromJson(e)).toList();
  }
}

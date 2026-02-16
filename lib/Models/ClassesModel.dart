import 'dart:core';

import 'package:gms_flutter/Models/ProfileModel.dart';

class ClassesModel {
  final ProfileDataModel coach;
  final int? id;
  final String? name;
  final String? description;
  final String? imagePath;
  final double? price;
  final bool isActive;
  final String? myFeedBack;
  final String? joinedAt;

  final List<dynamic>? programs;
  final List<dynamic>? subscribers;
  final List<dynamic>? feedbacks;

  ClassesModel({
    required this.coach,
    this.id,
    this.name,
    this.description,
    this.imagePath,
    this.price,
    required this.isActive,
    this.myFeedBack,
    this.joinedAt,
    this.programs,
    this.subscribers,
    this.feedbacks,
  });

  static List<ClassesModel> parseClassesList(List<dynamic> jsonList) {
    return jsonList.map((e) => ClassesModel.fromJson(e)).toList();
  }

  factory ClassesModel.fromJson(Map<String, dynamic> json) {
    return ClassesModel(
      coach: ProfileDataModel.fromJson(json['coach']),
      id: json['id'] as int?,
      name: json['name'] as String?,
      description: json['description'] as String?,
      imagePath: json['imagePath'] as String?,
      price: (json['price'] as num?)?.toDouble(),
      isActive: json['isActive'] ?? false,
      myFeedBack: json['myFeedBack'] as String?,
      joinedAt: json['joinedAt'] as String?,
      programs: json['programs'] as List<dynamic>?,
      subscribers: json['subscribers'] as List<dynamic>?,
      feedbacks: json['feedbacks'] as List<dynamic>?,
    );
  }
}

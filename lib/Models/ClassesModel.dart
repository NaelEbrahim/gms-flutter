import 'dart:core';

import 'package:gms_flutter/Models/ProfileModel.dart';

class ClassesModel {
  final UserModel coach;
  final int? id;
  final String? name;
  final String? description;
  final String? imagePath;
  final double? price;
  final bool isActive;//
  final String? myFeedBack;//
  final String? joinedAt;//

  final List<dynamic>? programs;
  final List<dynamic>? subscribers;//
  final List<dynamic>? feedbacks;//

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
      coach: UserModel.fromJson(json['coach']),
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


  factory ClassesModel.fromNestedJson(Map<String, dynamic> json) {
    return ClassesModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
      coach: UserModel.fromJson(json['coach']),
      imagePath: json['imagePath'],
      programs: null,
      subscribers: null,
      feedbacks: null,
      isActive: false,
      myFeedBack: null,
      joinedAt: null,
    );
  }

  static List<ClassesModel> parseList(List<dynamic> jsonList) {
    return jsonList.map((e) => ClassesModel.fromNestedJson(e)).toList();
  }
}

class GetClassesModel {
  final int count;

  final int totalPages;

  final int currentPage;

  final List<ClassesModel> items;

  GetClassesModel({
    required this.count,
    required this.totalPages,
    required this.currentPage,
    required this.items,
  });

  factory GetClassesModel.fromJson(Map<String, dynamic> json) {
    return GetClassesModel(
      count: json['count'],
      totalPages: json['totalPages'],
      currentPage: json['currentPage'],
      items: ClassesModel.parseList(json['classes']),
    );
  }
}

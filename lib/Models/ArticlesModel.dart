import 'dart:ffi';

import 'package:gms_flutter/Models/ProfileModel.dart';

class ArticlesModel {
  final int count;
  final int totalPages;
  final int currentPage;
  final List<Article> articles;

  ArticlesModel({
    required this.count,
    required this.totalPages,
    required this.currentPage,
    required this.articles,
  });

  static final List<String> articleCategories = [
    'All',
    'Health',
    'Sport',
    'Food',
    'Fitness',
    'Supplements',
  ];

  factory ArticlesModel.fromJson(Map<String, dynamic> json) {
    return ArticlesModel(
      count: json['count'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      currentPage: json['currentPage'] ?? 0,
      articles:
          (json['articles'] as List<dynamic>?)
              ?.map((e) => Article.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class Article {
  final int id;
  final ProfileDataModel admin;
  final String title;
  final String content;
  final String wikiType;
  final DateTime createdAt;
  final String? lastModifiedAt;
  final int? minReadTime;

  Article({
    required this.id,
    required this.admin,
    required this.title,
    required this.content,
    required this.wikiType,
    required this.createdAt,
    this.lastModifiedAt,
    required this.minReadTime
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'] ?? 0,
      admin: ProfileDataModel.fromJson(json['admin']),
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      wikiType: json['wikiType'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? ''),
      lastModifiedAt: json['lastModifiedAt'],
      minReadTime: json['minReadTime'] ?? 0
    );
  }
}

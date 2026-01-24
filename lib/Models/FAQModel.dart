import 'package:gms_flutter/Models/LoginModel.dart';

class FAQModel {
  final int id;
  final User_Data user;
  final String question;
  final String answer;

  FAQModel({
    required this.id,
    required this.user,
    required this.question,
    required this.answer,
  });

  factory FAQModel.fromJson(Map<String, dynamic> json) {
    return FAQModel(
      id: json['id'],
      user: User_Data.fromJson(json['admin']),
      question: json['question'] as String,
      answer: json['answer'] as String,
    );
  }

  static List<FAQModel> parseList(jsonList) {
    List<FAQModel> results = [];
    if (jsonList != null && (jsonList as List).isNotEmpty) {
      for (var element in jsonList) {
        results.add(FAQModel.fromJson(element));
      }
      return results;
    }
    return results;
  }
}

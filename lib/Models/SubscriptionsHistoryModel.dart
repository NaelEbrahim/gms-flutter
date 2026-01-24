import 'package:gms_flutter/Models/ClassesModel.dart';
import 'package:gms_flutter/Models/LoginModel.dart';

class SubscriptionsHistoryModel {
  int id;
  String paymentDate;
  double paymentAmount;
  double discountPercentage;
  User_Data user;
  ClassesModel aClass;

  SubscriptionsHistoryModel({
    required this.id,
    required this.paymentDate,
    required this.paymentAmount,
    required this.discountPercentage,
    required this.user,
    required this.aClass,
  });

  factory SubscriptionsHistoryModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionsHistoryModel(
      id: json['id'],
      paymentDate: json['paymentDate'],
      paymentAmount: json['paymentAmount'],
      discountPercentage: json['discountPercentage'],
      user: User_Data.fromJson(json['user']),
      aClass: ClassesModel.fromJson(json['aclass']),
    );
  }

  static List<SubscriptionsHistoryModel> parseList(jsonList) {
    List<SubscriptionsHistoryModel> result = [];
    if (jsonList != null && (jsonList as List).isNotEmpty) {
      for (var element in jsonList) {
        result.add(SubscriptionsHistoryModel.fromJson(element));
      }
    }
    return result;
  }
}

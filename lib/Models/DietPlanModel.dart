import 'package:gms_flutter/Models/ProfileModel.dart';

class DietPlanModel {
  final int? id;
  final ProfileDataModel coach;
  final String? title;
  final String? createdAt;
  final String? lastModifiedAt;
  final double? rate;
  final bool? isActive;
  final ScheduleModel? schedule;
  final List<dynamic>? feedbacks;
  final String? myFeedback;
  final String? startedAt;

  DietPlanModel({
    this.id,
    required this.coach,
    this.title,
    this.createdAt,
    this.lastModifiedAt,
    this.rate,
    this.isActive,
    this.schedule,
    this.feedbacks,
    this.myFeedback,
    this.startedAt,
  });

  static List<DietPlanModel> parseList(jsonList) {
    List<DietPlanModel> diets = [];
    if (jsonList != null && (jsonList as List).isNotEmpty) {
      for (var element in jsonList) {
        diets.add(DietPlanModel.fromJson(element));
      }
    }
    return diets;
  }

  factory DietPlanModel.fromJson(Map<String, dynamic> json) {
    return DietPlanModel(
      id: json['id'] as int?,
      coach: ProfileDataModel.fromJson(json['coach']),
      title: json['title'] as String?,
      createdAt: json['createdAt'] as String?,
      lastModifiedAt: json['lastModifiedAt'] as String?,
      rate: (json['rate'] as num?)?.toDouble(),
      isActive: json['isActive'] as bool?,
      schedule: json['schedule'] != null
          ? ScheduleModel.fromJson(json['schedule'])
          : null,
      feedbacks: json['feedBacks'] as List<dynamic>?,
      myFeedback: json['myFeedback'] as String?,
      startedAt: json['startedAt'] as String?,
    );
  }
}

class ScheduleModel {
  final Map<String, DayMealsModel>? days;

  ScheduleModel({this.days});

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    final daysJson = json['days'] as Map<String, dynamic>?;
    Map<String, DayMealsModel>? parsedDays;
    if (daysJson != null) {
      parsedDays = daysJson.map((key, value) =>
          MapEntry(key, DayMealsModel.fromJson(value as Map<String, dynamic>)));
    }
    return ScheduleModel(days: parsedDays);
  }
}

class DayMealsModel {
  final List<MealModel>? breakfast;
  final List<MealModel>? lunch;
  final List<MealModel>? dinner;
  final List<MealModel>? snack;

  DayMealsModel({
    this.breakfast,
    this.lunch,
    this.dinner,
    this.snack,
  });

  factory DayMealsModel.fromJson(Map<String, dynamic> json) {
    return DayMealsModel(
      breakfast: (json['Breakfast'] as List?)
          ?.map((e) => MealModel.fromJson(e))
          .toList(),
      lunch: (json['Lunch'] as List?)
          ?.map((e) => MealModel.fromJson(e))
          .toList(),
      dinner: (json['Dinner'] as List?)
          ?.map((e) => MealModel.fromJson(e))
          .toList(),
      snack: (json['Snack'] as List?)
          ?.map((e) => MealModel.fromJson(e))
          .toList(),
    );
  }
}

class MealModel {
  final int? id;
  final String? title;
  final String? imagePath;
  final double? baseCalories;
  final double? quantity;
  final String? description;
  final double? totalCalories;

  MealModel({
    this.id,
    this.title,
    this.imagePath,
    this.baseCalories,
    this.quantity,
    this.description,
    this.totalCalories,
  });

  factory MealModel.fromJson(Map<String, dynamic> json) {
    return MealModel(
      id: json['id'] as int?,
      title: json['title'] as String?,
      imagePath: json['imagePath'] as String?,
      baseCalories: (json['baseCalories'] as num?)?.toDouble(),
      quantity: (json['quantity'] as num?)?.toDouble(),
      description: json['description'] as String?,
      totalCalories: (json['totalCalories'] as num?)?.toDouble(),
    );
  }
}

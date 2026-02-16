import 'WorkoutModel.dart';

class ProgramModel {
  final int? id;
  final String? name;
  final String? level;
  final bool? isPublic;
  final double? rate;
  final ScheduleModel? schedule;
  final List<dynamic>? feedbacks;

  ProgramModel({
    this.id,
    this.name,
    this.level,
    this.isPublic,
    this.rate,
    this.schedule,
    this.feedbacks,
  });

  factory ProgramModel.fromJson(Map<String, dynamic> json) {
    return ProgramModel(
      id: json['id'] as int?,
      name: json['name'] as String?,
      level: json['level'] as String?,
      isPublic: json['isPublic'] as bool?,
      rate: (json['rate'] as num?)?.toDouble(),
      schedule: json['schedule'] != null
          ? ScheduleModel.fromJson(json['schedule'])
          : null,
      feedbacks: json['feedbacks'] as List<dynamic>?,
    );
  }

  static List<ProgramModel> parseList(List<dynamic> jsonList) {
    return jsonList.map((e) => ProgramModel.fromJson(e)).toList();
  }
}

class ScheduleModel {
  final Map<String, WorkoutDayModel>? days;

  ScheduleModel({this.days});

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    final daysJson = json['days'] as Map<String, dynamic>?;

    Map<String, WorkoutDayModel>? parsedDays;
    if (daysJson != null) {
      parsedDays = daysJson.map(
        (key, value) => MapEntry(
          key,
          WorkoutDayModel.fromJson(value as Map<String, dynamic>),
        ),
      );
    }

    return ScheduleModel(days: parsedDays);
  }
}

class WorkoutDayModel {
  final Map<String, List<WorkoutModel>>? muscleGroups;

  WorkoutDayModel({this.muscleGroups});

  factory WorkoutDayModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> map = json;

    final parsed = map.map((muscleName, workoutsJson) {
      final list = (workoutsJson as List)
          .map((w) => WorkoutModel.fromJson(w))
          .toList();

      return MapEntry(muscleName, list);
    });

    return WorkoutDayModel(muscleGroups: parsed);
  }
}

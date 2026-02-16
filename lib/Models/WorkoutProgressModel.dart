class WorkoutProgressModel {
  int id;
  double? weight;
  double? duration;
  String? note;
  DateTime recordedAt;

  WorkoutProgressModel({
    required this.id,
    this.weight,
    this.duration,
    this.note,
    required this.recordedAt,
  });

  factory WorkoutProgressModel.fromJson(Map<String, dynamic> json) {
    return WorkoutProgressModel(
      id: json['id'],
      weight: json['weight'] as double?,
      duration: json['duration'] as double?,
      note: json['note'] as String?,
      recordedAt: DateTime.parse(json['recordedAt']) ,
    );
  }

  static List<WorkoutProgressModel> parseList(List<dynamic> jsonList) {
    return jsonList.map((e) => WorkoutProgressModel.fromJson(e)).toList();
  }
}

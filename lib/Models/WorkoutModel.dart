class WorkoutModel {
  final int id;
  final String title;
  final double baseAvgCalories;
  final String primaryMuscle;
  final String? secondaryMuscles;
  final double totalBurnedCalories;
  final String description;
  final String? imagePath;
  final int? reps;
  final int sets;
  final int? duration;
  final int? programWorkoutId;

  WorkoutModel({
    required this.id,
    required this.title,
    required this.baseAvgCalories,
    required this.primaryMuscle,
    this.secondaryMuscles,
    required this.totalBurnedCalories,
    required this.description,
    this.imagePath,
    required this.reps,
    required this.sets,
    required this.duration,
    this.programWorkoutId,
  });

  factory WorkoutModel.fromJson(Map<String, dynamic> json) {
    return WorkoutModel(
      id: json['id'],
      title: json['title'],
      baseAvgCalories: (json['baseAvgCalories'] ?? 0).toDouble(),
      primaryMuscle: json['primaryMuscle'],
      secondaryMuscles: json['secondaryMuscles'],
      totalBurnedCalories: (json['totalBurnedCalories'] ?? 0).toDouble(),
      description: json['description'],
      imagePath: json['imagePath'],
      reps: json['reps'],
      sets: json['sets'],
      duration: json['duration'] ?? 0,
      programWorkoutId: json['program_workout_id'],
    );
  }

  static List<WorkoutModel> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => WorkoutModel.fromJson(json)).toList();
  }
}

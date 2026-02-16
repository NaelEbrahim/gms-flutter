class HealthInfoModel {
  final int id;
  final String recordedAt;
  final double weightKg;
  final double heightCm;
  final String? notes;
  final double? waistCircumference;
  final double? armCircumference;
  final double? thighCircumference;

  HealthInfoModel({
    required this.id,
    required this.recordedAt,
    required this.weightKg,
    required this.heightCm,
    this.notes,
    this.waistCircumference,
    this.armCircumference,
    this.thighCircumference,
  });

  // Helper to convert recordedAt string to a DateTime object
  DateTime get recordedDateTime => DateTime.parse(recordedAt);

  double get bmi {
    if (heightCm == 0) return 0.0;
    final double heightMeters = heightCm / 100.0;
    return weightKg / (heightMeters * heightMeters);
  }

  factory HealthInfoModel.fromJson(Map<String, dynamic> json) {
    return HealthInfoModel(
      id: json['id'] as int,
      recordedAt: json['recordedAt'] as String,
      weightKg: (json['weightKg'] as num).toDouble(),
      heightCm: (json['heightCm'] as num).toDouble(),
      notes: json['notes'] as String?,
      waistCircumference: (json['waistCircumference'] as num?)?.toDouble(),
      armCircumference: (json['armCircumference'] as num?)?.toDouble(),
      thighCircumference: (json['thighCircumference'] as num?)?.toDouble(),
    );
  }

  static List<HealthInfoModel> parseList(List<dynamic> jsonList) {
    return jsonList.map((e) => HealthInfoModel.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recordedAt': recordedAt,
      'weightKg': weightKg,
      'heightCm': heightCm,
      'notes': notes,
      'waistCircumference': waistCircumference,
      'armCircumference': armCircumference,
      'thighCircumference': thighCircumference,
    };
  }
}

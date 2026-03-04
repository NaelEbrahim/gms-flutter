import 'ProfileModel.dart';

class PrivateCoachModel {
  final UserModel coach;
  final bool isActive;
  final String? startedAt;
  final double? rate;

  PrivateCoachModel({
    required this.coach,
    required this.isActive,
    this.startedAt,
    this.rate,
  });

  factory PrivateCoachModel.fromJson(Map<String, dynamic> json) {
    return PrivateCoachModel(
      coach: UserModel.fromJson(json['item']),
      isActive: json['isActive'] as bool,
      startedAt: json['startedAt'] as String?,
      rate: (json['rate'] ?? 0)?.toDouble(),
    );
  }

  static List<PrivateCoachModel> parseList(List<dynamic> jsonList) {
    return jsonList.map((e) => PrivateCoachModel.fromJson(e)).toList();
  }
}

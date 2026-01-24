import 'ProfileModel.dart';

class PrivateCoachModel {
  final ProfileDataModel coach;
  final bool isActive;
  final String? startedAt;
  final double? rate;

  PrivateCoachModel({required this.coach, required this.isActive,this.startedAt, this.rate});

  factory PrivateCoachModel.fromJson(Map<String, dynamic> json) {
    return PrivateCoachModel(
      coach: ProfileDataModel.fromJson(json['coach']),
      isActive: json['isActive'] as bool,
      startedAt: json['startedAt'] as String?,
      rate: (json['rate'] as num?)?.toDouble(),
    );
  }

  static List<PrivateCoachModel> parseList(jsonList) {
    List<PrivateCoachModel> coaches = [];
    if (jsonList['message'] != null && (jsonList['message'] as List).isNotEmpty) {
      for (var element in jsonList['message']) {
        coaches.add(PrivateCoachModel.fromJson(element));
      }
    }
    return coaches;
  }
}

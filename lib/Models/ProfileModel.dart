class ProfileModel {
  ProfileDataModel data;

  ProfileModel({required this.data});

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(data: ProfileDataModel.fromJson(json['message']));
  }
}

class ProfileDataModel {
  final int? id;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? profileImagePath;
  final String? phoneNumber;
  final String? gender;
  final String? dob;
  final String? createdAt;
  final String? qr;

  ProfileDataModel({
    this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.profileImagePath,
    this.phoneNumber,
    this.gender,
    this.dob,
    this.createdAt,
    this.qr,
  });

  factory ProfileDataModel.fromJson(Map<String, dynamic> json) {
    return ProfileDataModel(
      id: json['id'] as int?,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      email: json['email'] as String?,
      profileImagePath: json['profileImagePath'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      gender: json['gender'] as String?,
      dob: json['dob'],
      createdAt: json['createdAt'],
      qr: json['qr'] as String?,
    );
  }

  static List<ProfileDataModel> parseList(jsonList) {
    List<ProfileDataModel> coaches = [];
    if (jsonList != null && (jsonList['users'] as List).isNotEmpty) {
      for (var element in jsonList['users']) {
        coaches.add(ProfileDataModel.fromJson(element));
      }
      return coaches;
    }
    return [];
  }
}

class Login_Model {
  final User_Data message;
  final String accessToken;
  final String refreshToken;

  Login_Model(this.message, this.accessToken, this.refreshToken);

  factory Login_Model.fromJson(Map<String, dynamic> json) {
    return Login_Model(
      User_Data.fromJson(json['message']),
      json['message']['accessToken'],
      json['message']['refreshToken'],
    );
  }
}

class User_Data {
  final int? id;
  final String? firstName;
  final String? lastName;
  final String? email;
  final String? profileImagePath;
  final String? phoneNumber;
  final String? gender;
  final String? dob;

  User_Data({
    this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.profileImagePath,
    this.phoneNumber,
    this.gender,
    this.dob,
  });

  factory User_Data.fromJson(Map<String, dynamic> json) {
    return User_Data(
      id: json['id'] as int?,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      email: json['email'] as String?,
      profileImagePath: json['profileImagePath'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      gender: json['gender'] as String?,
      dob: json['dob'] as String?,
    );
  }
}

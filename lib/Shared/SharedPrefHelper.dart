import 'package:gms_flutter/Models/ProfileModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefHelper {
  static late SharedPreferences _prefs;

  static Future init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future saveString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  static Future saveInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }

  static Future saveBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  static Future saveUserData(UserModel data) async {
    saveString('id', data.id.toString());
    saveString('firstName', data.firstName.toString());
    saveString('lastName', data.lastName.toString());
    saveString('email', data.email.toString());
    saveString('profileImagePath', data.profileImagePath.toString());
    saveString('phoneNumber', data.phoneNumber.toString());
    saveString('gender', data.gender.toString());
    saveString('dob', data.dob.toString());
  }

  static String? getString(String key) => _prefs.getString(key);

  static int? getInt(String key) => _prefs.getInt(key);

  static bool? getBool(String key) => _prefs.getBool(key);

  static Future remove(String key) async {
    await _prefs.remove(key);
  }

  static Future clear() async {
    await _prefs.clear();
  }
}

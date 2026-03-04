import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gms_flutter/Shared/Constant.dart';
import 'package:gms_flutter/Shared/SharedPrefHelper.dart';

class ThemeManager extends Cubit<ThemeData> {
  static final mainDarkColor = Constant.scaffoldColor;
  static final mainLightColor = Colors.grey[700];

  ThemeManager() : super(_darkTheme) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final isDark = SharedPrefHelper.getBool('appTheme') ?? true;
    if (isDark) {
      emit(_darkTheme);
    } else {
      emit(_lightTheme);
    }
  }

  static final _darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: mainDarkColor,
    canvasColor: Colors.black,
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: Colors.greenAccent,
    ),
    drawerTheme: DrawerThemeData(backgroundColor: mainDarkColor),
    bottomSheetTheme: BottomSheetThemeData(backgroundColor: mainDarkColor),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      selectedItemColor: Colors.greenAccent,
      unselectedItemColor: Colors.white,
    ),
  );

  static final _lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: mainLightColor,
    canvasColor: Colors.grey[800],
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: Colors.greenAccent,
    ),
    drawerTheme: DrawerThemeData(backgroundColor: mainLightColor),
    bottomSheetTheme: BottomSheetThemeData(backgroundColor: mainLightColor),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey[800],
      foregroundColor: Colors.white,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      selectedItemColor: Colors.greenAccent,
      unselectedItemColor: Colors.white,
    ),
  );

  void setLight() => emit(_lightTheme);

  void setDark() => emit(_darkTheme);
}

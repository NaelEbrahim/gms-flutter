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
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: Colors.greenAccent,
    ),
    drawerTheme: DrawerThemeData(backgroundColor: mainDarkColor),
    bottomSheetTheme: BottomSheetThemeData(backgroundColor: mainDarkColor),
  );

  static final _lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: mainLightColor,
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: Colors.greenAccent,
    ),
    drawerTheme: DrawerThemeData(backgroundColor: mainLightColor),
    bottomSheetTheme: BottomSheetThemeData(backgroundColor: mainLightColor),
  );

  void setLight() => emit(_lightTheme);

  void setDark() => emit(_darkTheme);
}

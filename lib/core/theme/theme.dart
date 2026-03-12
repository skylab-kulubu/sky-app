import 'package:flutter/material.dart';
import 'package:sky_app/core/constants/app_colors.dart';

//light theme
ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  cardColor: Colors.blueGrey,
  scaffoldBackgroundColor: Colors.white,
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    shape: CircleBorder(),
    backgroundColor: Colors.grey.shade300,
    foregroundColor: Colors.grey.shade900,
  ),
  colorScheme: ColorScheme.light(
    primary: AppColors.primaryColor,
    secondary: Colors.grey.shade400,
    surfaceContainer: Colors.grey.shade300,

    inversePrimary: Colors.grey.shade800,
  ),
  textTheme: TextTheme(bodyMedium: TextStyle(color: Colors.grey.shade900)),
  snackBarTheme: SnackBarThemeData(
    backgroundColor: Colors.grey.shade200,
    contentTextStyle: TextStyle(color: Colors.grey.shade900),
    actionTextColor: Colors.grey.shade800,
  ),
);

//dark theme
ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  cardColor: Colors.blueGrey.shade900,
  scaffoldBackgroundColor: Colors.grey.shade900,
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    shape: CircleBorder(),
    backgroundColor: Colors.grey.shade700,
    foregroundColor: Colors.grey.shade300,
  ),
  colorScheme: ColorScheme.dark(
    primary: Colors.grey.shade800,
    secondary: Colors.grey.shade700,
    surfaceContainer: Colors.grey.shade800,
    inversePrimary: Colors.grey.shade100,
  ),
  textTheme: TextTheme(bodyMedium: TextStyle(color: Colors.grey.shade400)),
  snackBarTheme: SnackBarThemeData(
    backgroundColor: Colors.grey.shade800,
    contentTextStyle: TextStyle(color: Colors.grey.shade300),
    actionTextColor: Colors.grey.shade300,
  ),
);

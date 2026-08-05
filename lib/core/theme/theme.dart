import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sky_app/core/constants/app_colors.dart';
import 'package:sky_app/core/constants/app_paddings.dart';

/// Zemin, metin ve ayraç renkleri buradaki [ColorScheme]'lerden gelir;
/// widget'lar bunlara `context` üzerinden erişir (bkz. context_extensions).
/// [AppColors] yalnızca temadan bağımsız marka/vurgu renklerini tutar.

//light theme
ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  scaffoldBackgroundColor: AppColors.lightBackground,
  dividerColor: AppColors.lightDivider,
  colorScheme: const ColorScheme.light(
    primary: AppColors.primaryStrong,
    onPrimary: AppColors.lightBackground,
    secondary: AppColors.primaryDeep,
    surface: AppColors.lightBackground,
    onSurface: AppColors.lightTextPrimary,
    onSurfaceVariant: AppColors.lightTextSecondary,
    surfaceContainer: AppColors.lightTile,
    surfaceContainerHigh: AppColors.lightTileHigh,
    outline: AppColors.lightTextTertiary,
    outlineVariant: AppColors.lightDivider,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    scrolledUnderElevation: 0,
    surfaceTintColor: Colors.transparent,
    centerTitle: false,
    actionsPadding: AppPaddings.appBarActions,
    // AppBar zemini saydam olduğu için Flutter durum çubuğu parlaklığını
    // doğru çıkaramıyor; açıkça belirtiliyor.
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
    iconTheme: IconThemeData(color: AppColors.lightTextPrimary),
    titleTextStyle: TextStyle(
      fontFamily: 'Poppins',
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: AppColors.lightTextPrimary,
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    shape: CircleBorder(),
    backgroundColor: AppColors.lightTileHigh,
    foregroundColor: AppColors.lightTextPrimary,
  ),
  textTheme: const TextTheme(
    displaySmall: TextStyle(fontFamily: 'Poppins'),
    titleLarge: TextStyle(fontFamily: 'Poppins'),
    titleMedium: TextStyle(fontFamily: 'Poppins'),
    titleSmall: TextStyle(fontFamily: 'Poppins'),
    labelSmall: TextStyle(fontFamily: 'Poppins'),
    bodyMedium: TextStyle(color: AppColors.lightTextPrimary),
  ),
  snackBarTheme: const SnackBarThemeData(
    backgroundColor: AppColors.lightTileHigh,
    contentTextStyle: TextStyle(color: AppColors.lightTextPrimary),
    actionTextColor: AppColors.primaryStrong,
  ),
);

//dark theme
ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: AppColors.darkBackground,
  dividerColor: AppColors.darkDivider,
  colorScheme: const ColorScheme.dark(
    primary: AppColors.primaryColor,
    onPrimary: AppColors.darkBackground,
    secondary: AppColors.primaryDeep,
    surface: AppColors.darkBackground,
    onSurface: AppColors.darkTextPrimary,
    onSurfaceVariant: AppColors.darkTextSecondary,
    surfaceContainer: AppColors.darkTile,
    surfaceContainerHigh: AppColors.darkTileHigh,
    outline: AppColors.darkTextTertiary,
    outlineVariant: AppColors.darkDivider,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    scrolledUnderElevation: 0,
    surfaceTintColor: Colors.transparent,
    centerTitle: false,
    actionsPadding: AppPaddings.appBarActions,
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
    ),
    iconTheme: IconThemeData(color: AppColors.darkTextPrimary),
    titleTextStyle: TextStyle(
      fontFamily: 'Poppins',
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: AppColors.darkTextPrimary,
    ),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    shape: CircleBorder(),
    backgroundColor: AppColors.darkTileHigh,
    foregroundColor: AppColors.darkTextPrimary,
  ),
  textTheme: const TextTheme(
    displaySmall: TextStyle(fontFamily: 'Poppins'),
    titleLarge: TextStyle(fontFamily: 'Poppins'),
    titleMedium: TextStyle(fontFamily: 'Poppins'),
    titleSmall: TextStyle(fontFamily: 'Poppins'),
    labelSmall: TextStyle(fontFamily: 'Poppins'),
    bodyMedium: TextStyle(color: AppColors.darkTextSecondary),
  ),
  snackBarTheme: const SnackBarThemeData(
    backgroundColor: AppColors.darkTileHigh,
    contentTextStyle: TextStyle(color: AppColors.darkTextPrimary),
    actionTextColor: AppColors.primaryColor,
  ),
);

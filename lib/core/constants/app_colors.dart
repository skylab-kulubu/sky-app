import 'package:flutter/material.dart';

class AppColors {
  // Main Colors
  static const primaryColor = Color(0xFFe0c8e5);
  static const cardBackground = Color(0xFF252525);
  static const buttonBackground = Color(0xFF263238);
  static const indicatorColor = Color(0xFFe0c8e5);
  static const secondaryBlue = Color(0xFF00BFFF);
  static const scaffoldBackgroundColor = Color(0xFF000000);
  static const tileBackgroundColor = Color.fromARGB(255, 27, 26, 26);

  // Bottom Navigation (glass floating nav from design)
  static const navBackground = Color(0xEB1E1E24); // slightly translucent glass
  static const primaryDeep = Color(0xFFC9A0D6);
  static const navTextTertiary = Color(0xFF9A97A6);
  static final navBorder = Colors.white.withValues(alpha: 0.10);
  static final navIndicator = const Color(
    0xFFE0C8E5,
  ).withValues(alpha: 0.14); // primarySoft

  // Text Colors
  static const textWhite = Color(0xFFFFFFFF);
  static const textWhite70 = Color(0xFFF0F0F0);
  static const textGray = Color(0xFF888888);
  static const textGrayDark = Color(0xFF666666);
  static const textGrayDarker = Color(0xFF555555);
  static const unselectedLabelColor = Color(0xFF888888);
  static const buttonColor = Color(0xFF303032);

  // Divider & Border
  static const dividerColor = Color(0xFF333333);

  // Status & Icon Colors
  static const teal = Color(0xFF1ABC9C);
  static const green = Color(0xFF2ECC71);
  static const purple = Color(0xFF6C5CE7);
  static const darkPurple = Color(0xFF9B59B6);
  static const orange = Color(0xFFE67E22);
  static const pink = Color(0xFFE84393);
  static const coral = Color(0xFFFF6467);
  static const red = Color(0xFFE74C3C);
  static const darkOrange = Color(0xFFF39C12);
  static const brightRed = Color(0xFFFB2C36);

  // Opacity Backgrounds (For icon boxes)
  static final primaryBlue10 = const Color(0xFF1E90FF).withValues(alpha: 0.1);
  static final secondaryBlue9 = const Color(
    0xFF00BFFF,
  ).withValues(alpha: 0.094);
  static final teal9 = const Color(0xFF1ABC9C).withValues(alpha: 0.094);
  static final green9 = const Color(0xFF2ECC71).withValues(alpha: 0.094);
  static final purple9 = const Color(0xFF6C5CE7).withValues(alpha: 0.094);
  static final darkPurple9 = const Color(0xFF9B59B6).withValues(alpha: 0.094);
  static final orange9 = const Color(0xFFE67E22).withValues(alpha: 0.094);
  static final red9 = const Color(0xFFE74C3C).withValues(alpha: 0.094);
  static final pink9 = const Color(0xFFE84393).withValues(alpha: 0.094);
}

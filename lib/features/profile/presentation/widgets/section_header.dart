import 'package:flutter/material.dart';
import 'package:sky_app/core/constants/app_colors.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 24, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textGrayDark,
          letterSpacing: 1.2,
          fontFamily: 'Poppins',
        ),
      ),
    );
  }
}

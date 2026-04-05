import 'package:flutter/material.dart';
import 'package:sky_app/core/constants/app_radiuses.dart';

class IconBox extends StatelessWidget {
  const IconBox({super.key, required this.icon, required this.iconColor});

  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadiuses.iconBox),
      ),
      child: Icon(icon, color: iconColor, size: 22),
    );
  }
}

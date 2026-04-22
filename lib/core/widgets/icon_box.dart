import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sky_app/core/constants/app_radiuses.dart';

class IconBox extends StatelessWidget {
  const IconBox({
    super.key,
    required this.icon,
    required this.color,
    this.size = 40,
    this.padding = 10,
  });

  final String icon;
  final double? size;
  final double? padding;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(padding!),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadiuses.iconBox),
      ),
      child: SvgPicture.asset(icon, fit: BoxFit.contain),
    );
  }
}

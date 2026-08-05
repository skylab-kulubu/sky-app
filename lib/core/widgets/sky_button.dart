import 'package:flutter/material.dart';
import 'package:sky_app/core/constants/app_radiuses.dart';
import 'package:sky_app/core/extensions/context_extensions.dart';

class SkyButton extends StatelessWidget {
  final String text;
  final Widget? icon;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;

  const SkyButton({
    super.key,
    required this.text,
    this.icon,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? context.elevatedColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadiuses.containerRadius),
          ),
          elevation: 0,
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[icon!, const SizedBox(width: 12)],
            Text(
              text,
              style: TextStyle(
                color: textColor ?? context.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

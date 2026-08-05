import 'package:flutter/material.dart';
import 'package:sky_app/core/constants/app_radiuses.dart';
import 'package:sky_app/core/extensions/context_extensions.dart';

class SkyTextfield extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final bool obscureText;
  final Widget? suffixIcon;

  const SkyTextfield({
    super.key,
    required this.hintText,
    this.controller,
    this.obscureText = false,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: TextStyle(color: context.textPrimary),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: context.textSecondary),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: context.backgroundColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadiuses.containerRadius),
          borderSide: BorderSide(color: context.elevatedColor, width: 1.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadiuses.containerRadius),
          borderSide: BorderSide(color: context.textSecondary, width: 1.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadiuses.containerRadius),
          borderSide: BorderSide(color: context.accentColor, width: 1.5),
        ),
      ),
    );
  }
}

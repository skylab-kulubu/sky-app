import 'package:flutter/material.dart';
import 'package:sky_app/core/constants/app_sizes.dart';
import 'package:sky_app/core/widgets/app_icon.dart';

class TabLabel extends StatelessWidget {
  final String? icon;
  final String label;
  const TabLabel({super.key, this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        icon != null
            ? AppIcon(icon!, size: AppSizes.icon)
            : const SizedBox.shrink(),
        const SizedBox(width: AppSizes.bigSpace),
        Text(label),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:sky_app/core/constants/app_sizes.dart';

class TabLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  const TabLabel({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon),
        const SizedBox(width: AppSizes.bigSpace),
        Text(label),
      ],
    );
  }
}

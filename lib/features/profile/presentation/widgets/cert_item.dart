import 'package:flutter/material.dart';
import 'package:sky_app/core/constants/app_colors.dart';
import 'package:sky_app/core/constants/app_paddings.dart';
import 'package:sky_app/features/profile/data/models/cert_model.dart';

class CertItem extends StatelessWidget {
  const CertItem({super.key, required this.certificate});

  final Certificate certificate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppPaddings.mainPaddingAll,
      child: Row(
        children: [_iconContainer(), const SizedBox(width: 16), _textsColumn()],
      ),
    );
  }

  Widget _iconContainer() => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Color(0xFF332D21), // Örn: cert background color
      borderRadius: BorderRadius.circular(12),
    ),
    child: const Icon(
      Icons.workspace_premium,
      color: Colors.orangeAccent,
      size: 24,
    ),
  );

  Widget _textsColumn() => Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          certificate.title,
          style: const TextStyle(
            color: AppColors.textWhite,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          certificate.subtitle,
          style: const TextStyle(color: AppColors.textGrey, fontSize: 12),
        ),
      ],
    ),
  );
}

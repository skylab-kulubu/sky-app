import 'package:flutter/material.dart';
import 'package:sky_app/core/constants/app_assets.dart';
import 'package:sky_app/core/constants/app_colors.dart';
import 'package:sky_app/core/constants/app_paddings.dart';
import 'package:sky_app/core/widgets/icon_box.dart';
import 'package:sky_app/features/profile/data/models/cert_model.dart';

class CertItem extends StatelessWidget {
  const CertItem({super.key, required this.certificate});

  final Certificate certificate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppPaddings.mainPaddingAll,
      child: Row(
        children: [
          const IconBox(
            icon: AppAssets.certificate,
            color: Colors.blue,
            size: 48,
          ),
          const SizedBox(width: 16),
          _textsColumn(),
        ],
      ),
    );
  }

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
          style: const TextStyle(color: AppColors.textGray, fontSize: 12),
        ),
      ],
    ),
  );
}

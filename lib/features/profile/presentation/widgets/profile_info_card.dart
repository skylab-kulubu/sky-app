import 'package:flutter/material.dart';
import 'package:sky_app/core/constants/app_colors.dart';
import 'package:sky_app/core/constants/app_paddings.dart';
import 'package:sky_app/core/constants/app_radiuses.dart';
import 'package:sky_app/core/constants/app_sizes.dart';
import 'package:sky_app/core/extensions/context_extensions.dart';

/// Hesap bilgilerini etiket + değer satırları hâlinde gösteren kart.
///
/// Etiket değerin üstünde durur; değer tam genişliği kullandığı için uzun
/// e-posta ve bölüm adları kesilmez.
class ProfileInfoCard extends StatelessWidget {
  const ProfileInfoCard({super.key, required this.rows});

  final List<ProfileInfoRow> rows;

  @override
  Widget build(BuildContext context) {
    final visible = rows.where((r) => r.value.trim().isNotEmpty).toList();
    if (visible.isEmpty) return const SizedBox.shrink();

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadiuses.tile),
      child: Container(
        color: AppColors.tileBackgroundColor,
        child: Column(
          // stretch olmadan satırlar kendi içerik genişliğinde kalıp
          // yatayda ortalanıyor; kartın tamamını kaplamaları gerekiyor.
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < visible.length; i++) ...[
              if (i > 0) _divider(),
              _row(context, visible[i]),
            ],
          ],
        ),
      ),
    );
  }

  Widget _row(BuildContext context, ProfileInfoRow row) {
    return Padding(
      padding: AppPaddings.profileInfoRow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            row.label,
            style: context.textTheme.bodySmall?.copyWith(
              color: AppColors.textGray,
            ),
          ),
          const SizedBox(height: AppSizes.smallSpace),
          Text(
            row.value,
            style: context.textTheme.bodyLarge?.copyWith(
              color: AppColors.textWhite,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => const Divider(
    height: 1,
    color: AppColors.dividerColor,
    indent: 16,
    endIndent: 16,
  );
}

class ProfileInfoRow {
  const ProfileInfoRow({required this.label, required this.value});

  final String label;

  /// Boş olan satırlar hiç çizilmez.
  final String value;
}

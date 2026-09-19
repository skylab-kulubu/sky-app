import 'package:flutter/material.dart';
import 'package:sky_app/core/constants/app_colors.dart';
import 'package:sky_app/core/constants/app_icons.dart';
import 'package:sky_app/core/constants/app_paddings.dart';
import 'package:sky_app/core/constants/app_radiuses.dart';
import 'package:sky_app/core/constants/app_sizes.dart';
import 'package:sky_app/core/extensions/context_extensions.dart';
import 'package:sky_app/core/widgets/app_icon.dart';

/// Bir okutmanın sonucu: başarılı, zaten yapılmış ya da hata.
enum ScanResultKind { success, already, error }

class ScanResult {
  const ScanResult(this.kind, this.title, [this.detail = '']);

  final ScanResultKind kind;
  final String title;
  final String detail;
}

/// Okuyucunun altındaki sonuç kartı; sonuç yokken ne yapılacağını söyleyen
/// ipucunu gösteriyor. Kapı okuyucusu ve oturum QR'ı aynı kartı kullanıyor.
class ScanResultCard extends StatelessWidget {
  const ScanResultCard({
    super.key,
    required this.result,
    required this.hintIcon,
    required this.hint,
  });

  final ScanResult? result;
  final String hintIcon;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final value = result;
    final (icon, color) = switch (value?.kind) {
      ScanResultKind.success => (AppIcons.checkCircle, AppColors.green),
      ScanResultKind.already => (AppIcons.clock, AppColors.orange),
      ScanResultKind.error => (AppIcons.warning, AppColors.red),
      null => (hintIcon, context.textTertiary),
    };

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: Container(
        key: ValueKey(value),
        padding: AppPaddings.settingsTile,
        decoration: BoxDecoration(
          color: context.tileColor,
          borderRadius: AppRadiuses.cardBorderRadius,
        ),
        child: Row(
          children: [
            AppIcon(icon, size: AppSizes.iconMedium, color: color),
            const SizedBox(width: AppSizes.bigSpace),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value?.title ?? hint,
                    // Ölçüler SettingsTile ile aynı; ipucu sade, sonuç
                    // renkli ve biraz daha kalın.
                    style: context.textTheme.titleMedium?.copyWith(
                      fontWeight: value == null
                          ? FontWeight.w400
                          : FontWeight.w500,
                      color: value == null ? context.textSecondary : color,
                    ),
                  ),
                  if (value != null && value.detail.isNotEmpty) ...[
                    const SizedBox(height: AppSizes.smallSpace),
                    Text(
                      value.detail,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

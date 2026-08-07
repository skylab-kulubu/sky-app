import 'package:flutter/material.dart';
import 'package:sky_app/core/constants/app_colors.dart';
import 'package:sky_app/core/constants/app_icons.dart';
import 'package:sky_app/core/constants/app_paddings.dart';
import 'package:sky_app/core/constants/app_sizes.dart';
import 'package:sky_app/core/extensions/context_extensions.dart';
import 'package:sky_app/core/widgets/app_icon.dart';

/// Hesap sayfasındaki bilgi satırı: solda etiket, sağda değer.
///
/// [onTap] verilmezse satır salt okunur olur ve dokunma efekti almaz; hesap
/// bilgileri üyelik kaydından geliyor, uygulama içinden düzenlenmiyor.
class AccountInfoTile extends StatelessWidget {
  const AccountInfoTile({
    super.key,
    required this.label,
    required this.value,
    this.onTap,
    this.trailingIcon,
    this.verified = false,
  });

  /// Kısa tutulur: genişliği içeriğine göre alır, kalanı [value]'ya kalır.
  final String label;

  final String value;

  final VoidCallback? onTap;

  /// [AppIcons] içindeki ikon adı; dışarı açılan satırlarda
  /// [AppIcons.externalLink] verilir.
  final String? trailingIcon;

  /// Değerin yanına doğrulama rozeti koyar (doğrulanmış e-posta).
  final bool verified;

  @override
  Widget build(BuildContext context) {
    final row = Padding(
      padding: AppPaddings.infoTile,
      child: Row(
        children: [
          Text(
            label,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w400,
              color: context.textPrimary,
            ),
          ),
          const SizedBox(width: AppSizes.bigSpace),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              // Uzun okul e-postaları tek satıra sığmıyor; kesmek yerine
              // ikinci satıra taşıyoruz.
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.textSecondary,
              ),
            ),
          ),
          if (verified) ...[
            const SizedBox(width: AppSizes.midSpace),
            const AppIcon(
              AppIcons.verified,
              filled: true,
              size: AppSizes.iconSmall,
              color: AppColors.green,
            ),
          ],
          if (trailingIcon != null) ...[
            const SizedBox(width: AppSizes.midSpace),
            AppIcon(
              trailingIcon!,
              size: AppSizes.iconSmall,
              color: context.textTertiary,
            ),
          ],
        ],
      ),
    );

    if (onTap == null) return row;

    return Material(
      color: Colors.transparent,
      child: InkWell(onTap: onTap, child: row),
    );
  }
}

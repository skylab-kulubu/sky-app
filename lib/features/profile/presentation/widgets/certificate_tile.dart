import 'package:flutter/material.dart';
import 'package:sky_app/core/constants/app_colors.dart';
import 'package:sky_app/core/constants/app_icons.dart';
import 'package:sky_app/core/constants/app_paddings.dart';
import 'package:sky_app/core/constants/app_sizes.dart';
import 'package:sky_app/core/extensions/context_extensions.dart';
import 'package:sky_app/core/widgets/app_icon.dart';
import 'package:sky_app/core/widgets/icon_circle.dart';
import 'package:sky_app/features/profile/data/models/certificate.dart';

/// Sertifika listesindeki tek satır: solda ikon dairesi, sağda sertifika adı
/// ve altında veren ekip ile tarih.
///
/// Düzeni ve tipografisi ayarlardaki hesap satırıyla aynı; tek farkı solundaki
/// avatarın yerini renkli ikon dairesinin alması. Ortak bir widget'a
/// çıkarılmadı: hesap satırı tek başına duran bir kart, bu satır ise
/// [TileGroup] içinde yaşıyor ve kendi zeminini çizmiyor.
class CertificateTile extends StatelessWidget {
  const CertificateTile({super.key, required this.certificate});

  final Certificate certificate;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppPaddings.accountTile,
      child: Row(
        children: [
          const IconCircle(icon: AppIcons.certificate, color: AppColors.blue),
          const SizedBox(width: AppSizes.bigSpace),
          Expanded(child: _texts(context)),
          AppIcon(
            AppIcons.chevronRight,
            size: AppSizes.iconSmall,
            color: context.textTertiary,
          ),
        ],
      ),
    );
  }

  Widget _texts(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          certificate.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: context.textPrimary,
          ),
        ),
        const SizedBox(height: AppSizes.smallSpace),
        Text(
          certificate.subtitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textTheme.bodySmall?.copyWith(
            color: context.textSecondary,
          ),
        ),
      ],
    );
  }
}

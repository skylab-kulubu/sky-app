import 'package:flutter/material.dart';
import 'package:sky_app/core/constants/app_colors.dart';
import 'package:sky_app/core/constants/app_icons.dart';
import 'package:sky_app/core/constants/app_paddings.dart';
import 'package:sky_app/core/constants/app_radiuses.dart';
import 'package:sky_app/core/constants/app_sizes.dart';
import 'package:sky_app/core/extensions/context_extensions.dart';
import 'package:sky_app/core/widgets/settings_tile.dart';
import 'package:sky_app/core/widgets/tile_group.dart';
import 'package:sky_app/features/profile/data/models/certificate.dart';

/// Sertifikaya dokununca açılan işlemler.
enum CertificateAction { openPdf, verify, share }

/// Sertifikanın işlemleri: PDF (yalnızca geçerlide), doğrulama sayfası ve
/// paylaşma. Adresi olmayan işlem listelenmiyor. Seçileni döner.
class CertificateActionsSheet extends StatelessWidget {
  const CertificateActionsSheet({super.key, required this.certificate});

  final Certificate certificate;

  static Future<CertificateAction?> show(
    BuildContext context,
    Certificate certificate,
  ) {
    return showModalBottomSheet<CertificateAction>(
      context: context,
      useRootNavigator: true,
      backgroundColor: context.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadiuses.sheetBorderRadius,
      ),
      builder: (_) => CertificateActionsSheet(certificate: certificate),
    );
  }

  @override
  Widget build(BuildContext context) {
    void pick(CertificateAction action) => Navigator.pop(context, action);

    return SafeArea(
      top: false,
      child: Padding(
        padding: AppPaddings.mainPaddingAll,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              certificate.eventName,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSizes.bigSpace),
            TileGroup(
              children: [
                if (certificate.isValid && certificate.pdfUrl != null)
                  SettingsTile(
                    icon: AppIcons.certificate,
                    iconColor: AppColors.blue,
                    title: 'Sertifikayı Aç',
                    subtitle: 'PDF olarak görüntüle ya da indir',
                    trailingIcon: AppIcons.externalLink,
                    onTap: () => pick(CertificateAction.openPdf),
                  ),
                if (certificate.verifyUrl != null)
                  SettingsTile(
                    icon: AppIcons.permissions,
                    iconColor: AppColors.green,
                    title: 'Doğrula',
                    subtitle: 'Herkese açık doğrulama sayfası',
                    trailingIcon: AppIcons.externalLink,
                    onTap: () => pick(CertificateAction.verify),
                  ),
                if (certificate.shareUrl != null)
                  SettingsTile(
                    icon: AppIcons.share,
                    iconColor: AppColors.purple,
                    title: 'Paylaş',
                    subtitle: 'Doğrulama bağlantısını paylaş',
                    trailingIcon: null,
                    onTap: () => pick(CertificateAction.share),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

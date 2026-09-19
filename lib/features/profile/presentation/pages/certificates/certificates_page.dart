import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sky_app/core/constants/app_colors.dart';
import 'package:sky_app/core/constants/app_icons.dart';
import 'package:sky_app/core/constants/app_paddings.dart';
import 'package:sky_app/core/constants/app_sizes.dart';
import 'package:sky_app/core/extensions/context_extensions.dart';
import 'package:sky_app/core/models/link_item.dart';
import 'package:sky_app/core/services/api_exception.dart';
import 'package:sky_app/core/services/webview_service.dart';
import 'package:sky_app/core/widgets/app_icon.dart';
import 'package:sky_app/core/widgets/sky_button.dart';
import 'package:sky_app/core/widgets/tile_group.dart';
import 'package:sky_app/features/profile/data/models/certificate.dart';
import 'package:sky_app/features/profile/data/services/certificate_service.dart';
import 'package:sky_app/features/profile/presentation/widgets/certificate_tile.dart';

part 'certificates_pagemodel.dart';

/// Kullanıcının katılım sertifikaları. Core sertifikayı etkinliğin katılım
/// kuralına göre veriyor; dokunulan sertifikanın PDF'i açılıyor.
class CertificatesPage extends StatefulWidget {
  const CertificatesPage({super.key});

  @override
  State<CertificatesPage> createState() => _CertificatesPageState();
}

class _CertificatesPageState extends CertificatesPagemodel {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sertifikalar'),
        leading: IconButton(
          icon: const AppIcon(AppIcons.arrowBack),
          onPressed: () => context.pop(),
        ),
      ),
      body: RefreshIndicator.adaptive(onRefresh: onRefresh, child: _body()),
    );
  }

  Widget _body() {
    if (isLoading) {
      return _scrollable(
        const Center(child: CircularProgressIndicator.adaptive()),
      );
    }

    final error = this.error;
    if (error != null && certificates.isEmpty) {
      return _scrollable(
        _message(
          icon: error.isConnectivityIssue ? AppIcons.wifiOff : AppIcons.warning,
          title: 'Sertifikalar Yüklenemedi',
          message: error.userMessage,
          showRetry: true,
        ),
      );
    }

    if (certificates.isEmpty) {
      return _scrollable(
        _message(
          icon: AppIcons.certificate,
          title: 'Henüz Sertifika Yok',
          message:
              'Katıldığın etkinliklerin sertifikaları hazır olduğunda burada '
              'görünecek.',
        ),
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: AppPaddings.mainPaddingAll,
      children: [
        TileGroup(
          children: [
            for (final certificate in certificates)
              CertificateTile(
                certificate: certificate,
                onTap: () => onCertificateTap(certificate),
              ),
          ],
        ),
      ],
    );
  }

  /// Liste dışındaki durumlar da aşağı çekilebilsin diye kaydırılabilir.
  Widget _scrollable(Widget child) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [SliverFillRemaining(hasScrollBody: false, child: child)],
    );
  }

  Widget _message({
    required String icon,
    required String title,
    required String message,
    bool showRetry = false,
  }) {
    return Center(
      child: Padding(
        padding: AppPaddings.mainPaddingAll,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppIcon(
              icon,
              size: AppSizes.iconLarge,
              color: context.textTertiary,
            ),
            const SizedBox(height: AppSizes.bigSpace),
            Text(
              title,
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSizes.smallSpace),
            Text(
              message,
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.textTertiary,
              ),
            ),
            if (showRetry) ...[
              const SizedBox(height: AppSizes.largeSpace),
              SkyButton(text: 'Tekrar Dene', onPressed: onRetry),
            ],
          ],
        ),
      ),
    );
  }
}

import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:sky_app/core/constants/app_icons.dart';
import 'package:sky_app/core/constants/app_paddings.dart';
import 'package:sky_app/core/constants/app_radiuses.dart';
import 'package:sky_app/core/constants/app_sizes.dart';
import 'package:sky_app/core/extensions/context_extensions.dart';
import 'package:sky_app/core/services/api_exception.dart';
import 'package:sky_app/core/services/handoff_service.dart';
import 'package:sky_app/core/widgets/app_icon.dart';
import 'package:sky_app/core/widgets/sky_button.dart';
import 'package:sky_app/features/auth/presentation/providers/user_provider.dart';

part 'handoff_sheetmodel.dart';

/// Bir SKY LAB sitesini (Hesap Merkezi, SKYFORMS) uygulama içinde, tam boy
/// bir sheet'te açar.
///
/// Sheet açılırken [HandoffService] kısa ömürlü bir devir bağlantısı alıyor
/// ve WebView yalnızca onu, kanıt başlığıyla yüklüyor; kullanıcı ikinci kez
/// giriş yapmıyor. Sistem tarayıcısı (Custom Tabs / SFSafariViewController)
/// bilerek kullanılmıyor: sözleşme birinci taraf, adres çubuksuz WebView
/// istiyor (`mobile-web-handoff-contract.md`).
class HandoffSheet extends StatefulWidget {
  const HandoffSheet({super.key, required this.target, this.path = '/'});

  final HandoffTarget target;

  /// Hedef sitede açılacak yol.
  final String path;

  /// Sheet ekranın neredeyse tamamını kaplıyor; içerik bir web sayfası.
  static const double _heightFactor = 0.94;

  static Future<void> show(
    BuildContext context, {
    required HandoffTarget target,
    String path = '/',
  }) {
    return showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      backgroundColor: context.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadiuses.sheetBorderRadius,
      ),
      builder: (_) => FractionallySizedBox(
        heightFactor: _heightFactor,
        child: HandoffSheet(target: target, path: path),
      ),
    );
  }

  @override
  State<HandoffSheet> createState() => _HandoffSheetState();
}

class _HandoffSheetState extends HandoffSheetmodel {
  @override
  Widget build(BuildContext context) {
    // Android'de sistem geri tuşu önce WebView geçmişinde gezsin.
    return PopScope(
      canPop: !canGoBack,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) onBack();
      },
      child: ClipRRect(
        borderRadius: AppRadiuses.sheetBorderRadius,
        child: Column(
          children: [
            _header(),
            Expanded(child: SafeArea(top: false, child: _body())),
          ],
        ),
      ),
    );
  }

  /// Başlık ortada, kapatma solda; sayfa içi gezinme sistem geri tuşunda.
  Widget _header() {
    return Padding(padding: AppPaddings.sheetHeader, child: _titleRow());
  }

  Widget _titleRow() {
    return Row(
      children: [
        IconButton(
          icon: const AppIcon(AppIcons.close),
          onPressed: onClose,
          tooltip: 'Kapat',
        ),
        Expanded(
          child: Text(
            widget.target.label,
            textAlign: TextAlign.center,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        // Başlık tam ortada kalsın diye kapatma butonu kadar boşluk.
        const SizedBox(width: AppSizes.sheetHeaderAction),
      ],
    );
  }

  Widget _body() {
    final error = this.error;
    if (error != null) {
      return _message(
        icon: error.isConnectivityIssue ? AppIcons.wifiOff : AppIcons.warning,
        title: 'Sayfa Açılamadı',
        message: errorDetail ?? error.userMessage,
      );
    }

    if (kIsWeb) {
      return _message(
        icon: AppIcons.browser,
        title: widget.target.label,
        message:
            'Web sürümünde bu sayfa uygulama içinde açılmıyor; tarayıcıdan '
            '${Uri.parse(widget.target.origin).host} adresine git.',
      );
    }

    return Stack(
      children: [
        if (controller != null)
          WebViewWidget(
            controller: controller!,
            // Dokunma hareketlerini kendi alanında doğrudan WebView alıyor;
            // aksi hâlde sheet'in kapanma sürüklemesi kaydırmayı yiyor.
            // Sheet yine sürüklenerek kapanıyor, ama başlıktan.
            gestureRecognizers: {
              Factory<EagerGestureRecognizer>(EagerGestureRecognizer.new),
            },
          ),
        if (isLoading)
          ColoredBox(
            color: context.backgroundColor,
            child: const Center(child: CircularProgressIndicator.adaptive()),
          ),
      ],
    );
  }

  Widget _message({
    required String icon,
    required String title,
    required String message,
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
              textAlign: TextAlign.center,
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
            if (!kIsWeb) ...[
              const SizedBox(height: AppSizes.largeSpace),
              SkyButton(text: 'Tekrar Dene', onPressed: onRetry),
            ],
          ],
        ),
      ),
    );
  }
}

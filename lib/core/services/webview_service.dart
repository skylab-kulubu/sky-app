import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart' as custom_tabs;
import 'package:go_router/go_router.dart';
import 'package:sky_app/core/extensions/context_extensions.dart';
import 'package:sky_app/core/models/link_item.dart';
import 'package:url_launcher/url_launcher.dart';

class WebviewService {
  /// Android'de sheet'in üst köşeleri. Chrome 16'dan büyüğünü kabul etmiyor;
  /// iOS'taki kadar yuvarlak olamıyor, verilebilecek en yuvarlağı bu.
  static const int _sheetCornerRadius = 16;

  /// Bağlantıyı alttan açılan bir tarayıcı sheet'inde açar: Android'de
  /// Partial Custom Tabs, iOS'ta sayfa sheet'i olarak `SFSafariViewController`.
  ///
  /// `webview_flutter` yerine tarayıcı kullanılıyor çünkü girişte oluşan
  /// Keycloak (e-skylab) çerezini paylaşıyor; kulüp siteleri kullanıcıyı
  /// yeniden şifre sormadan içeri alıyor. WebView'un kendi ayrı çerez deposu
  /// var ve oturumu göremiyordu. Bkz. `AuthService._externalUserAgent`.
  ///
  /// Android'de sheet Chrome 107+ istiyor; desteklemeyen tarayıcıda aynı
  /// sekme tam ekran açılıyor. Hiç açılamazsa eski yol, uygulamanın kendi
  /// webview sayfası.
  static Future<void> openLink(BuildContext context, LinkItem link) async {
    final uri = Uri.parse(link.url);

    if (kIsWeb) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }

    try {
      await custom_tabs.launchUrl(
        uri,
        customTabsOptions: _customTabsOptions(context),
        safariVCOptions: _safariOptions(context),
      );
      return;
    } catch (_) {
      // Tarayıcı bulunamadı ya da açılamadı; aşağıda webview'a düşülüyor.
    }

    if (!context.mounted) return;
    context.push('/webview', extra: {'url': link.url, 'title': link.name});
  }

  static custom_tabs.CustomTabsOptions _customTabsOptions(
    BuildContext context,
  ) {
    return custom_tabs.CustomTabsOptions.partial(
      configuration: custom_tabs.PartialCustomTabsConfiguration.bottomSheet(
        // Durum çubuğunun hemen altına kadar; iOS'taki büyük sheet gibi.
        // Oranla verildiğinde (%90) appbar açıkta kalıyor ve sheet ekranın
        // bir parçası gibi değil, üstüne yarım binmiş gibi duruyordu.
        initialHeight:
            MediaQuery.sizeOf(context).height -
            MediaQuery.paddingOf(context).top,
        cornerRadius: _sheetCornerRadius,
      ),
      colorSchemes: custom_tabs.CustomTabsColorSchemes.defaults(
        toolbarColor: context.backgroundColor,
      ),
      showTitle: true,
      // Giriş, varsayılan tarayıcının Custom Tabs'ında yapıldı; çerez orada.
      // Paket kendi hâline bırakılırsa Chrome'u seçebiliyor ve varsayılan
      // tarayıcı başkaysa (Samsung Internet vb.) oturum görünmüyor.
      browser: const custom_tabs.CustomTabsBrowserConfiguration(
        prefersDefaultBrowser: true,
      ),
    );
  }

  static custom_tabs.SafariViewControllerOptions _safariOptions(
    BuildContext context,
  ) {
    return custom_tabs.SafariViewControllerOptions.pageSheet(
      configuration: const custom_tabs.SheetPresentationControllerConfiguration(
        // Yalnızca büyük yükseklik. Orta da verildiğinde iOS sheet'i en
        // küçük yükseklikte, ekranın yarısında açıyordu ve paket açılış
        // yüksekliğini seçtirmiyor (`selectedDetentIdentifier` yok).
        detents: {custom_tabs.SheetPresentationControllerDetent.large},
        prefersGrabberVisible: true,
        prefersScrollingExpandsWhenScrolledToEdge: true,
        prefersEdgeAttachedInCompactHeight: true,
      ),
      // iOS 26+ Liquid Glass yüzünden bu iki renk yok sayılıyor; eski
      // sürümlerde sheet uygulamanın temasında dursun diye veriliyor.
      preferredBarTintColor: context.backgroundColor,
      preferredControlTintColor: context.textPrimary,
      dismissButtonStyle:
          custom_tabs.SafariViewControllerDismissButtonStyle.close,
    );
  }
}

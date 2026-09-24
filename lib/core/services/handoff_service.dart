import 'dart:developer';

import 'package:sky_app/core/services/api_client.dart';
import 'package:sky_app/core/services/api_exception.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Uygulamadan bir SKY LAB sitesine girişli geçiş (web handoff).
///
/// Uygulama kendi Keycloak access token'ıyla kısa ömürlü bir kod alıyor,
/// WebView bu kodu **kanıt başlığıyla** tek bir adres olarak açıyor ve
/// kullanıcı hedef sitede yeniden giriş yapmadan içeri düşüyor.
///
/// Sözleşme: `mobile-web-handoff-contract.md` (WEBLAB, 2026-09-23). Uç
/// Keycloak'ta; 2026-09-24'te canlıya çıktı, eski Hesap Merkezi ucu
/// (`my.yildizskylab.com/v1/native-handoff`) artık hiç çağrılmıyor.
class HandoffTarget {
  const HandoffTarget._(this.id, this.origin, this.label);

  /// Hesap Merkezi: hesap, güvenlik, oturumlar, kulüp profili.
  static const HandoffTarget accountCenter = HandoffTarget._(
    'account-center',
    'https://my.yildizskylab.com',
    'Hesap Merkezi',
  );

  /// SKYFORMS: etkinlik başvuru formları.
  static const HandoffTarget forms = HandoffTarget._(
    'skyforms',
    'https://forms.yildizskylab.com',
    'SkyForms',
  );

  /// Keycloak istemci kimliği; istek gövdesine bu gidiyor.
  final String id;

  /// Hedef sitenin adresi; WebView'de hangi origin'lere izin verileceğini
  /// belirliyor.
  final String origin;

  /// Sheet başlığında görünen ad; site kendi üst çubuğunu çizmiyor.
  final String label;
}

/// Alınan devir bağlantısı ve yalnızca ilk istekte gönderilecek kanıt.
class Handoff {
  const Handoff({required this.url, required this.proof});

  final String url;

  /// `X-Sky-Handoff-Proof` başlığının değeri; yalnız ilk istekte
  /// gönderiliyor, saklanmıyor ve loglanmıyor.
  final String proof;

  Map<String, String> get headers => {'X-Sky-Handoff-Proof': proof};
}

class HandoffService {
  static const String keycloakRealm =
      'https://e.yildizskylab.com/realms/e-skylab';

  static const String _handoffPath = '/sky-handoff/v1/handoffs';

  /// Devir başarısız olursa WebView bu yola gidiyor; uygulama kendi hata
  /// ekranını göstersin diye yakalanıyor.
  static const String failedPath = '/realms/e-skylab/sky-handoff/v1/failed';

  /// Akış sırasında girilebilecek ortak adresler: Keycloak ve YTÜ hesabıyla
  /// doğrulama. Hedefin kendi adresi ayrıca ekleniyor.
  static const Set<String> _commonHosts = {
    'e.yildizskylab.com',
    'login.microsoftonline.com',
  };

  static Set<String> allowedHostsFor(HandoffTarget target) => {
    Uri.parse(target.origin).host,
    ..._commonHosts,
  };

  /// [target] sitesinin [path] sayfası için devir bağlantısı alır.
  ///
  /// Kod 45 saniye geçerli ve tek kullanımlık; her açılışta yeniden
  /// isteniyor. Hatalar [ApiException]: 401 token (yenilemeyi `ApiClient`
  /// yapıyor), 429 oran sınırı, 400 hedef/yol, 5xx geçici.
  Future<Handoff> start(HandoffTarget target, {String path = '/'}) async {
    final response = await ApiClient.instance.dio.post<dynamic>(
      '$keycloakRealm$_handoffPath',
      data: {'target': target.id, 'path': path},
    );
    return _parse(response.data);
  }

  /// [url] hedefin kendi adresindeyse açılacak yolu (sorgu dahil) döner;
  /// başka bir siteyse `null` — o zaman bağlantı tarayıcıda açılıyor.
  static String? pathOf(HandoffTarget target, String url) {
    final uri = Uri.tryParse(url);
    if (uri == null || uri.host != Uri.parse(target.origin).host) return null;
    final path = uri.path.isEmpty ? '/' : uri.path;
    return uri.hasQuery ? '$path?${uri.query}' : path;
  }

  Handoff _parse(Object? body) {
    final url = body is Map ? body['handoffUrl'] : null;
    final proof = body is Map ? body['proof'] : null;
    if (url is! String ||
        !url.startsWith('https://') ||
        proof is! String ||
        proof.isEmpty) {
      throw const ApiException(
        ApiErrorType.server,
        message: 'Devir bağlantısı alınamadı',
      );
    }
    return Handoff(url: url, proof: proof);
  }

  /// Hata sayfasındaki `reason` değerinin Türkçe karşılığı.
  static String failureMessage(String? reason) => switch (reason) {
    'expired' => 'Bağlantının süresi doldu.',
    'used' => 'Bu bağlantı zaten kullanıldı.',
    'invalid' => 'Bağlantı geçersiz.',
    'target_disabled' => 'Bu sayfaya uygulamadan geçiş şu an kapalı.',
    'account_unavailable' => 'Hesabın şu an kullanılamıyor.',
    _ => 'Geçici bir sorun oluştu.',
  };

  /// Çıkışta WebView'de kalan oturumu temizler; sıradaki kullanıcı
  /// öncekinin hesabını görmemeli (sözleşme 6).
  static Future<void> clearWebSession() async {
    try {
      await WebViewCookieManager().clearCookies();
      final controller = WebViewController();
      await controller.clearLocalStorage();
      await controller.clearCache();
    } catch (e) {
      // Web'de ve testlerde platform yok; oturum zaten taşınmıyor.
      log('WebView oturumu temizlenemedi: $e');
    }
  }
}

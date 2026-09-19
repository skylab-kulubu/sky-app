import 'package:sky_app/core/services/core_api.dart';
import 'package:sky_app/features/profile/data/models/skypass_token.dart';

/// SkyPass'in ağ işleri (core `/v1/skypass`): kapı kodu ve öğrenci kartı.
class SkyPassService {
  SkyPassService._();

  /// Son alınan kod ve kime ait olduğu. Kart çevrildikçe ve profil yeniden
  /// açıldıkça her seferinde yeni kod istenmesin diye, süresi dolmadıkça bu
  /// kullanılıyor. Sahibi tutuluyor ki çıkış yapıp başka hesapla girildiğinde
  /// önceki kişinin kodu gösterilmesin.
  static SkyPassToken? _current;
  static String? _currentOwner;
  static Future<SkyPassToken>? _pending;

  /// Kodun bu kadar süresi kalmışsa yenisi alınıyor; görevli okuturken kod
  /// elinde dolmasın.
  static const Duration refreshMargin = Duration(seconds: 10);

  /// [owner]'ın (SKY numarası) geçerli kodunu döndürür; yoksa ya da dolmak
  /// üzereyse yenisini alır. Hatalar `ApiException` olarak fırlıyor.
  static Future<SkyPassToken> token({required String owner}) {
    final current = _current;
    if (current != null &&
        _currentOwner == owner &&
        !current.expiresWithin(refreshMargin)) {
      return Future.value(current);
    }
    return _pending ??= _mint(owner).whenComplete(() => _pending = null);
  }

  static Future<SkyPassToken> _mint(String owner) async {
    final body = await CoreApi.post('/skypass/qr');
    final token = SkyPassToken.fromJson(
      CoreApi.object(body, what: 'SkyPass kodu'),
    );
    _currentOwner = owner;
    return _current = token;
  }

  /// Öğrenci kartının UID'sini hesaba bağlar (varsa eskisinin yerine).
  /// Kart başka bir hesaba bağlıysa core 409 dönüyor.
  static Future<void> bindCard(String uid) async {
    await CoreApi.post('/skypass/card-bind', body: {'uid': uid});
  }
}

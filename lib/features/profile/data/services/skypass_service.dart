import 'package:sky_app/core/services/core_api.dart';
import 'package:sky_app/features/profile/data/models/skypass_token.dart';

/// SkyPass'in ağ işleri (core `/v1/skypass`): kapı kodu ve öğrenci kartı.
class SkyPassService {
  SkyPassService._();

  /// Son alınan kod; dolmadıkça yeniden istenmiyor. Sahibi tutuluyor ki başka
  /// hesapla girilince öncekinin kodu görünmesin.
  static SkyPassToken? _current;
  static String? _currentOwner;
  static Future<SkyPassToken>? _pending;

  /// Bu kadar süresi kalan kod yenileniyor; görevli okuturken dolmasın.
  static const Duration refreshMargin = Duration(seconds: 10);

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

  /// UID'yi hesaba bağlar; kart başka hesaba bağlıysa 409.
  static Future<void> bindCard(String uid) async {
    await CoreApi.post('/skypass/card-bind', body: {'uid': uid});
  }
}

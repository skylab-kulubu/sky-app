import 'package:flutter/foundation.dart';
import 'package:sky_app/core/services/api_client.dart';
import 'package:sky_app/core/services/handoff_service.dart';
import 'package:sky_app/features/auth/data/models/user.dart';
import 'package:sky_app/features/auth/data/services/auth_service.dart';

/// Oturumun durumu.
///
/// `user != null` tek başına yetmiyordu: "oturum yok" ile "sunucuya
/// ulaşılamadı" aynı şeye düşüyor ve çevrimdışı açılan uygulama kullanıcıyı
/// giriş ekranına atıyordu.
enum AuthStatus {
  /// İlk oturum kontrolü sürüyor.
  loading,

  authenticated,

  /// Oturum yok ya da kesin olarak geçersiz.
  unauthenticated,

  /// Oturum bilinmiyor: sunucuya ulaşılamadı. Kayıtlı oturum korunuyor.
  offline,
}

class UserProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  AuthStatus _status = AuthStatus.loading;

  User? get user => _user;
  AuthStatus get status => _status;

  /// İlk oturum kontrolü tamamlandı mı.
  bool get isInitialized => _status != AuthStatus.loading;

  Future<bool> login() async {
    final success = await _authService.login();

    // Web'de tarayıcı Keycloak'a gidiyor; oturum `handleWebAuth` ile geri
    // dönüşte kuruluyor, burada kurulacak bir şey yok.
    if (success && !kIsWeb) {
      _user = await _authService.getUser();
      _status = _user == null
          ? AuthStatus.unauthenticated
          : AuthStatus.authenticated;
      notifyListeners();
    }

    return success;
  }

  /// Profili (`/v1/users/me`) yeniden okur; ör. öğrenci kartı eşlendikten
  /// sonra kartın durumu güncellensin diye. Oturum yoksa bir şey yapmıyor.
  Future<void> reloadProfile() async {
    if (_user == null) return;
    final refreshed = await _authService.getUser();
    if (refreshed == null || _user == null) return;
    _user = refreshed;
    notifyListeners();
  }

  Future<void> logout() async {
    await _authService.logout();
    // Sitelerdeki oturum WebView'de kalmasın; sıradaki kullanıcı öncekinin
    // hesabını görmemeli (web handoff sözleşmesi 6).
    await HandoffService.clearWebSession();
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  /// Kayıtlı oturumu yenileyip kullanıcıyı kurar.
  ///
  /// Splash'te ve çevrimdışı ekranındaki "tekrar dene"de çağrılıyor.
  Future<void> tryAutoLogin() async {
    _status = AuthStatus.loading;
    notifyListeners();

    await _applyOutcome(await _authService.refreshSession());
  }

  Future<void> handleWebAuth(String code) async {
    await _applyOutcome(await _authService.handleWebCallback(code));
  }

  /// Çevrimdışı takılan kullanıcı için çıkış yolu.
  ///
  /// Keycloak'a gitmiyor (bağlantı zaten yok); yalnızca yerel oturumu silip
  /// giriş ekranına düşürüyor.
  Future<void> discardSession() async {
    await _authService.clearSession();
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<void> _applyOutcome(RefreshOutcome outcome) async {
    switch (outcome) {
      case RefreshOutcome.success:
        _user = await _authService.getUser();
        _status = _user == null
            ? AuthStatus.unauthenticated
            : AuthStatus.authenticated;
      case RefreshOutcome.unauthorized:
        _user = null;
        _status = AuthStatus.unauthenticated;
      case RefreshOutcome.networkFailure:
        // Oturum silinmedi; bağlantı gelince yeniden denenebilir.
        _user = null;
        _status = AuthStatus.offline;
    }

    notifyListeners();
  }
}

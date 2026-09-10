import 'dart:convert';
import 'dart:developer';
import 'dart:math' hide log;
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sky_app/core/services/api_client.dart';
import 'package:sky_app/core/services/api_exception.dart';
import 'package:sky_app/features/auth/data/models/user.dart';
import 'package:url_launcher/url_launcher.dart';

/// Keycloak ile konuşan oturum servisi.
///
/// Tek örnek: hem `UserProvider` hem de [ApiClient]'ın token kaynağı aynı
/// nesneyi kullanıyor, böylece yenileme tek yerden yürüyor.
class AuthService implements TokenProvider {
  AuthService._();

  static final AuthService _instance = AuthService._();

  factory AuthService() => _instance;

  final FlutterAppAuth _appAuth = FlutterAppAuth();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// Keycloak istekleri [ApiClient]'tan geçmiyor: yenileme isteğinin kendisi
  /// 401 alsaydı interceptor tekrar yenilemeye girerdi. Timeout'lar yine de
  /// gerekli — yoksa yanıt vermeyen sunucu splash'i süresiz kilitliyor.
  final Dio _authDio = Dio(
    BaseOptions(
      connectTimeout: ApiClient.connectTimeout,
      receiveTimeout: ApiClient.receiveTimeout,
    ),
  );

  static const String _clientId = 'skyapp';
  static const String _redirectUrl = kIsWeb
      ? 'https://app.yildizskylab.com/'
      : 'com.yildizskylab.app:/oauth2redirect';
  static const String _issuer = 'https://e.yildizskylab.com/realms/e-skylab';
  static const List<String> _scopes = [
    'openid',
    'profile',
    'email',
    'offline_access',
  ];

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _idTokenKey = 'id_token';
  static const String _codeVerifierKey = 'code_verifier';

  Future<bool> login() async {
    if (kIsWeb) {
      return await _loginWeb();
    } else {
      return await _loginMobile();
    }
  }

  Future<bool> _loginWeb() async {
    final codeVerifier = _generateCodeVerifier();
    final codeChallenge = _generateCodeChallenge(codeVerifier);

    await _storage.write(key: _codeVerifierKey, value: codeVerifier);

    final authUri = Uri.parse('$_issuer/protocol/openid-connect/auth').replace(
      queryParameters: {
        'response_type': 'code',
        'client_id': _clientId,
        'redirect_uri': _redirectUrl,
        'scope': 'openid profile email offline_access',
        'code_challenge': codeChallenge,
        'code_challenge_method': 'S256',
      },
    );

    return await launchUrl(authUri, webOnlyWindowName: '_self');
  }

  Future<bool> _loginMobile() async {
    try {
      final AuthorizationTokenResponse result = await _appAuth
          .authorizeAndExchangeCode(
            AuthorizationTokenRequest(
              _clientId,
              _redirectUrl,
              issuer: _issuer,
              scopes: _scopes,
            ),
          );

      await _saveTokens(
        result.accessToken,
        result.refreshToken,
        result.idToken,
      );
      return true;
    } on FlutterAppAuthUserCancelledException {
      return false;
    } on FlutterAppAuthPlatformException catch (e) {
      log('Platform error: ${e.platformErrorDetails}');

      return false;
    } catch (e) {
      log('Login error: $e');

      return false;
    }
  }

  /// Web'de `?code=` ile dönen yetkilendirme kodunu token'a çevirir.
  Future<RefreshOutcome> handleWebCallback(String code) async {
    final verifier = await _storage.read(key: _codeVerifierKey);

    try {
      final response = await _authDio.post<dynamic>(
        '$_issuer/protocol/openid-connect/token',
        data: {
          'grant_type': 'authorization_code',
          'client_id': _clientId,
          'code': code,
          'redirect_uri': _redirectUrl,
          'code_verifier': verifier,
        },
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );

      await _saveTokens(
        response.data['access_token'],
        response.data['refresh_token'],
        response.data['id_token'],
      );

      await _storage.delete(key: _codeVerifierKey);
      return RefreshOutcome.success;
    } catch (e) {
      final outcome = _classifyAuthFailure(e);
      log('Web callback hatası ($outcome): $e');

      // Eskimiş bir `?code=` ile açılan sayfa, o an geçerli olan oturumu
      // düşürmemeli. Yalnızca kod kesin olarak reddedildiyse temizleniyor.
      if (outcome == RefreshOutcome.unauthorized) {
        await _storage.delete(key: _codeVerifierKey);
      }
      return outcome;
    }
  }

  @override
  Future<RefreshOutcome> refreshSession() async {
    final storedRefreshToken = await _storage.read(key: _refreshTokenKey);
    if (storedRefreshToken == null) return RefreshOutcome.unauthorized;

    try {
      if (kIsWeb) {
        final response = await _authDio.post<dynamic>(
          '$_issuer/protocol/openid-connect/token',
          data: {
            'grant_type': 'refresh_token',
            'client_id': _clientId,
            'refresh_token': storedRefreshToken,
          },
          options: Options(contentType: Headers.formUrlEncodedContentType),
        );
        await _saveTokens(
          response.data['access_token'],
          response.data['refresh_token'] ?? storedRefreshToken,
          response.data['id_token'],
        );
      } else {
        final TokenResponse result = await _appAuth.token(
          TokenRequest(
            _clientId,
            _redirectUrl,
            issuer: _issuer,
            refreshToken: storedRefreshToken,
            scopes: _scopes,
          ),
        );
        await _saveTokens(
          result.accessToken,
          result.refreshToken ?? storedRefreshToken,
          result.idToken,
        );
      }
      return RefreshOutcome.success;
    } catch (e) {
      final outcome = _classifyAuthFailure(e);
      log('Yenileme hatası ($outcome): $e');

      // Oturum yalnızca kesin reddedilmede siliniyor. Ağ hatasında silinseydi
      // uygulamayı çevrimdışı açan kullanıcı oturumunu kaybederdi.
      if (outcome == RefreshOutcome.unauthorized) await clearSession();
      return outcome;
    }
  }

  /// Yetkilendirme hatasının kalıcı mı geçici mi olduğunu ayırır.
  ///
  /// Kesin ret sayılanlar OAuth 2.0'ın tanımladığı hata kodları; ağ, timeout
  /// ve 5xx geçici kabul edilip oturum korunuyor. Tanımadığımız bir hatada da
  /// oturum korunuyor: gerçekten geçersizse bir sonraki istek zaten 401
  /// döndürüp kullanıcıyı giriş ekranına düşürecek.
  RefreshOutcome _classifyAuthFailure(Object error) {
    if (error is DioException) {
      final apiError = ApiException.fromDio(error);
      if (apiError.isConnectivityIssue) return RefreshOutcome.networkFailure;
      if (_isRejectedGrant(error.response?.data)) {
        return RefreshOutcome.unauthorized;
      }
      // Keycloak geçersiz grant'i 400 ile söylüyor, 401 de kesin ret. Kalan
      // her şey (429, 5xx, tanımsız) geçici kabul edilip oturum korunuyor.
      final status = apiError.statusCode;
      return status == 400 || status == 401
          ? RefreshOutcome.unauthorized
          : RefreshOutcome.networkFailure;
    }

    if (error is FlutterAppAuthPlatformException) {
      return _isRejectedGrantCode(error.platformErrorDetails.error)
          ? RefreshOutcome.unauthorized
          : RefreshOutcome.networkFailure;
    }

    return RefreshOutcome.networkFailure;
  }

  /// Keycloak'ın token uç noktası hatayı gövdedeki `error` alanıyla söylüyor.
  bool _isRejectedGrant(dynamic data) {
    dynamic body = data;
    if (body is String) {
      try {
        body = jsonDecode(body);
      } catch (_) {
        return false;
      }
    }
    return body is Map && _isRejectedGrantCode(body['error']);
  }

  bool _isRejectedGrantCode(Object? code) => const {
    FlutterAppAuthOAuthError.invalidGrant,
    FlutterAppAuthOAuthError.invalidClient,
    FlutterAppAuthOAuthError.unauthorizedClient,
  }.contains(code);

  Future<void> logout() async {
    final idToken = await _storage.read(key: _idTokenKey);
    await clearSession();

    try {
      if (kIsWeb) {
        if (idToken != null) {
          final logoutUri = Uri.parse('$_issuer/protocol/openid-connect/logout')
              .replace(
                queryParameters: {
                  'post_logout_redirect_uri': _redirectUrl,
                  'id_token_hint': idToken,
                },
              );
          await launchUrl(logoutUri, webOnlyWindowName: '_self');
        }
      } else {
        await _appAuth.endSession(
          EndSessionRequest(
            idTokenHint: idToken,
            postLogoutRedirectUrl: _redirectUrl,
            issuer: _issuer,
          ),
        );
      }
    } catch (e) {
      log('Çıkış hatası: $e');
    }
  }

  /// Yerel oturumu siler; Keycloak'a hiç gitmez.
  ///
  /// Çevrimdışıyken kullanıcıyı giriş ekranına döndürmek için gerekli:
  /// [logout] tarayıcı açtığı için bağlantısız çalışmıyor.
  Future<void> clearSession() => _storage.deleteAll();

  Future<void> _saveTokens(String? access, String? refresh, String? id) async {
    await _storage.write(key: _accessTokenKey, value: access);
    await _storage.write(key: _refreshTokenKey, value: refresh);
    await _storage.write(key: _idTokenKey, value: id);
  }

  @override
  Future<String?> readAccessToken() => _storage.read(key: _accessTokenKey);

  /// Oturumdaki kullanıcıyı kurar.
  ///
  /// Roller yalnızca JWT'de olduğu için temel nesne token'dan kuruluyor;
  /// profil API'si erişilebilirse üzerine uygulanıyor. API'ye ulaşılamaması
  /// oturumu geçersiz kılmaz, sadece ek alanlar boş kalır.
  Future<User?> getUser() async {
    final token = await readAccessToken();
    if (token == null) return null;

    final User jwtUser;
    try {
      jwtUser = User.fromJwt(_decodeJwt(token));
    } catch (e) {
      log('JWT çözülemedi: $e');
      return null;
    }

    try {
      final response = await ApiClient.instance.dio.get<dynamic>(
        '/api/users/me',
      );

      dynamic rawData = response.data;
      if (rawData is String) {
        rawData = jsonDecode(rawData);
      }

      if (rawData is Map<String, dynamic>) {
        final data = rawData['data'];
        if (data is Map<String, dynamic>) {
          return jwtUser.mergeWith(User.fromJson(data));
        }
      }
    } catch (e) {
      log('Profil API hatası: $e');
    }

    return jwtUser;
  }

  String _generateCodeVerifier() {
    final random = Random.secure();
    final values = List<int>.generate(32, (i) => random.nextInt(256));
    return base64UrlEncode(
      values,
    ).replaceAll('=', '').replaceAll('+', '-').replaceAll('/', '_');
  }

  String _generateCodeChallenge(String verifier) {
    final bytes = utf8.encode(verifier);
    final digest = sha256.convert(bytes);
    return base64UrlEncode(
      digest.bytes,
    ).replaceAll('=', '').replaceAll('+', '-').replaceAll('/', '_');
  }
}

Map<String, dynamic> _decodeJwt(String token) {
  final parts = token.split('.');
  if (parts.length != 3) throw Exception('Geçersiz JWT');

  String payload = parts[1];
  switch (payload.length % 4) {
    case 2:
      payload += '==';
      break;
    case 3:
      payload += '=';
      break;
  }

  final decoded = utf8.decode(base64Url.decode(payload));
  return jsonDecode(decoded);
}

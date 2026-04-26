import 'dart:convert';
import 'dart:developer';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sky_app/features/auth/data/models/user_model.dart';

class AuthService {
  final FlutterAppAuth _appAuth = FlutterAppAuth();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _clientId = 'skyapp';
  static const String _redirectUrl = 'com.yildizskylab.app:/oauth2redirect';
  static const String _issuer = 'https://e.yildizskylab.com/realms/e-skylab';
  static const List<String> _scopes = [
    'openid',
    'profile',
    'email',
    'offline_access',
  ];

  Future<bool> login() async {
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

      await _storage.write(key: 'access_token', value: result.accessToken);
      await _storage.write(key: 'refresh_token', value: result.refreshToken);
      await _storage.write(key: 'id_token', value: result.idToken);
      return true;
    } on FlutterAppAuthUserCancelledException {
      return false;
    } on FlutterAppAuthPlatformException catch (e) {
      final details = e.details;
      log('Platform error: $details');

      return false;
    } catch (e) {
      log('Login error: $e');

      return false;
    }
  }

  Future<bool> refreshToken() async {
    try {
      final storedRefreshToken = await _storage.read(key: 'refresh_token');
      if (storedRefreshToken == null) return false;

      final TokenResponse result = await _appAuth.token(
        TokenRequest(
          _clientId,
          _redirectUrl,
          issuer: _issuer,
          refreshToken: storedRefreshToken,
          scopes: _scopes,
        ),
      );

      await _storage.write(key: 'access_token', value: result.accessToken);
      if (result.refreshToken != null) {
        await _storage.write(key: 'refresh_token', value: result.refreshToken);
      }

      return true;
    } catch (e) {
      log('Refresh error: $e');

      return false;
    }
  }

  Future<void> logout() async {
    final idToken = await _storage.read(key: 'id_token');
    await _storage.deleteAll();

    try {
      await _appAuth.endSession(
        EndSessionRequest(
          idTokenHint: idToken,
          postLogoutRedirectUrl: _redirectUrl,
          issuer: _issuer,
        ),
      );
    } catch (_) {
      // Logout sırasında hata oluşursa bile token'lar silindiği için kullanıcıyı çıkış yapmış sayıyoruz.
    }
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: 'access_token');
  }

  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'access_token');

    return token != null;
  }

  Future<UserModel?> getUser() async {
    final token = await _storage.read(key: 'access_token');
    if (token == null) return null;

    final payload = _decodeJwt(token);
    return UserModel.fromJwt(payload);
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

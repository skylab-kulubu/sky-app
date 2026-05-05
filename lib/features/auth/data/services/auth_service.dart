import 'dart:convert';
import 'dart:developer';
import 'dart:math' hide log;
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sky_app/features/auth/data/models/user_model.dart';
import 'package:url_launcher/url_launcher.dart';

class AuthService {
  final FlutterAppAuth _appAuth = FlutterAppAuth();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final Dio _dio = Dio();

  static const String _clientId = 'skyapp';
  static const String _redirectUrl = kIsWeb
      ? 'http://localhost:8080/'
      : 'com.yildizskylab.app:/oauth2redirect';
  static const String _issuer = 'https://e.yildizskylab.com/realms/e-skylab';
  static const List<String> _scopes = [
    'openid',
    'profile',
    'email',
    'offline_access',
  ];

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

    await _storage.write(key: 'code_verifier', value: codeVerifier);

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

  Future<bool> handleWebCallback(String code) async {
    final verifier = await _storage.read(key: 'code_verifier');

    try {
      final response = await _dio.post(
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

      await _storage.delete(key: 'code_verifier');
      return true;
    } catch (e) {
      log('Web Callback Hatası: $e');

      await _storage.deleteAll();
      return false;
    }
  }

  Future<bool> refreshToken() async {
    try {
      final storedRefreshToken = await _storage.read(key: 'refresh_token');
      if (storedRefreshToken == null) return false;

      if (kIsWeb) {
        final response = await _dio.post(
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
        return true;
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
          result.refreshToken,
          result.idToken,
        );
        return true;
      }
    } catch (e) {
      log('Refresh error: $e');
      await _storage.deleteAll();
      return false;
    }
  }

  Future<void> logout() async {
    final idToken = await _storage.read(key: 'id_token');
    await _storage.deleteAll();

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
      log('Logout Hatası: $e');
    }
  }

  Future<void> _saveTokens(String? access, String? refresh, String? id) async {
    await _storage.write(key: 'access_token', value: access);
    await _storage.write(key: 'refresh_token', value: refresh);
    await _storage.write(key: 'id_token', value: id);
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

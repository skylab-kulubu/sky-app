import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:sky_app/features/auth/data/models/user_model.dart';
import 'package:sky_app/features/auth/data/services/auth_service.dart';

class UserProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _user;
  bool _isInitialized = false;

  UserModel? get user => _user;
  bool get isInitialized => _isInitialized;

  Future<bool> login() async {
    notifyListeners();
    final success = await _authService.login();
    if (success) {
      _user = await _authService.getUser();
    }
    notifyListeners();
    return success;
  }

  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    notifyListeners();
  }

  Future<void> tryAutoLogin() async {
    try {
      final refreshed = await _authService.refreshToken();
      if (refreshed) {
        _user = await _authService.getUser();
      }
    } catch (e) {
      log('Auto-login error: $e');
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }
}

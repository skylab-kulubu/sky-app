import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:sky_app/core/services/api_exception.dart';
import 'package:sky_app/features/profile/data/models/activity.dart';
import 'package:sky_app/features/profile/data/services/activity_service.dart';

class ActivityProvider extends ChangeNotifier {
  final ActivityService _service = ActivityService();

  List<Activity> _activities = [];
  bool _isLoading = false;
  ApiException? _error;

  /// Listenin kime ait olduğu. Aktiviteler kullanıcıya özel; çıkış yapıp
  /// başka hesapla girildiğinde öncekinin listesi gösterilmemeli.
  String? _loadedUserId;

  List<Activity> get activities => _activities;
  bool get isLoading => _isLoading;

  /// Son yüklemenin hatası; başarılıysa null.
  ApiException? get error => _error;

  /// Elde bu kullanıcının listesi yokken, ilk yükleme sürüyor.
  bool isBusyFor(String userId) =>
      _loadedUserId != userId || (_isLoading && _activities.isEmpty);

  /// Bu kullanıcının listesi elde yoksa yükler, varsa hiçbir şey yapmaz.
  ///
  /// Sayfa her açılışta koşulsuz çağırabilsin diye idempotent.
  Future<void> ensureLoaded(String userId) async {
    if (_loadedUserId == userId && _error == null) return;
    await _load(userId);
  }

  /// Elde ne olursa olsun yeniden yükler; hata satırındaki "tekrar dene".
  Future<void> refresh(String userId) => _load(userId);

  Future<void> _load(String userId) async {
    if (_isLoading) return;

    if (_loadedUserId != userId) _activities = [];
    _loadedUserId = userId;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _activities = await _service.fetchMyActivities();
    } on ApiException catch (e) {
      log('Aktiviteler yüklenemedi: $e');
      _activities = [];
      _error = e;
    }

    _isLoading = false;
    notifyListeners();
  }
}

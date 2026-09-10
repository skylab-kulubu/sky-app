import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:sky_app/core/services/api_exception.dart';
import 'package:sky_app/features/calendar/data/models/event_model.dart';
import 'package:sky_app/features/calendar/data/services/event_service.dart';

class EventProvider extends ChangeNotifier {
  final EventService _eventService = EventService();
  List<EventModel> _events = [];
  List<EventModel> _activeEvents = [];
  bool _isInitialized = false;
  bool _isLoading = false;
  ApiException? _error;

  List<EventModel> get events => _events;
  List<EventModel> get activeEvents => _activeEvents;

  /// Son yüklemenin hatası; başarılıysa null.
  ///
  /// Boş liste artık tek başına bir şey söylemiyor: "etkinlik yok" ile
  /// "yüklenemedi" ayrımını bu alan taşıyor.
  ApiException? get error => _error;
  bool get hasError => _error != null;

  /// Bitişi geçmemiş etkinlikler, en yakın tarihli önce.
  ///
  /// Filtre `active` bayrağına değil tarihe bakıyor; bayrağın anlamı
  /// (başvuruya açık mı, devam ediyor mu) net olmadığı için tarih daha
  /// öngörülebilir bir ölçüt.
  List<EventModel> get upcomingEvents {
    final upcoming = _events.where((event) => event.isUpcoming).toList();
    upcoming.sort((a, b) {
      final aStart = a.startDateTime;
      final bStart = b.startDateTime;
      if (aStart == null || bStart == null) return 0;
      return aStart.compareTo(bStart);
    });
    return upcoming;
  }

  EventModel? get activeEvent {
    for (final event in _activeEvents) {
      if (event.active) return event;
    }
    return null;
  }

  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;

  /// Etkinlikler elde yoksa bir kez yükler, varsa hiçbir şey yapmaz.
  ///
  /// Sayfalar açılışta koşulsuz çağırabilsin diye idempotent: arka arkaya
  /// gelen çağrılar tek bir yüklemeye karşılık gelir. Veriyi hangi sayfanın
  /// tetiklediği önemsiz; ilk gelen yükler, sonrakiler hazır bulur.
  Future<void> ensureLoaded() async {
    if (_isInitialized || _isLoading) return;
    await _load();
  }

  /// Elde ne olursa olsun yeniden yükler; hata ekranındaki "tekrar dene".
  Future<void> refresh() => _load();

  Future<void> _load() async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _events = await _eventService.fetchEvents();
    } on ApiException catch (e) {
      log('Etkinlikler yüklenemedi: $e');
      _events = [];
      _error = e;
    }

    // Ayrı ele alınıyor: bu listeyi şu an hiçbir ekran okumuyor, bu yüzden
    // buradaki hata etkinlik listesini karartmamalı.
    try {
      _activeEvents = await _eventService.fetchActiveEvents();
    } on ApiException catch (e) {
      log('Aktif etkinlikler yüklenemedi: $e');
      _activeEvents = [];
    }

    _isLoading = false;
    _isInitialized = true;
    notifyListeners();
  }

  Future<bool> joinEvent(String eventId) async {
    return await _eventService.joinEvent(eventId);
  }
}

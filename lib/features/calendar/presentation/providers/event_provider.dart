import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:sky_app/core/services/api_exception.dart';
import 'package:sky_app/features/calendar/data/models/event_model.dart';
import 'package:sky_app/features/calendar/data/services/event_service.dart';

class EventProvider extends ChangeNotifier {
  final EventService _eventService = EventService();
  List<EventModel> _events = [];
  bool _isInitialized = false;
  bool _isLoading = false;
  ApiException? _error;

  List<EventModel> get events => _events;

  /// Son yüklemenin hatası: "etkinlik yok" ile "yüklenemedi" ayrımı bu. Yükleme
  /// sürerken önceki değerinde kalıyor; yoksa yenilemede hata ekranı bir anlık
  /// boş duruma dönüyordu.
  ApiException? get error => _error;
  bool get hasError => _error != null;

  /// Bitişi geçmemiş yayındaki etkinlikler, en yakın önce; `active` yerine
  /// tarih, daha öngörülebilir. Taslak ve iptal edilen yalnız Etkinlikler
  /// sekmesinde, etiketiyle.
  List<EventModel> get upcomingEvents {
    final upcoming = _events
        .where((e) => e.isUpcoming && !e.isDraft && !e.isCancelled)
        .toList();
    upcoming.sort((a, b) {
      final aStart = a.startDateTime;
      final bStart = b.startDateTime;
      if (aStart == null || bStart == null) return 0;
      return aStart.compareTo(bStart);
    });
    return upcoming;
  }

  String _searchQuery = '';

  /// Etkinlikler sekmesindeki arama kutusunun metni; boşsa arama yok.
  String get searchQuery => _searchQuery;

  void setSearchQuery(String query) {
    final trimmed = query.trim();
    if (trimmed == _searchQuery) return;
    _searchQuery = trimmed;
    notifyListeners();
  }

  /// Ad, konum ve tür satırında aranıyor; açıklamadaki tek kelime alakasız
  /// sonuçlar getiriyordu.
  List<EventModel> get searchedEvents {
    if (_searchQuery.isEmpty) return _events;

    final needle = _normalize(_searchQuery);
    return _events
        .where(
          (event) => [
            event.name,
            event.location,
            event.ownerTeam,
            event.ownerLabel,
          ].any((field) => _normalize(field).contains(needle)),
        )
        .toList();
  }

  /// Büyük/küçük harf ve i/ı farkını yok sayar; `toLowerCase` Türkçeyi bilmiyor
  /// ("İ" → "i̇").
  static String _normalize(String value) => value
      .replaceAll('İ', 'i')
      .replaceAll('I', 'i')
      .toLowerCase()
      .replaceAll('ı', 'i');

  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;

  /// Süren yükleme; aynı anda gelen çağrılar bunu paylaşır.
  Future<void>? _inFlight;

  /// Elde yoksa bir kez yükler; sayfalar açılışta koşulsuz çağırabilsin diye
  /// idempotent.
  Future<void> ensureLoaded() async {
    if (_isInitialized) return;
    await _load();
  }

  /// Her durumda yeniden yükler (aşağı çekme, "tekrar dene").
  Future<void> refresh() => _load();

  /// Süren yükleme varsa onu döndürür; erken `return` aşağı çekme göstergesini
  /// veri gelmeden kapatıyordu.
  Future<void> _load() => _inFlight ??= _run();

  Future<void> _run() async {
    _isLoading = true;
    notifyListeners();

    ApiException? error;

    try {
      _events = await _eventService.fetchEvents();
    } on ApiException catch (e) {
      log('Etkinlikler yüklenemedi: $e');
      // Eldeki liste korunuyor: ağ koptu diye ekrandaki etkinlikler kaybolmamalı.
      error = e;
    } catch (e) {
      // Beklenmeyen hata da sayfayı yükleniyor durumunda bırakmamalı.
      log('Etkinlikler işlenemedi: $e');
      error = const ApiException(
        ApiErrorType.server,
        message: 'Etkinlikler işlenemedi',
      );
    } finally {
      _error = error;
      _isLoading = false;
      _isInitialized = true;
      _inFlight = null;
      notifyListeners();
    }
  }

  Future<JoinResult> joinEvent(String eventId) =>
      _eventService.joinEvent(eventId);
}

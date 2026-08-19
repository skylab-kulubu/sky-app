import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:sky_app/features/calendar/data/models/event_model.dart';
import 'package:sky_app/features/calendar/data/services/event_service.dart';

class EventProvider extends ChangeNotifier {
  final EventService _eventService = EventService();
  List<EventModel> _events = [];
  List<EventModel> _activeEvents = [];
  bool _isInitialized = false;
  bool _isLoading = false;

  List<EventModel> get events => _events;
  List<EventModel> get activeEvents => _activeEvents;

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
  /// gelen çağrılar tek bir isteğe karşılık gelir. Veriyi hangi sayfanın
  /// tetiklediği önemsiz; ilk gelen yükler, sonrakiler hazır bulur.
  ///
  /// İki istek sırayla: `fetchEvents` ve `fetchActiveEvents` aynı
  /// [_isLoading] bayrağını paylaşıyor ve ikisi de bayrak kalkıkken erken
  /// dönüyor. Paralel başlatılırsa ikincisi sessizce hiç çalışmaz.
  Future<void> ensureLoaded() async {
    if (_isInitialized || _isLoading) return;
    await fetchEvents();
    await fetchActiveEvents();
  }

  Future<void> fetchEvents({bool forceRefresh = false}) async {
    if (_isLoading) return;
    if (_events.isNotEmpty && !forceRefresh) {
      _isInitialized = true;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _events = await _eventService.fetchEvents();
    } catch (e) {
      log('Event fetch error: $e');
      _events = [];
    } finally {
      _isLoading = false;
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> fetchActiveEvents({bool forceRefresh = false}) async {
    if (_isLoading) return;
    if (_activeEvents.isNotEmpty && !forceRefresh) {
      _isInitialized = true;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _activeEvents = await _eventService.fetchActiveEvents();
    } catch (e) {
      log('Active event fetch error: $e');
      _activeEvents = [];
    } finally {
      _isLoading = false;
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<bool> joinEvent(String eventId) async {
    return await _eventService.joinEvent(eventId);
  }
}

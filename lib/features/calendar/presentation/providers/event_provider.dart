import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:sky_app/features/calendar/data/models/event_model.dart';
import 'package:sky_app/features/calendar/data/services/event_service.dart';

class EventProvider extends ChangeNotifier {
  final EventService _eventService = EventService();
  List<EventModel> _events = [];
  bool _isInitialized = false;
  bool _isLoading = false;

  List<EventModel> get events => _events;

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

  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;

  /// Etkinlikler elde yoksa bir kez yükler, varsa hiçbir şey yapmaz.
  ///
  /// Sayfalar açılışta koşulsuz çağırabilsin diye idempotent: arka arkaya
  /// gelen çağrılar tek bir isteğe karşılık gelir. Veriyi hangi sayfanın
  /// tetiklediği önemsiz; ilk gelen yükler, sonrakiler hazır bulur.
  ///
  Future<void> ensureLoaded() async {
    if (_isInitialized || _isLoading) return;
    await fetchEvents();
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

  Future<bool> joinEvent(String eventId) async {
    return await _eventService.joinEvent(eventId);
  }
}

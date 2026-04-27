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
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;

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
}
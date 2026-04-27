import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:sky_app/features/calendar/data/models/event_model.dart';

class EventService {
  static const String _apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://e.yildizskylab.com',
  );
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: _apiBaseUrl,
      headers: const {'Accept': 'application/json'},
    ),
  );
  static List<EventModel>? _cache;

  static Future<void> prefetch() async {
    _cache = await _fetch();
  }

  static Future<List<EventModel>> fetchEvents() async {
    if (_cache != null) return _cache!;
    _cache = await _fetch();
    return _cache!;
  }

  static Future<List<EventModel>> _fetch() async {
    try {
      final response = await _dio.get<dynamic>('/api/events');
      dynamic rawData = response.data;
      if (rawData is String) {
        rawData = jsonDecode(rawData);
      }

      if (rawData is! Map<String, dynamic>) {
        return [];
      }

      final data = rawData['data'];
      if (data is! List) {
        return [];
      }

      return data
          .whereType<Map<String, dynamic>>()
          .map(EventModel.fromJson)
          .toList(growable: false);
    } catch (e) {
      return [];
    }
  }
}

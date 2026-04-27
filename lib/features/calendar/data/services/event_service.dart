import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:sky_app/features/calendar/data/models/event_model.dart';

class EventService {
  static const String _apiBaseUrl = 'https://api.yildizskylab.com';
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: _apiBaseUrl,
      headers: const {'Accept': 'application/json'},
    ),
  );

  Future<List<EventModel>> fetchEvents() async {
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

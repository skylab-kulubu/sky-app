import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:sky_app/features/auth/data/services/auth_service.dart';
import 'package:sky_app/features/calendar/data/models/event_model.dart';

class EventService {
  late AuthService _authService;
  static const String _apiBaseUrl = 'https://api.yildizskylab.com';
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: _apiBaseUrl,
      headers: const {'Accept': 'application/json'},
    ),
  );

  Future<List<EventModel>> fetchEvents() async {
    return _fetchEvents('/api/events');
  }

  Future<List<EventModel>> fetchActiveEvents() async {
    return _fetchEvents('/api/events/active');
  }

  Future<List<EventModel>> _fetchEvents(String path) async {
    try {
      final response = await _dio.get<dynamic>(path);
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

  Future<bool> joinEvent(String eventId) async {
    _authService = AuthService();
    final token = await _authService.getAccessToken();
    try {
      await _dio.post(
        '/api/events/$eventId/applications/me',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return true;
    } catch (e) {
      log('Error joining event: $e');
      return false;
    }
  }
}

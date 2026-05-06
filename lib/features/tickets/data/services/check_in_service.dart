import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:sky_app/features/auth/data/services/auth_service.dart';
import 'package:sky_app/features/calendar/data/services/event_service.dart';
import 'package:sky_app/features/tickets/data/models/event_day_model.dart';

class CheckInService {
  static const String _apiBaseUrl = 'https://api.yildizskylab.com';

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: _apiBaseUrl,
      headers: const {'Accept': 'application/json'},
    ),
  );

  final AuthService _authService = AuthService();
  final EventService _eventService = EventService();

  Future<bool> checkIn({
    required String ticketId,
    required String eventDayId,
  }) async {
    try {
      final token = await _authService.getAccessToken();
      if (token == null) return false;

      await _dio.post<dynamic>(
        '/api/tickets/$ticketId/event-days/$eventDayId/check-in',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      return true;
    } on DioException catch (e) {
      log('CheckIn error: ${e.message}');
      return false;
    } catch (e) {
      log('CheckIn error: $e');
      return false;
    }
  }

  Future<List<EventDayModel>> fetchEventDays() async {
    try {
      final token = await _authService.getAccessToken();
      if (token == null) return [];

      final activeEvents = await _eventService.fetchActiveEvents();
      final activeEvent = activeEvents.firstOrNull;
      if (activeEvent == null) return [];

      final response = await _dio.get<dynamic>(
        'api/event-days/event/${activeEvent.id}',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      dynamic rawData = response.data;

      if (rawData is String) {
        rawData = jsonDecode(rawData);
      }

      if (rawData is! Map<String, dynamic>) return [];

      final data = rawData['data'];
      if (data is! List) return [];

      return data
          .whereType<Map<String, dynamic>>()
          .map(EventDayModel.fromJson)
          .toList(growable: false);
    } on DioException catch (e) {
      log('Tickets fetch error: ${e.message}');
      return [];
    } catch (e) {
      log('Tickets fetch error: $e');
      return [];
    }
  }
}

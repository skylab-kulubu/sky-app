import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:sky_app/features/auth/data/services/auth_service.dart';
import 'package:sky_app/features/tickets/data/models/ticket_model.dart';

class TicketsService {
  static const String _apiBaseUrl = 'https://api.yildizskylab.com';

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: _apiBaseUrl,
      headers: const {'Accept': 'application/json'},
    ),
  );

  final AuthService _authService = AuthService();

  Future<List<TicketModel>> fetchMyTickets() async {
    try {
      final token = await _authService.getAccessToken();
      if (token == null) return [];

      final response = await _dio.get<dynamic>(
        '/api/tickets/me',
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
          .map(TicketModel.fromJson)
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

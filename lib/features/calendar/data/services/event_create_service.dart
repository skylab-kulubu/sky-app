import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sky_app/core/services/api_client.dart';
import 'package:sky_app/core/services/api_exception.dart';
import 'package:sky_app/features/calendar/data/models/event_model.dart';
import 'package:sky_app/features/calendar/data/models/season.dart';

/// Etkinlik oluşturma, düzenleme ve silmenin ağ işleri: sezon listesi,
/// kapak yükleme, kayıt, güncelleme, silme.
///
/// Yetki OPA'da: sahip ekipte lider (GECEKODU'da üye) ya da YK/DK/ADMIN
/// olmayan kullanıcının isteği 403 ile reddediliyor.
class EventCreateService {
  final Dio _dio = ApiClient.instance.dio;

  /// Bütün sezonlar; girişsiz okunuyor. Etkinlik oluştururken sezon zorunlu.
  Future<List<Season>> fetchSeasons() async {
    final data = await _unwrap(() => _dio.get<dynamic>('/api/seasons'));
    if (data is! List) {
      throw const ApiException(
        ApiErrorType.server,
        message: 'Yanıtta sezon listesi yok',
      );
    }
    return data
        .whereType<Map<String, dynamic>>()
        .map(Season.fromJson)
        .where((season) => season.id.isNotEmpty)
        .toList(growable: false);
  }

  /// Kapak görselini yükler ve medya id'sini döner. Backend yalnızca görsel
  /// dosyalarını kabul ediyor; alan adı `file`.
  Future<String> uploadCover(XFile image) async {
    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(image.path, filename: image.name),
    });

    final data = await _unwrap(
      () => _dio.post<dynamic>('/api/media', data: form),
    );
    final id = data is Map<String, dynamic> ? data['id'] as String? : null;
    if (id == null || id.isEmpty) {
      throw const ApiException(
        ApiErrorType.server,
        message: 'Yüklenen görselin kimliği dönmedi',
      );
    }
    return id;
  }

  /// Etkinliği oluşturur ve oluşturulan hâlini döner.
  ///
  /// İstek JSON değil multipart: veri `data` adlı parçada, JSON içerik
  /// tipiyle gidiyor (`@RequestPart("data")`). Tarihler saat dilimsiz
  /// (`LocalDateTime`), cihazın yerel saatiyle yazılıyor.
  Future<EventModel> createEvent({
    required String name,
    required String location,
    required String ownerTeam,
    required String seasonId,
    required DateTime startDate,
    required DateTime endDate,
    required bool active,
    String description = '',
    String? coverImageId,
    String formUrl = '',
    String linkedin = '',
    int capacity = 0,
  }) async {
    final payload = {
      'name': name,
      'location': location,
      'ownerTeam': ownerTeam,
      'seasonId': seasonId,
      'startDate': _localDateTime(startDate),
      'endDate': _localDateTime(endDate),
      'active': active,
      'description': description,
      'coverImageId': ?coverImageId,
      'formUrl': formUrl,
      'linkedin': linkedin,
      'capacity': capacity,
    };

    final form = FormData.fromMap({
      'data': MultipartFile.fromString(
        jsonEncode(payload),
        contentType: DioMediaType('application', 'json'),
      ),
    });

    final data = await _unwrap(
      () => _dio.post<dynamic>('/api/events', data: form),
    );
    if (data is! Map<String, dynamic>) {
      throw const ApiException(
        ApiErrorType.server,
        message: 'Oluşturulan etkinlik dönmedi',
      );
    }
    return EventModel.fromJson(data);
  }

  /// Etkinliği günceller (`PATCH`, düz JSON) ve güncel hâlini döner.
  ///
  /// Kapak ve kontenjan güncelleme isteğinde yok; backend yalnızca
  /// oluştururken alıyor.
  Future<EventModel> updateEvent(
    String id, {
    required String name,
    required String location,
    required String ownerTeam,
    required String seasonId,
    required DateTime startDate,
    required DateTime endDate,
    required bool active,
    required String description,
    required String formUrl,
    required String linkedin,
  }) async {
    final data = await _unwrap(
      () => _dio.patch<dynamic>(
        '/api/events/$id',
        data: {
          'name': name,
          'location': location,
          'ownerTeam': ownerTeam,
          'seasonId': seasonId,
          'startDate': _localDateTime(startDate),
          'endDate': _localDateTime(endDate),
          'active': active,
          'description': description,
          'formUrl': formUrl,
          'linkedin': linkedin,
        },
      ),
    );
    if (data is! Map<String, dynamic>) {
      throw const ApiException(
        ApiErrorType.server,
        message: 'Güncellenen etkinlik dönmedi',
      );
    }
    return EventModel.fromJson(data);
  }

  /// Etkinliği siler. Bilet alınmış ya da günü tanımlanmış etkinliği
  /// backend 400 ile reddediyor.
  Future<void> deleteEvent(String id) async {
    await _unwrap(() => _dio.delete<dynamic>('/api/events/$id'));
  }

  /// `2026-09-20T18:00:00`: saniyeli, saat dilimsiz.
  static String _localDateTime(DateTime value) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${value.year}-${two(value.month)}-${two(value.day)}'
        'T${two(value.hour)}:${two(value.minute)}:00';
  }

  /// İsteği atar, `{data: ...}` zarfını açar.
  Future<Object?> _unwrap(Future<Response<dynamic>> Function() request) async {
    final Response<dynamic> response;
    try {
      response = await request();
    } catch (e) {
      throw ApiException.from(e);
    }

    dynamic body = response.data;
    if (body is String) {
      try {
        body = jsonDecode(body);
      } catch (_) {
        throw const ApiException(
          ApiErrorType.server,
          message: 'Yanıt çözümlenemedi',
        );
      }
    }
    return body is Map<String, dynamic> ? body['data'] : null;
  }
}

import 'package:sky_app/core/services/api_client.dart';
import 'package:sky_app/core/services/core_api.dart';
import 'package:sky_app/features/calendar/data/models/event_session.dart';
import 'package:sky_app/features/calendar/data/services/event_service.dart';

/// Katılımcının oturumda perdede gösterilen QR'ı okutup kendi yoklamasını
/// vermesi (core). Görevlinin kapıda giriş alması [DoorService]'te.
class AttendanceService {
  final EventService _events = EventService();

  static final RegExp _uuid = RegExp(
    r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
    caseSensitive: false,
  );

  /// Oturum QR'ındaki oturum id'si. Core QR'a oturumun adresini yazıyor
  /// (`https://api.yildizskylab.com/v1/sessions/{id}`); başka bir kodsa
  /// `null`.
  static String? sessionIdFromQr(String raw) {
    final uri = Uri.tryParse(raw.trim());
    if (uri == null ||
        uri.scheme != 'https' ||
        uri.host != Uri.parse(ApiClient.baseUrl).host) {
      return null;
    }
    final segments = uri.pathSegments;
    if (segments.length != 3 ||
        segments[0] != 'v1' ||
        segments[1] != 'sessions' ||
        !_uuid.hasMatch(segments[2])) {
      return null;
    }
    return segments[2].toLowerCase();
  }

  /// Oturumun kendisi (`GET /v1/sessions/{id}`, herkese açık); 404 oturum
  /// yok.
  Future<EventSession> fetchSession(String sessionId) async {
    final body = await CoreApi.get('/sessions/$sessionId');
    return EventSession.fromJson(CoreApi.object(body, what: 'oturum'));
  }

  /// Oturuma kendi girişini yazar (`POST /v1/sessions/{id}/check-in/me`).
  /// Hatalar `ApiException`: 409 zaten katılmış, 404 bu etkinlikte kaydı
  /// yok.
  Future<void> checkIn(String sessionId) =>
      CoreApi.post('/sessions/$sessionId/check-in/me');

  /// Oturumun ait olduğu etkinliğin adı (gün → etkinlik). Yalnızca sonucu
  /// göstermek için; alınamazsa boş.
  Future<String> eventName(EventSession session) async {
    try {
      final day = EventDay.fromJson(
        CoreApi.object(
          await CoreApi.get('/event-days/${session.dayId}'),
          what: 'etkinlik günü',
        ),
      );
      return (await _events.fetchEvent(day.eventId)).name;
    } catch (_) {
      return '';
    }
  }
}

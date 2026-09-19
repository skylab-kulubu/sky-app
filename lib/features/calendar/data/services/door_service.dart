import 'dart:convert';

import 'package:sky_app/core/services/core_api.dart';
import 'package:sky_app/features/calendar/data/models/event_session.dart';
import 'package:sky_app/features/calendar/data/services/schedule_service.dart';

/// Kapıda okutulan kodun sahibi; QR'daki imzalı belirtecin içinden okunuyor.
/// Doğrulama sunucuda (check-in isteğinde) yapılıyor, bu yalnızca ekranda
/// kimin girdiğini göstermek için.
class DoorHolder {
  const DoorHolder({required this.name, required this.skyNumber});

  final String name;
  final String skyNumber;
}

/// Kapı okuyucusunun ağ işleri (core): etkinliğin günleri ve oturumları,
/// SkyPass ile giriş.
class DoorService {
  final ScheduleService _schedule = ScheduleService();

  /// Etkinliğin iptal edilmemiş bütün oturumları, günleriyle birlikte;
  /// programdaki sırayla.
  Future<List<({EventDay day, EventSession session})>> fetchSessions(
    String eventId,
  ) async {
    final schedule = await _schedule.fetchSchedule(eventId);
    return [
      for (final entry in schedule)
        for (final session in entry.sessions)
          if (!session.cancelled) (day: entry.day, session: session),
    ];
  }

  /// SkyPass QR'ı ile oturuma giriş. Hatalar `ApiException`: 409 zaten
  /// girmiş, 404 bu etkinlikte kaydı yok, 401 kodun süresi dolmuş ya da
  /// imza geçersiz, 403 okutma yetkisi yok.
  Future<void> checkInWithPass(String sessionId, String token) async {
    await CoreApi.post(
      '/sessions/$sessionId/check-in/skypass',
      body: {'token': token},
    );
  }

  /// Öğrenci kartıyla (NFC UID) oturuma giriş. Kart kimseye eşli değilse ya
  /// da kişinin bu etkinlikte bileti yoksa 404; diğerleri QR ile aynı.
  Future<void> checkInWithCard(String sessionId, String uid) async {
    await CoreApi.post(
      '/sessions/$sessionId/check-in/skypass',
      body: {'uid': uid},
    );
  }

  /// Kartın sahibinin adı ve SKY numarası. Core bu sorguyu yalnızca
  /// YK/DK/ADMIN'e açıyor; diğer görevlilerde `null` dönüyor ve giriş adsız
  /// gösteriliyor.
  Future<DoorHolder?> cardHolder(String uid) async {
    try {
      final body = CoreApi.object(
        await CoreApi.get('/skypass/card', query: {'uid': uid}),
        what: 'kart sahibi',
      );
      final name = [
        body['firstName'] as String? ?? '',
        body['lastName'] as String? ?? '',
      ].where((p) => p.isNotEmpty).join(' ');
      return DoorHolder(
        name: name,
        skyNumber: body['skyNumber'] as String? ?? '',
      );
    } catch (_) {
      return null;
    }
  }

  /// Okunan QR'daki SkyPass belirtecinden ad ve SKY numarası; SkyPass
  /// değilse `null`.
  static DoorHolder? holderFrom(String raw) {
    final parts = raw.trim().split('.');
    if (parts.length != 3) return null;
    try {
      final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );
      if (payload is! Map<String, dynamic> || payload['iss'] != 'skypass') {
        return null;
      }
      return DoorHolder(
        name: payload['name'] as String? ?? '',
        skyNumber: payload['skyNumber'] as String? ?? '',
      );
    } catch (_) {
      return null;
    }
  }
}

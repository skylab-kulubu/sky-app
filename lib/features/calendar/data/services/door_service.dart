import 'dart:convert';

import 'package:sky_app/core/services/core_api.dart';
import 'package:sky_app/features/calendar/data/models/event_model.dart';
import 'package:sky_app/features/calendar/data/models/event_session.dart';
import 'package:sky_app/features/calendar/data/services/schedule_service.dart';

/// Kapıdaki bir girişin sonucu: kimin girdiği ve oturumdaki toplam giriş.
class DoorCheckIn {
  const DoorCheckIn({required this.personName, required this.total});

  /// Girenin adı; bulunamazsa boş.
  final String personName;

  /// Oturumda şimdiye kadar alınan giriş sayısı; bilinmiyorsa `null`.
  final int? total;
}

/// Kapıda giriş almanın ağ işleri (core): görevlinin etkinlikleri,
/// oturumlar, SkyPass/öğrenci kartıyla giriş ve oturumun giriş kaydı.
class DoorService {
  final ScheduleService _schedule = ScheduleService();

  /// Kullanıcının kapıda giriş alabildiği etkinlikler
  /// (`GET /v1/door/events`). Yetkiyi core hesaplıyor; grubunda
  /// `team_door_scan` açık ekiplerin üyeleri de dahil.
  Future<List<EventModel>> fetchDoorEvents() async {
    final body = await CoreApi.get('/door/events');
    return CoreApi.list(
      body,
      what: 'kapı etkinlikleri',
    ).map(EventModel.fromJson).where((e) => e.id.isNotEmpty).toList();
  }

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

  /// SkyPass QR'ı (`{token}`) ya da öğrenci kartıyla (`{uid}`) oturuma
  /// giriş; ardından girenin adını oturumun giriş kaydından alıyor.
  ///
  /// Hatalar `ApiException`: 409 zaten girmiş, 404 bu etkinlikte kaydı yok
  /// (kartta: kart eşli değil de olabilir), 401 kodun süresi dolmuş ya da
  /// imza geçersiz, 403 giriş alma yetkisi yok.
  Future<DoorCheckIn> checkIn(
    String sessionId, {
    String? token,
    String? uid,
  }) async {
    final created = CoreApi.object(
      await CoreApi.post(
        '/sessions/$sessionId/check-in/skypass',
        body: {'token': ?token, 'uid': ?uid},
      ),
      what: 'giriş',
    );
    return _describe(sessionId, created['id'] as String? ?? '');
  }

  /// Oturumun son girişlerinde bu girişi bulup adı döndürür. SkyPass kodu
  /// kişinin adını taşımıyor, kart sorgusu ise yalnızca YK/DK/ADMIN'e açık;
  /// giriş kaydı (`GET /v1/sessions/{id}/check-ins`) her görevliye açık.
  /// Alınamazsa adsız dönüyor, giriş yine de alınmış sayılıyor.
  Future<DoorCheckIn> _describe(String sessionId, String checkInId) async {
    try {
      final activity = await sessionActivity(sessionId);
      return DoorCheckIn(
        personName: activity.names[checkInId] ?? '',
        total: activity.total,
      );
    } catch (_) {
      return const DoorCheckIn(personName: '', total: null);
    }
  }

  /// Oturumdaki toplam giriş ve son girişlerin adları (giriş id'sine göre).
  Future<({int total, Map<String, String> names})> sessionActivity(
    String sessionId,
  ) async {
    final body = CoreApi.object(
      await CoreApi.get('/sessions/$sessionId/check-ins'),
      what: 'giriş kaydı',
    );
    final items = body['items'] as List<dynamic>? ?? const [];
    return (
      total: (body['total'] as num?)?.toInt() ?? items.length,
      names: {
        for (final item in items.whereType<Map<String, dynamic>>())
          if (item['id'] is String)
            item['id'] as String: (item['personName'] as String? ?? '').trim(),
      },
    );
  }

  /// QR'dan okunan değer SkyPass kodu mu: ES256 imzalı, konusu (`sub`)
  /// kullanıcı id'si olan bir belirteç. Asıl doğrulama sunucuda; bu yalnızca
  /// alakasız QR'ları (web adresi, bilet vb.) sunucuya göndermemek için.
  static bool isSkyPassToken(String raw) {
    final parts = raw.trim().split('.');
    if (parts.length != 3) return false;
    try {
      final header = _decodePart(parts[0]);
      final payload = _decodePart(parts[1]);
      return header['alg'] == 'ES256' &&
          payload['sub'] is String &&
          (payload['sub'] as String).isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  static Map<String, dynamic> _decodePart(String part) {
    final decoded = jsonDecode(
      utf8.decode(base64Url.decode(base64Url.normalize(part))),
    );
    return decoded is Map<String, dynamic> ? decoded : const {};
  }
}

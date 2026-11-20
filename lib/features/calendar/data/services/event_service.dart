import 'dart:developer';

import 'package:sky_app/core/services/api_exception.dart';
import 'package:sky_app/core/services/core_api.dart';
import 'package:sky_app/features/calendar/data/models/event_model.dart';

/// Etkinlik okuma ve katılma (core `/v1/events`).
class EventService {
  /// Tek etkinlik (girişsiz); bağlantıyla açılan detay sayfası için.
  /// Bulunamazsa `notFound` tipinde [ApiException].
  Future<EventModel> fetchEvent(String id) async {
    final body = await CoreApi.get('/events/$id');
    return EventModel.fromJson(CoreApi.object(body, what: 'etkinlik'));
  }

  /// Bütün etkinlikler. Girişsiz istekte core yalnızca aktifleri dönüyor;
  /// oturum açıkken hepsi geliyor.
  ///
  /// Hatayı yutmuyor: "etkinlik yok" ile "yüklenemedi" ayrımını çağıran
  /// [ApiException] üzerinden yapıyor.
  Future<List<EventModel>> fetchEvents() async {
    final body = await CoreApi.get('/events');
    return CoreApi.list(
      body,
      what: 'etkinlik listesi',
    ).map(EventModel.fromJson).toList(growable: false);
  }

  /// Üye başvurusu: giriş yapmış kullanıcıya bilet oluşturur (201).
  ///
  /// Core'un 409'ları `code` ile ayrılıyor (`internal/handlers/tickets.go`):
  /// kodsuz 409 zaten bileti olduğu anlamına geliyor ve başarı sayılıyor;
  /// `registration_closed` başvuru kapanmış (elle, son tarihle ya da
  /// etkinlik bitmiş), `event_cancelled` iptal, `event_not_published`
  /// taslak.
  Future<JoinResult> joinEvent(String eventId) async {
    try {
      await CoreApi.post('/events/$eventId/applications/me');
      return JoinResult.joined;
    } on ApiException catch (e) {
      log('Etkinliğe katılma hatası: $e');
      if (e.statusCode != 409) return JoinResult.failed;
      return switch (e.code) {
        null || '' => JoinResult.alreadyJoined,
        'registration_closed' => JoinResult.registrationClosed,
        'event_cancelled' => JoinResult.cancelled,
        _ => JoinResult.failed,
      };
    }
  }
}

/// [EventService.joinEvent] sonucu.
enum JoinResult {
  joined,
  alreadyJoined,
  registrationClosed,
  cancelled,
  failed;

  /// Bilet var mı (yeni ya da önceden).
  bool get hasTicket => this == joined || this == alreadyJoined;

  /// Kullanıcıya gösterilen kısa mesaj.
  String get message => switch (this) {
    joined => 'Kaydın başarıyla alındı!',
    alreadyJoined => 'Bu etkinliğe zaten kaydın var.',
    registrationClosed => 'Bu etkinliğin başvuruları kapandı.',
    cancelled => 'Bu etkinlik iptal edildi.',
    failed => 'Katılım kaydı oluşturulamadı.',
  };
}

import 'dart:developer';

import 'package:sky_app/core/services/api_exception.dart';
import 'package:sky_app/core/services/core_api.dart';
import 'package:sky_app/features/calendar/data/models/event_model.dart';

class EventService {
  /// Tek etkinlik (girişsiz); bağlantıyla açılan detay sayfası için.
  /// Bulunamazsa `notFound` tipinde [ApiException].
  Future<EventModel> fetchEvent(String id) async {
    final body = await CoreApi.get('/events/$id');
    return EventModel.fromJson(CoreApi.object(body, what: 'etkinlik'));
  }

  /// Girişsiz istekte core yalnız aktifleri dönüyor. Hata yutulmuyor: "etkinlik
  /// yok" ile "yüklenemedi" ayrımı [ApiException]'la.
  Future<List<EventModel>> fetchEvents() async {
    final body = await CoreApi.get('/events');
    return CoreApi.list(
      body,
      what: 'etkinlik listesi',
    ).map(EventModel.fromJson).toList(growable: false);
  }

  /// Üye başvurusu (201). Core'un 409'ları `code` ile ayrılıyor: kodsuz 409
  /// zaten bileti var (başarı), `registration_closed`, `event_cancelled`,
  /// `event_not_published`.
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

enum JoinResult {
  joined,
  alreadyJoined,
  registrationClosed,
  cancelled,
  failed;

  /// Bilet var mı (yeni ya da önceden).
  bool get hasTicket => this == joined || this == alreadyJoined;

  String get message => switch (this) {
    joined => 'Kaydın başarıyla alındı!',
    alreadyJoined => 'Bu etkinliğe zaten kaydın var.',
    registrationClosed => 'Bu etkinliğin başvuruları kapandı.',
    cancelled => 'Bu etkinlik iptal edildi.',
    failed => 'Katılım kaydı oluşturulamadı.',
  };
}

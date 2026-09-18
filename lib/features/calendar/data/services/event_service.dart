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
  /// Kullanıcının o etkinlikte zaten bileti varsa core 409 dönüyor; kayıt
  /// mevcut olduğu için bu da başarı sayılıyor.
  Future<bool> joinEvent(String eventId) async {
    try {
      await CoreApi.post('/events/$eventId/applications/me');
      return true;
    } on ApiException catch (e) {
      if (e.statusCode == 409) return true;
      log('Etkinliğe katılma hatası: $e');
      return false;
    }
  }
}

import 'dart:math';

import 'package:sky_app/core/extensions/date_time_extensions.dart';
import 'package:sky_app/core/services/api_exception.dart';
import 'package:sky_app/core/services/core_api.dart';
import 'package:sky_app/features/calendar/data/models/event_model.dart';

/// Etkinliğin durumu: yayınlama, taslağa alma, iptal ve kopya (core ADR 0066,
/// `docs/event-drafts.md`, `event-cancel.md`, `event-copy.md`). Hepsi
/// düzenleme yetkisine bağlı; DK 403 alıyor.
class EventStatusService {
  /// Taslak → yayında. Ad, konum ya da başlangıç eksikse
  /// `400 event_incomplete`.
  Future<EventModel> publish(String id) => _post('/events/$id/publish');

  /// Yayında → taslak; bileti ya da yarışmacısı varsa 409.
  Future<EventModel> unpublish(String id) => _post('/events/$id/unpublish');

  /// İptal; hiçbir şey silinmiyor ve geri alınabiliyor. [notify] bilet
  /// sahiplerine core'un e-postasını kuyruğa koyuyor.
  Future<EventModel> cancel(
    String id, {
    required String reason,
    required bool notify,
  }) => _post(
    '/events/$id/cancel',
    body: {'reason': reason, 'notifyTicketHolders': notify},
  );

  /// İptali geri alır; iptal e-postası gittiyse [notify] aynı kişilere
  /// "etkinlik geri geldi" e-postası gönderiyor.
  Future<EventModel> uncancel(String id, {required bool notify}) =>
      _post('/events/$id/uncancel', body: {'notifyTicketHolders': notify});

  /// Yapıyı (açıklama, konum, program, kapak) yeni bir taslağa kopyalar;
  /// biletler, formlar ve geçmiş gelmiyor. Diğer tarihler yeni başlangıçla
  /// aynı mesafede kayıyor.
  Future<EventModel> copy(
    String id, {
    required String name,
    required DateTime startDate,
  }) async {
    final body = await CoreApi.post(
      '/events/$id/copy',
      body: {
        // Core isteği bu id ile tekrarlanabilir kılıyor; istemci üretiyor.
        'id': _uuidV4(),
        'name': name,
        'startDate': startDate.toApiString(),
      },
    );
    final result = CoreApi.object(body, what: 'kopya');
    return EventModel.fromJson(
      CoreApi.object(result['event'], what: 'kopyalanan etkinlik'),
    );
  }

  Future<EventModel> _post(String path, {Object? body}) async {
    final response = await CoreApi.post(path, body: body);
    return EventModel.fromJson(CoreApi.object(response, what: 'etkinlik'));
  }

  /// Core'un problem `code`'ları kullanıcıya söylenecek Türkçe metne.
  static String messageFor(ApiException error) {
    return switch (error.code) {
      'event_incomplete' =>
        'Yayınlamak için ad, konum ve başlangıç tarihi gerekli.',
      'event_cancelled' => 'İptal edilmiş etkinlikte bu yapılamaz.',
      'event_has_tickets' =>
        'Kaydı olan etkinlik taslağa alınamaz; iptal edebilirsin.',
      'event_has_competitors' => 'Yarışmacısı olan etkinlik taslağa alınamaz.',
      'event_ended' => 'Bitmiş etkinlik iptal edilemez.',
      'event_not_published' => 'Taslak iptal edilmez; silebilirsin.',
      _ => switch (error.statusCode) {
        403 => 'Bu etkinliği yönetme yetkin yok.',
        _ => error.userMessage,
      },
    };
  }

  static final Random _random = Random.secure();

  static String _uuidV4() {
    final bytes = List<int>.generate(16, (_) => _random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
  }
}

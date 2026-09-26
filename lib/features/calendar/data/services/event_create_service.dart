import 'package:image_picker/image_picker.dart';
import 'package:sky_app/core/extensions/date_time_extensions.dart';
import 'package:sky_app/core/services/api_exception.dart';
import 'package:sky_app/core/services/core_api.dart';
import 'package:sky_app/core/services/media_service.dart';
import 'package:sky_app/features/calendar/data/models/event_model.dart';
import 'package:sky_app/features/calendar/data/models/season.dart';

/// Formdan gelen etkinlik bilgileri; oluşturma ve düzenlemede aynı.
class EventDraft {
  const EventDraft({
    required this.name,
    required this.location,
    required this.ownerTeam,
    required this.startDate,
    required this.endDate,
    required this.active,
    required this.description,
    required this.formUrl,
    required this.linkedin,
    required this.capacity,
    this.coverImageId,
  });

  final String name;
  final String location;
  final String ownerTeam;
  final DateTime startDate;
  final DateTime endDate;
  final bool active;
  final String description;
  final String formUrl;
  final String linkedin;

  /// 0 sınırsız.
  final int capacity;

  /// Yeni yüklenen kapağın medya id'si; `null` ise kapak değişmiyor.
  final String? coverImageId;
}

/// Etkinlik oluşturma, düzenleme ve silmenin ağ işleri (core `/v1`):
/// sezon listesi, kapak yükleme, kayıt, sezona bağlama, güncelleme, silme.
///
/// Yetki core'da (`internal/authz`): sahip ekipte lider (GECEKODU'da üye)
/// ya da YK/DK/ADMIN olmayan kullanıcının isteği 403 ile reddediliyor.
/// Sezona bağlama yalnızca YK/DK/ADMIN'e açık.
class EventCreateService {
  final MediaService _media = MediaService();

  /// Bütün sezonlar; girişsiz okunuyor.
  Future<List<Season>> fetchSeasons() async {
    final body = await CoreApi.get('/seasons');
    return CoreApi.list(body, what: 'sezon listesi')
        .map(Season.fromJson)
        .where((season) => season.id.isNotEmpty)
        .toList(growable: false);
  }

  /// Kapak görselini yükler ve medya id'sini döner.
  ///
  /// Amaç `event_cover`: core görseli yeniden kodluyor, kart ve sayfa
  /// boyutlarını üretiyor. Etkinliğe bağlanmayan yükleme 24 saat sonra
  /// düşüyor, kaydedilen kapak core'un kaydına bağlı olduğu için kalıyor.
  Future<String> uploadCover(XFile image) async =>
      (await _media.uploadImage(image, purpose: 'event_cover')).id;

  /// Etkinliği oluşturur; [seasonId] verilirse sezona da bağlar ve son
  /// hâlini döner.
  ///
  /// Sezon oluşturma isteğinde gitmiyor, ayrı bir çağrıyla bağlanıyor ve bu
  /// yalnızca YK/DK/ADMIN'e açık. Bağlama düşerse etkinlik yine oluşmuş
  /// oluyor; o durumda sezonsuz hâli dönüyor.
  Future<EventModel> createEvent(EventDraft draft, {String? seasonId}) async {
    final body = await CoreApi.post('/events', body: _payload(draft));
    final created = EventModel.fromJson(
      CoreApi.object(body, what: 'oluşturulan etkinlik'),
    );

    if (seasonId == null || seasonId.isEmpty) return created;
    try {
      return await assignSeason(created.id, seasonId);
    } on ApiException {
      return created;
    }
  }

  /// Etkinliği günceller ve güncel hâlini döner.
  ///
  /// Core güncellemede bütün alanları yazıyor; formda olmayanlar
  /// ([original]'dan sıralama, ödül, katılım kuralı) aynen geri gönderiliyor
  /// ki silinmesin. Kapak değişmediyse mevcut kapak id'si gidiyor.
  Future<EventModel> updateEvent(EventModel original, EventDraft draft) async {
    final coverImageId =
        draft.coverImageId ??
        (original.coverImageId.isEmpty ? null : original.coverImageId);

    final body = await CoreApi.put(
      '/events/${original.id}',
      body: {
        ..._payload(draft),
        'coverImageId': coverImageId,
        'ranked': original.ranked,
        'prizeInfo': original.prizeInfo,
        if (original.attendanceRule.isNotEmpty)
          'attendanceRule': original.attendanceRule,
        'attendanceRatio': original.attendanceRatio,
      },
    );
    return EventModel.fromJson(
      CoreApi.object(body, what: 'güncellenen etkinlik'),
    );
  }

  /// Etkinliği sezona bağlar (YK/DK/ADMIN) ve güncel hâlini döner.
  Future<EventModel> assignSeason(String eventId, String seasonId) async {
    final body = await CoreApi.post('/seasons/$seasonId/events/$eventId');
    return EventModel.fromJson(CoreApi.object(body, what: 'etkinlik'));
  }

  /// Etkinliği siler (204). Core biletleri, yoklamaları ve sertifikaları da
  /// birlikte siliyor.
  Future<void> deleteEvent(String id) => CoreApi.delete('/events/$id');

  /// Tarihler UTC, RFC 3339.
  static Map<String, dynamic> _payload(EventDraft draft) => {
    'name': draft.name,
    'location': draft.location,
    'ownerTeam': draft.ownerTeam,
    'startDate': draft.startDate.toApiString(),
    'endDate': draft.endDate.toApiString(),
    'active': draft.active,
    'description': draft.description,
    'formUrl': draft.formUrl,
    'linkedin': draft.linkedin,
    'capacity': draft.capacity,
    'coverImageId': ?draft.coverImageId,
  };
}

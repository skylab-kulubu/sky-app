import 'package:image_picker/image_picker.dart';
import 'package:sky_app/core/extensions/date_time_extensions.dart';
import 'package:sky_app/core/services/api_exception.dart';
import 'package:sky_app/core/services/core_api.dart';
import 'package:sky_app/core/services/media_service.dart';
import 'package:sky_app/features/calendar/data/models/event_model.dart';
import 'package:sky_app/features/calendar/data/models/season.dart';

class EventDraft {
  const EventDraft({
    required this.name,
    required this.location,
    required this.ownerTeam,
    required this.startDate,
    required this.endDate,
    required this.description,
    required this.formUrl,
    required this.linkedin,
    required this.capacity,
    required this.registrationClosed,
    this.coverImageId,
  });

  final String name;
  final String location;
  final String ownerTeam;
  final DateTime startDate;
  final DateTime endDate;
  final String description;
  final String formUrl;
  final String linkedin;

  /// 0 sınırsız.
  final int capacity;

  /// Kapalıyken kimse kendi başvurusunu yapamıyor (`409 registration_closed`);
  /// Forms'tan gelen cevaplar yine bilet yazıyor.
  final bool registrationClosed;

  /// Yeni yüklenen kapağın medya id'si; `null` ise kapak değişmiyor.
  final String? coverImageId;
}

/// Etkinlik oluşturma, düzenleme ve silmenin ağ işleri. Yetki core'da;
/// sezona bağlama yalnızca YK/ADMIN'e açık.
class EventCreateService {
  final MediaService _media = MediaService();

  Future<List<Season>> fetchSeasons() async {
    final body = await CoreApi.get('/seasons');
    return CoreApi.list(body, what: 'sezon listesi')
        .map(Season.fromJson)
        .where((season) => season.id.isNotEmpty)
        .toList(growable: false);
  }

  /// Kapağı `event_cover` amacıyla yükler: core yeniden kodlayıp boyutları
  /// üretiyor. Etkinliğe bağlanmayan yükleme 24 saat sonra düşüyor.
  Future<String> uploadCover(XFile image) async =>
      (await _media.uploadImage(image, purpose: 'event_cover')).id;

  /// Oluşturur; [seasonId] verilirse ayrı çağrıyla sezona da bağlar (YK/ADMIN).
  /// Bağlama düşerse etkinlik sezonsuz hâliyle dönüyor. Durum gönderilmezse
  /// core yayında oluşturuyor.
  Future<EventModel> createEvent(
    EventDraft draft, {
    String? seasonId,
    bool asDraft = false,
  }) async {
    final body = await CoreApi.post(
      '/events',
      body: {..._payload(draft), if (asDraft) 'status': 'draft'},
    );
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

  /// Formda olmayan alanlar ([original]'dan sıralama, ödül, katılım kuralı)
  /// aynen geri gönderiliyor; kapak değişmediyse mevcut kapak id'si.
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

  /// Etkinliği sezona bağlar (YK/ADMIN) ve güncel hâlini döner.
  Future<EventModel> assignSeason(String eventId, String seasonId) async {
    final body = await CoreApi.post('/seasons/$seasonId/events/$eventId');
    return EventModel.fromJson(CoreApi.object(body, what: 'etkinlik'));
  }

  /// Etkinliği siler (204; core arşivliyor). Yalnız taslak; yayındakinde
  /// `409 event_not_draft` (YK/ADMIN hariç).
  Future<void> deleteEvent(String id) => CoreApi.delete('/events/$id');

  static Map<String, dynamic> _payload(EventDraft draft) => {
    'name': draft.name,
    'location': draft.location,
    'ownerTeam': draft.ownerTeam,
    'startDate': draft.startDate.toApiString(),
    'endDate': draft.endDate.toApiString(),
    'description': draft.description,
    'formUrl': draft.formUrl,
    'linkedin': draft.linkedin,
    'capacity': draft.capacity,
    'registrationClosed': draft.registrationClosed,
    'coverImageId': ?draft.coverImageId,
  };
}

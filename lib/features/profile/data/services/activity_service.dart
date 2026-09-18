import 'package:sky_app/core/constants/app_colors.dart';
import 'package:sky_app/core/constants/app_icons.dart';
import 'package:sky_app/core/extensions/date_time_extensions.dart';
import 'package:sky_app/core/services/api_exception.dart';
import 'package:sky_app/core/services/core_api.dart';
import 'package:sky_app/features/calendar/data/models/event_model.dart';
import 'package:sky_app/features/profile/data/models/activity.dart';

/// Kullanıcının son aktiviteleri.
///
/// Backend'de ayrı bir aktivite geçmişi yok; liste kullanıcının kendi
/// biletlerinden (`/v1/tickets/me`) ve yarışmacı kayıtlarından
/// (`/v1/competitors/me`) türetiliyor:
///
/// - Bilet → etkinliğe kayıt. Girişte okutulduysa kayıt yerine katılım.
/// - Yarışmacı kaydı → sıra, puan ya da kazanma bilgisi.
class ActivityService {
  /// Yeniden eskiye sıralı aktiviteler.
  ///
  /// İki istekten biri düşerse [ApiException] fırlatıyor; yarım bir liste
  /// "aktiviten bu kadar" gibi okunurdu.
  Future<List<Activity>> fetchMyActivities() async {
    final results = await Future.wait([
      CoreApi.get('/tickets/me'),
      CoreApi.get('/competitors/me'),
    ]);

    final activities = <Activity>[
      ...CoreApi.list(
        results[0],
        what: 'bilet listesi',
      ).map(_fromTicket).nonNulls,
      ...CoreApi.list(
        results[1],
        what: 'yarışma listesi',
      ).map(_fromCompetitor).nonNulls,
    ]..sort((a, b) => b.dateTime.compareTo(a.dateTime));

    return activities;
  }

  /// Bilette kayıt tarihi yok; kayıt, etkinliğin başlangıç tarihiyle
  /// listeleniyor. Katılımda ise okutmanın gerçek zamanı var.
  Activity? _fromTicket(Map<String, dynamic> json) {
    final event = _event(json['event']);
    if (event == null) return null;

    final checkInTimes =
        (json['checkIns'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map((checkIn) => ApiDateTime.parse('${checkIn['createdAt']}'))
            .nonNulls
            .toList()
          ..sort();

    if (checkInTimes.isNotEmpty) {
      // Yoklama oturum (konuşma) başına alınıyor; hepsi tek satır.
      final sessions = checkInTimes.length;
      return Activity(
        title: event.name,
        description: sessions > 1
            ? 'Etkinlikte $sessions oturuma katıldın.'
            : 'Etkinliğe katıldın.',
        icon: AppIcons.checkCircle,
        color: AppColors.green,
        dateTime: checkInTimes.last,
      );
    }

    final start = event.startDateTime;
    if (start == null) return null;

    return Activity(
      title: event.name,
      description: 'Etkinliğe kaydoldun.',
      icon: AppIcons.ticket,
      color: AppColors.orange,
      dateTime: start,
    );
  }

  Activity? _fromCompetitor(Map<String, dynamic> json) {
    final event = _event(json['event']);
    if (event == null) return null;

    final date = event.endDateTime ?? event.startDateTime;
    if (date == null) return null;

    return Activity(
      title: event.name,
      description: _competitorDescription(json, finished: !event.isUpcoming),
      icon: AppIcons.medal,
      color: AppColors.purple,
      dateTime: date,
    );
  }

  /// Bitmemiş yarışmada sıra ve puan henüz anlamlı değil.
  String _competitorDescription(
    Map<String, dynamic> json, {
    required bool finished,
  }) {
    if (!finished) return 'Yarışmacı olarak kaydoldun.';

    if (json['isWinner'] == true) return 'Yarışmayı kazandın!';

    final score = json['score'];
    if (score is num) {
      final formatted = score == score.roundToDouble()
          ? score.toInt().toString()
          : score.toStringAsFixed(1);
      return 'Yarışmayı $formatted puanla tamamladın.';
    }

    return 'Yarışmaya katıldın.';
  }

  EventModel? _event(Object? json) {
    if (json is! Map<String, dynamic>) return null;
    final event = EventModel.fromJson(json);
    return event.name.isEmpty ? null : event;
  }
}

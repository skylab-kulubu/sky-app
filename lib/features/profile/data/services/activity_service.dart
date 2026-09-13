import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:sky_app/core/constants/app_colors.dart';
import 'package:sky_app/core/constants/app_icons.dart';
import 'package:sky_app/core/services/api_client.dart';
import 'package:sky_app/core/services/api_exception.dart';
import 'package:sky_app/features/calendar/data/models/event_model.dart';
import 'package:sky_app/features/profile/data/models/activity.dart';

/// Kullanıcının son aktiviteleri.
///
/// Backend'de ayrı bir aktivite geçmişi yok; liste kullanıcının kendi
/// biletlerinden (`/api/tickets/me`) ve yarışmacı kayıtlarından
/// (`/api/competitors/me`) türetiliyor:
///
/// - Bilet → etkinliğe kayıt. Girişte okutulduysa kayıt yerine katılım.
/// - Yarışmacı kaydı → sıra, puan ya da kazanma bilgisi.
class ActivityService {
  final Dio _dio = ApiClient.instance.dio;

  /// Yeniden eskiye sıralı aktiviteler.
  ///
  /// İki istekten biri düşerse [ApiException] fırlatıyor; yarım bir liste
  /// "aktiviten bu kadar" gibi okunurdu.
  Future<List<Activity>> fetchMyActivities() async {
    final results = await Future.wait([
      _fetchList('/api/tickets/me'),
      _fetchList('/api/competitors/me'),
    ]);

    final activities = <Activity>[
      ...results[0].map(_fromTicket).nonNulls,
      ...results[1].map(_fromCompetitor).nonNulls,
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
            .map((checkIn) => DateTime.tryParse('${checkIn['createdAt']}'))
            .nonNulls
            .toList()
          ..sort();

    if (checkInTimes.isNotEmpty) {
      // Çok günlü etkinlikte her gün ayrı okutuluyor; hepsi tek satır.
      final days = checkInTimes.length;
      return Activity(
        title: event.name,
        description: days > 1
            ? 'Etkinliğe $days gün katıldın.'
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

    // Backend alanı `isWinner`, ama Lombok'un `isWinner()` getter'ı yüzünden
    // Jackson onu `winner` diye yazıyor; ikisi de okunuyor.
    final isWinner = json['isWinner'] == true || json['winner'] == true;
    if (isWinner) return 'Yarışmayı kazandın!';

    final rank = json['rank'];
    if (rank is int) return 'Yarışmayı $rank. sırada tamamladın.';

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

  /// `DataResult` sarmalayıcısındaki `data` listesini döner.
  Future<List<Map<String, dynamic>>> _fetchList(String path) async {
    final Response<dynamic> response;
    try {
      response = await _dio.get<dynamic>(path);
    } catch (e) {
      throw ApiException.from(e);
    }

    dynamic rawData = response.data;
    if (rawData is String) {
      try {
        rawData = jsonDecode(rawData);
      } catch (_) {
        throw const ApiException(
          ApiErrorType.server,
          message: 'Yanıt çözümlenemedi',
        );
      }
    }

    final data = rawData is Map<String, dynamic> ? rawData['data'] : null;
    if (data is! List) {
      throw const ApiException(
        ApiErrorType.server,
        message: 'Beklenmeyen yanıt gövdesi',
      );
    }

    return data.whereType<Map<String, dynamic>>().toList(growable: false);
  }
}

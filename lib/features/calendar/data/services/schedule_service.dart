import 'package:sky_app/core/services/core_api.dart';
import 'package:sky_app/features/calendar/data/models/event_session.dart';

/// Etkinlik programı (core): günler ve oturumlar. Okuma herkese açık;
/// yazma etkinliği düzenleyebilenlere (sahip ekibin lideri, GECEKODU'da
/// üyeler, YK/DK/ADMIN), silme liderlere ve YK/DK/ADMIN'e.
class ScheduleService {
  /// Etkinliğin programı: tarihe göre sıralı günler, her birinin saate göre
  /// sıralı oturumları (iptaller dahil).
  Future<List<ScheduleDay>> fetchSchedule(String eventId) async {
    final days = CoreApi.list(
      await CoreApi.get('/events/$eventId/days'),
      what: 'etkinlik günleri',
    ).map(EventDay.fromJson).where((d) => d.id.isNotEmpty).toList();

    days.sort((a, b) {
      final aDate = a.startDate;
      final bDate = b.startDate;
      if (aDate == null || bDate == null) return 0;
      return aDate.compareTo(bDate);
    });

    final sessionsByDay = await Future.wait([
      for (final day in days) CoreApi.get('/event-days/${day.id}/sessions'),
    ]);

    return [
      for (var i = 0; i < days.length; i++)
        ScheduleDay(
          day: days[i],
          sessions:
              CoreApi.list(sessionsByDay[i], what: 'oturumlar')
                  .map(EventSession.fromJson)
                  .where((s) => s.id.isNotEmpty)
                  .toList()
                ..sort(_bySchedule),
        ),
    ];
  }

  static int _bySchedule(EventSession a, EventSession b) {
    final aStart = a.startTime;
    final bStart = b.startTime;
    if (aStart != null && bStart != null) return aStart.compareTo(bStart);
    return a.orderIndex.compareTo(b.orderIndex);
  }

  Future<void> createDay(EventDay day) =>
      CoreApi.post('/event-days', body: day.toJson());

  Future<void> updateDay(EventDay day) =>
      CoreApi.put('/event-days/${day.id}', body: day.toJson());

  /// Günü siler; core oturumlarını ve yoklamalarını da birlikte siliyor.
  Future<void> deleteDay(String dayId) => CoreApi.delete('/event-days/$dayId');

  Future<void> createSession(EventSession session) =>
      CoreApi.post('/sessions', body: session.toJson());

  Future<void> updateSession(EventSession session) =>
      CoreApi.put('/sessions/${session.id}', body: session.toJson());

  Future<void> deleteSession(String sessionId) =>
      CoreApi.delete('/sessions/$sessionId');
}

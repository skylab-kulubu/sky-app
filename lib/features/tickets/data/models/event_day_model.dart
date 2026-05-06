class EventDayModel {
  final String id;
  final String name;
  final String startDate;
  final String endDate;
  final String eventDayId;

  const EventDayModel({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.eventDayId,
  });

  factory EventDayModel.fromJson(Map<String, dynamic> json) {
    return EventDayModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      startDate: json['startDate'] as String? ?? '',
      endDate: json['endDate'] as String? ?? '',
      eventDayId: json['session']['eventDayId'] as String? ?? '',
    );
  }

  String get formattedDate {
    if (startDate.isEmpty) return '';
    try {
      final date = DateTime.parse(startDate);
      return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
    } catch (_) {
      return startDate;
    }
  }

  List<DateTime> get eventDays {
    if (startDate.isEmpty || endDate.isEmpty) return [];
    try {
      final start = DateTime.parse(startDate);
      final end = DateTime.parse(endDate);

      final days = <DateTime>[];
      var current = DateTime(start.year, start.month, start.day);
      final last = DateTime(end.year, end.month, end.day);

      while (!current.isAfter(last)) {
        days.add(current);
        current = current.add(const Duration(days: 1));
      }
      return days;
    } catch (e) {
      return [];
    }
  }
}

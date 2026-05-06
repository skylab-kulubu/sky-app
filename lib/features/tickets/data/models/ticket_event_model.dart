class TicketEventModel {
  final String id;
  final String name;
  final String coverImageUrl;
  final String location;
  final String startDate;
  final String endDate;
  final bool active;

  const TicketEventModel({
    required this.id,
    required this.name,
    required this.coverImageUrl,
    required this.location,
    required this.startDate,
    required this.endDate,
    required this.active,
  });

  factory TicketEventModel.fromJson(Map<String, dynamic> json) {
    return TicketEventModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      coverImageUrl: json['coverImageUrl'] as String? ?? '',
      location: json['location'] as String? ?? '',
      startDate: json['startDate'] as String? ?? '',
      endDate: json['endDate'] as String? ?? '',
      active: json['active'] as bool? ?? false,
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

  String get formattedTime {
    if (startDate.isEmpty) return '';
    try {
      final date = DateTime.parse(startDate);
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }
}

class EventModel {
  final String id;
  final String imageUrl;
  final String title;
  final String date;
  final String time;
  final bool isJoinable;

  EventModel({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.date,
    required this.time,
    required this.isJoinable,
  });
}

/// Etkinliklerin bağlı olduğu dönem (core `/v1/seasons`).
class Season {
  const Season({required this.id, required this.name, required this.active});

  final String id;
  final String name;
  final bool active;

  factory Season.fromJson(Map<String, dynamic> json) {
    return Season(
      id: json['id'] as String? ?? '',
      name: (json['name'] as String? ?? '').trim(),
      active: json['active'] == true,
    );
  }
}

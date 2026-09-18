/// Ekibin herkese açık üyesi (core `/v1/teams/{team}/members`).
class TeamMember {
  const TeamMember({
    required this.firstName,
    required this.lastName,
    required this.profilePictureUrl,
    required this.linkedin,
    required this.department,
    required this.isLeader,
  });

  final String firstName;
  final String lastName;
  final String profilePictureUrl;

  /// Kayıtta şemasız gelebiliyor (`linkedin.com/in/...`); [linkedinUrl]
  /// tamamlanmış hâlini veriyor.
  final String linkedin;
  final String department;
  final bool isLeader;

  factory TeamMember.fromJson(Map<String, dynamic> json) {
    return TeamMember(
      firstName: (json['firstName'] as String? ?? '').trim(),
      lastName: (json['lastName'] as String? ?? '').trim(),
      profilePictureUrl: (json['profilePictureUrl'] as String? ?? '').trim(),
      linkedin: (json['linkedin'] as String? ?? '').trim(),
      department: (json['department'] as String? ?? '').trim(),
      isLeader: json['leader'] == true,
    );
  }

  String get name => [firstName, lastName].where((p) => p.isNotEmpty).join(' ');

  String get linkedinUrl {
    if (linkedin.isEmpty) return '';
    return linkedin.startsWith('http') ? linkedin : 'https://$linkedin';
  }
}

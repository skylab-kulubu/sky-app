class UserModel {
  final String name;
  final String givenName;
  final String familyName;
  final String email;
  final String preferredUsername;
  final String university;
  final String department;
  final String skyNumber;
  final bool emailVerified;
  final List<String> realmRoles;

  const UserModel({
    required this.name,
    required this.givenName,
    required this.familyName,
    required this.email,
    required this.preferredUsername,
    required this.university,
    required this.department,
    required this.skyNumber,
    required this.emailVerified,
    required this.realmRoles,
  });

  factory UserModel.fromJwt(Map<String, dynamic> payload) {
    return UserModel(
      name: payload['name'] ?? '',
      givenName: payload['given_name'] ?? '',
      familyName: payload['family_name'] ?? '',
      email: payload['email'] ?? '',
      preferredUsername: payload['preferred_username'] ?? '',
      university: payload['university'] ?? '',
      department: payload['department'] ?? '',
      skyNumber: payload['sky_number'] ?? '',
      emailVerified: payload['email_verified'] ?? false,
      realmRoles: List<String>.from(payload['realm_access']?['roles'] ?? []),
    );
  }

  static const List<String> _teamRoles = [
    'MOBILAB',
    'AIRLAB',
    'ALGOLAB',
    'GAMELAB',
    'CHAINLAB',
    'SKYSEC',
    'SKYSIS',
    'WEBLAB',
    'GECEKODU',
    'SKYMEDYA',
    'BIZBIZE',
    'DK',
    'YK',
    'SKYDEVOPS',
  ];

  List<String> get teams =>
      realmRoles.where((role) => _teamRoles.contains(role)).toList();

  String get teamsDisplay => teams.isEmpty ? '' : teams.join(' • ');
}

class UserModel {
  final String id;
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

  // Yalnızca profil API'sinden gelen alanlar; JWT'de karşılıkları yok.
  final String schoolEmail;
  final String faculty;
  final String profilePictureUrl;
  final String linkedin;
  final bool ldapUser;

  const UserModel({
    required this.id,
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
    this.schoolEmail = '',
    this.faculty = '',
    this.profilePictureUrl = '',
    this.linkedin = '',
    this.ldapUser = false,
  });

  factory UserModel.fromJwt(Map<String, dynamic> payload) {
    return UserModel(
      id: payload['sub'] ?? '',
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

  /// Profil API'sinin `data` objesinden kurar.
  ///
  /// Yanıtta rol bilgisi bulunmadığı için [realmRoles] boş kalır; roller
  /// yalnızca JWT'de olduğundan bu nesne tek başına değil, [mergeWith] ile
  /// JWT'den gelen nesnenin üzerine uygulanmalıdır.
  factory UserModel.fromJson(Map<String, dynamic> data) {
    final firstName = data['firstName'] as String? ?? '';
    final lastName = data['lastName'] as String? ?? '';

    return UserModel(
      id: data['id'] ?? '',
      name: '$firstName $lastName'.trim(),
      givenName: firstName,
      familyName: lastName,
      email: data['email'] ?? '',
      preferredUsername: data['username'] ?? '',
      university: data['university'] ?? '',
      department: data['department'] ?? '',
      skyNumber: data['skyNumber'] ?? '',
      emailVerified: false,
      realmRoles: const [],
      schoolEmail: data['schoolEmail'] ?? '',
      faculty: data['faculty'] ?? '',
      profilePictureUrl: data['profilePictureUrl'] ?? '',
      linkedin: data['linkedin'] ?? '',
      ldapUser: data['ldapUser'] ?? false,
    );
  }

  /// JWT'den gelen nesnenin üzerine profil API'sinden geleni uygular.
  ///
  /// Roller ve [emailVerified] JWT'de kalır (API bunları döndürmüyor);
  /// diğer alanlarda API kazanır, ama boş gelen bir alan JWT'deki değeri
  /// silmez.
  UserModel mergeWith(UserModel profile) {
    String pick(String fromProfile, String fromJwt) =>
        fromProfile.trim().isNotEmpty ? fromProfile : fromJwt;

    return UserModel(
      id: pick(profile.id, id),
      name: pick(profile.name, name),
      givenName: pick(profile.givenName, givenName),
      familyName: pick(profile.familyName, familyName),
      email: pick(profile.email, email),
      preferredUsername: pick(profile.preferredUsername, preferredUsername),
      university: pick(profile.university, university),
      department: pick(profile.department, department),
      skyNumber: pick(profile.skyNumber, skyNumber),
      emailVerified: emailVerified,
      realmRoles: realmRoles,
      schoolEmail: pick(profile.schoolEmail, schoolEmail),
      faculty: pick(profile.faculty, faculty),
      profilePictureUrl: pick(profile.profilePictureUrl, profilePictureUrl),
      linkedin: pick(profile.linkedin, linkedin),
      ldapUser: profile.ldapUser || ldapUser,
    );
  }

  static const List<String> _teamRoles = [
    'AGC',
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
    'YILDIZJAM',
  ];

  List<String> get teams =>
      realmRoles.where((role) => _teamRoles.contains(role)).toList();

  bool isOrganizerFor(String activeEventTypeName) {
    if (activeEventTypeName.isEmpty) return false;
    return realmRoles.contains(activeEventTypeName);
  }

  bool isOrganizerForAny(Iterable<String> activeEventTypeNames) {
    for (final activeEventTypeName in activeEventTypeNames) {
      if (isOrganizerFor(activeEventTypeName)) {
        return true;
      }
    }
    return false;
  }

  String get teamsDisplay => teams.isEmpty ? '' : teams.join(' • ');
}

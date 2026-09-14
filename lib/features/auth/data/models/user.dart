class User {
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

  /// Keycloak grup yolları (`/UYELER/ARGE/MOBILAB/LIDERLER`). Yalnızca
  /// JWT'de var. Etkinlik yetkilerini OPA bunlardan hesaplıyor; uygulama da
  /// aynı kaynaktan okuyor ki gösterdiği ile backend'in izin verdiği aynı olsun.
  final List<String> groups;

  // Yalnızca profil API'sinden gelen alanlar; JWT'de karşılıkları yok.
  final String schoolEmail;
  final String faculty;
  final String profilePictureUrl;
  final String linkedin;
  final bool ldapUser;

  const User({
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
    this.groups = const [],
  });

  factory User.fromJwt(Map<String, dynamic> payload) {
    return User(
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
      groups: List<String>.from(payload['groups'] ?? []),
    );
  }

  /// Profil API'sinin `data` objesinden kurar.
  ///
  /// Yanıtta rol bilgisi bulunmadığı için [realmRoles] boş kalır; roller
  /// yalnızca JWT'de olduğundan bu nesne tek başına değil, [mergeWith] ile
  /// JWT'den gelen nesnenin üzerine uygulanmalıdır.
  factory User.fromJson(Map<String, dynamic> data) {
    final firstName = data['firstName'] as String? ?? '';
    final lastName = data['lastName'] as String? ?? '';

    return User(
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
  User mergeWith(User profile) {
    String pick(String fromProfile, String fromJwt) =>
        fromProfile.trim().isNotEmpty ? fromProfile : fromJwt;

    return User(
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
      groups: groups,
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

  /// Grup yollarının parçaları; `/UYELER/ARGE/MOBILAB/LIDERLER` →
  /// `[UYELER, ARGE, MOBILAB, LIDERLER]`.
  Iterable<List<String>> get _groupPaths => groups.map(
    (path) => path.split('/').where((part) => part.isNotEmpty).toList(),
  );

  static const Set<String> _privilegedGroups = {'ADMIN', 'YK', 'DK'};
  static const Set<String> _leaderSubgroups = {'LIDERLER', 'KOORDINATORLER'};

  /// YK, DK ya da ADMIN grubunda (ya da alt gruplarında) mı. OPA'da bu
  /// kullanıcılar her ekip adına etkinlik oluşturabiliyor.
  bool get isPrivileged =>
      _groupPaths.any((parts) => parts.any(_privilegedGroups.contains));

  /// Lideri ya da koordinatörü olduğu ekipler; grup yolunda lider alt
  /// grubunun hemen üstündeki parça.
  Set<String> get leaderTeams => {
    for (final parts in _groupPaths)
      for (var i = 1; i < parts.length; i++)
        if (_leaderSubgroups.contains(parts[i])) parts[i - 1],
  };

  /// Verilen grubun (ya da alt gruplarından birinin) üyesi mi.
  bool isInGroup(String name) =>
      _groupPaths.any((parts) => parts.contains(name));

  /// Etkinlik oluştururken seçilebilecek sahip ekipler; OPA kurallarının
  /// uygulamadaki karşılığı (`e-skylab/opa/policies/events.rego`):
  ///
  /// - YK/DK/ADMIN: bütün ekipler.
  /// - Lider/koordinatör: lideri olduğu ekipler.
  /// - GECEKODU'da düz üyeler de oluşturabiliyor.
  ///
  /// Boşsa kullanıcı etkinlik oluşturamaz. Asıl kontrol backend'de; bu liste
  /// yalnızca butonu ve seçenekleri belirliyor.
  List<String> get eventOwnerOptions {
    if (isPrivileged) return List.of(_teamRoles);

    return {
      ...leaderTeams,
      if (isInGroup(_everyMemberCanCreateTeam)) _everyMemberCanCreateTeam,
    }.toList();
  }

  static const String _everyMemberCanCreateTeam = 'GECEKODU';

  bool get canCreateEvent => eventOwnerOptions.isNotEmpty;

  /// Verilen ekibin etkinliğini düzenleyebilir mi. OPA'da güncelleme,
  /// oluşturmayla aynı kurala bağlı (GECEKODU'da üyeler dahil).
  bool canEditEvent(String ownerTeam) =>
      ownerTeam.isNotEmpty &&
      (isPrivileged ||
          leaderTeams.contains(ownerTeam) ||
          (ownerTeam == _everyMemberCanCreateTeam && isInGroup(ownerTeam)));

  /// Silme her ekipte yalnızca liderlere ve YK/DK/ADMIN'e açık; GECEKODU
  /// üyeleri düzenleyebiliyor ama silemiyor.
  bool canDeleteEvent(String ownerTeam) =>
      ownerTeam.isNotEmpty && (isPrivileged || leaderTeams.contains(ownerTeam));

  /// Verilen ekibin lideri mi. Keycloak'ta ekibin `LIDERLER` alt grubuna
  /// `<EKİP>_LEADER` realm rolü bağlı; gruba eklenen kişi rolü token'da
  /// taşıyor. SkyCMS de ekip düzenleme yetkisini aynı rolden okuyor.
  bool isTeamLeader(String teamKey) =>
      teamKey.isNotEmpty && realmRoles.contains('${teamKey}_LEADER');

  /// Kullanıcı adının gösterim hâli; arayüzde hep `@` ile yazılıyor.
  String get usernameDisplay =>
      preferredUsername.isEmpty ? '' : '@$preferredUsername';
}

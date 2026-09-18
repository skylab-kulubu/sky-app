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

  /// Keycloak realm rolleri. Yetki için **kullanılmıyor**: core ve CMS
  /// yalnızca [groups]'a bakıyor. Bilgi amaçlı duruyor.
  final List<String> realmRoles;

  /// Keycloak grup yolları (`/UYELER/ARGE/MOBILAB/LIDERLER`). Yalnızca
  /// JWT'de var. Ekip üyeliği ve bütün yetkiler bunlardan hesaplanıyor;
  /// core (`internal/authz`) ve CMS de aynı kaynağa bakıyor, böylece
  /// uygulamanın gösterdiği ile backend'in izin verdiği aynı kalıyor.
  final List<String> groups;

  /// Token'ı alan client'ın (`azp`, uygulamada `skyapp`) rolleri. CMS
  /// `cms:access`'i buradan okuyor; başka client'lardaki roller sayılmıyor.
  final List<String> cmsRoles;

  bool get _hasCmsAccess => cmsRoles.contains('cms:access');

  /// Haber oluşturup düzenleyebilir mi: CMS `cms:access` rolüyle birlikte
  /// YK/DK/ADMIN grubunu istiyor.
  bool get canManageNews => _hasCmsAccess && isPrivileged;

  /// Ekibin CMS sayfasını düzenleyebilir mi: `cms:access` ve o ekibin lider
  /// ya da koordinatör alt grubu. [teamKey] büyük harfli grup adı (`MOBILAB`).
  bool canEditTeam(String teamKey) =>
      _hasCmsAccess && leaderTeams.contains(teamKey);

  // Yalnızca profil API'sinden gelen alanlar; JWT'de karşılıkları yok.
  final String schoolEmail;
  final String faculty;
  final String profilePictureUrl;
  final String linkedin;

  /// Eşlenmiş öğrenci kartının UID'si (NFC); eşlenmemişse boş.
  final String studentCardUid;

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
    this.studentCardUid = '',
    this.groups = const [],
    this.cmsRoles = const [],
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
      cmsRoles: List<String>.from(
        payload['resource_access']?[payload['azp']]?['roles'] ?? [],
      ),
    );
  }

  /// Core `GET /v1/users/me` yanıtından kurar.
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
      studentCardUid: data['studentCardUid'] ?? '',
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
      cmsRoles: cmsRoles,
      schoolEmail: pick(profile.schoolEmail, schoolEmail),
      faculty: pick(profile.faculty, faculty),
      profilePictureUrl: pick(profile.profilePictureUrl, profilePictureUrl),
      linkedin: pick(profile.linkedin, linkedin),
      studentCardUid: pick(profile.studentCardUid, studentCardUid),
    );
  }

  /// Etkinlik sahibi olarak seçilebilen ekipler (YK/DK/ADMIN için).
  /// `ownerTeam` Keycloak grup adıyla eşleşmeli; core yetkiyi o gruba göre
  /// veriyor.
  static const List<String> _eventOwnerTeams = [
    'AIRLAB',
    'ALGOLAB',
    'CHAINLAB',
    'GAMELAB',
    'MOBILAB',
    'SKYSEC',
    'SKYSIS',
    'WEBLAB',
    'GECEKODU',
    'YK',
    'DK',
  ];

  /// Kullanıcının grupları, arayüzde gösterilecek adlarıyla: her grup
  /// yolunun en derin anlamlı parçası. Kapsayıcılar (`UYELER`, `ARGE`,
  /// `ORGANIZASYON`), rol alt grupları (`LIDERLER`) ve teknik `ADMIN`
  /// gösterilmiyor. `/UYELER/ARGE/MOBILAB/LIDERLER` → `MOBILAB`.
  List<String> get teams => {
    for (final parts in _groupPaths)
      if (parts.where((part) => !_leaderSubgroups.contains(part)).lastOrNull
          case final team?)
        if (!_hiddenGroups.contains(team)) team,
  }.toList();

  static const Set<String> _hiddenGroups = {
    'UYELER',
    'ARGE',
    'ORGANIZASYON',
    'ADMIN',
  };

  String get teamsDisplay => teams.isEmpty ? '' : teams.join(' • ');

  /// Grup yollarının parçaları; `/UYELER/ARGE/MOBILAB/LIDERLER` →
  /// `[UYELER, ARGE, MOBILAB, LIDERLER]`.
  Iterable<List<String>> get _groupPaths => groups.map(
    (path) => path.split('/').where((part) => part.isNotEmpty).toList(),
  );

  static const Set<String> _privilegedGroups = {'ADMIN', 'YK', 'DK'};
  static const Set<String> _leaderSubgroups = {'LIDERLER', 'KOORDINATORLER'};

  /// YK, DK ya da ADMIN grubunda (ya da alt gruplarında) mı. Core ve CMS'te
  /// bu kullanıcılar her şeye yetkili.
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

  /// Etkinlik oluştururken seçilebilecek sahip ekipler; core kurallarının
  /// uygulamadaki karşılığı (`core-backend/internal/authz/policy.go`):
  ///
  /// - YK/DK/ADMIN: bütün ekipler.
  /// - Lider/koordinatör: lideri olduğu ekipler.
  /// - GECEKODU'da düz üyeler de oluşturabiliyor.
  ///
  /// Boşsa kullanıcı etkinlik oluşturamaz. Asıl kontrol backend'de; bu liste
  /// yalnızca butonu ve seçenekleri belirliyor.
  List<String> get eventOwnerOptions {
    if (isPrivileged) return List.of(_eventOwnerTeams);

    return {
      ...leaderTeams,
      if (isInGroup(_everyMemberCanCreateTeam)) _everyMemberCanCreateTeam,
    }.toList();
  }

  static const String _everyMemberCanCreateTeam = 'GECEKODU';

  bool get canCreateEvent => eventOwnerOptions.isNotEmpty;

  /// Verilen ekibin etkinliğini düzenleyebilir mi. Core'da güncelleme,
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

  /// Kullanıcı adının gösterim hâli; arayüzde hep `@` ile yazılıyor.
  String get usernameDisplay =>
      preferredUsername.isEmpty ? '' : '@$preferredUsername';
}

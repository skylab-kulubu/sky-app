import 'package:sky_app/core/models/image_sizes.dart';

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

  /// Keycloak realm rolleri; yalnız bilgi için. Yetki [groups]'tan hesaplanıyor.
  final List<String> realmRoles;

  /// Keycloak grup yolları (`/UYELER/ARGE/MOBILAB/LIDERLER`), yalnızca JWT'de.
  /// Bütün yetkiler bunlardan; core ve CMS de aynı kaynağa bakıyor.
  final List<String> groups;

  /// Token'ı alan client'ın (`azp`, uygulamada `skyapp`) rolleri. CMS
  /// `cms:access`'i buradan okuyor; başka client'lardaki roller sayılmıyor.
  final List<String> cmsRoles;

  bool get _hasCmsAccess => cmsRoles.contains('cms:access');

  /// Haber oluşturup düzenleyebilir mi: CMS `cms:access` ile YK/DK/ADMIN grubu
  /// istiyor. Kararı CMS veriyor; core'un "DK salt okur" kuralı buraya girmiyor.
  bool get canManageNews => _hasCmsAccess && isPrivileged;

  /// Ekibin CMS sayfasını düzenleyebilir mi: `cms:access` ve o ekibin lider
  /// ya da koordinatör alt grubu. [teamKey] büyük harfli grup adı (`MOBILAB`).
  bool canEditTeam(String teamKey) =>
      _hasCmsAccess && leaderTeams.contains(teamKey);

  // Yalnızca profil API'sinden gelen alanlar; JWT'de karşılıkları yok.
  final String schoolEmail;
  final String faculty;
  final String profilePictureUrl;
  final ImageSizes profilePictureSizes;
  final String linkedin;

  /// Avatar küçük çiziliyor; `card` boyutu yetiyor.
  String get avatarUrl => profilePictureSizes.cardOr(profilePictureUrl);

  /// Öğrenci kartı SkyPass'e eşlenmiş mi (core `studentCardLinked`). Kartın
  /// numarası gizli, yalnızca bu bilgi geliyor.
  final bool studentCardLinked;

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
    this.profilePictureSizes = ImageSizes.none,
    this.linkedin = '',
    this.studentCardLinked = false,
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

  /// Core `GET /v1/users/me` yanıtından kurar. Yanıtta rol olmadığı için tek
  /// başına değil, [mergeWith] ile JWT'den gelen nesnenin üzerine uygulanmalı.
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
      profilePictureSizes: ImageSizes.fromJson(data['profilePictureSizes']),
      linkedin: data['linkedin'] ?? '',
      studentCardLinked: data['studentCardLinked'] == true,
    );
  }

  /// JWT'den gelen nesnenin üzerine profil API'sinden geleni uygular. Roller
  /// ve [emailVerified] JWT'de kalıyor; diğer alanlarda API kazanıyor ama boş
  /// gelen alan JWT'deki değeri silmiyor.
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
      profilePictureSizes: profile.profilePictureSizes,
      linkedin: pick(profile.linkedin, linkedin),
      studentCardLinked: profile.studentCardLinked,
    );
  }

  /// Etkinlik sahibi olarak seçilebilen ekipler (YK/ADMIN için); değerler
  /// Keycloak grup adı, core yetkiyi o gruba göre veriyor.
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

  /// Kullanıcının ekipleri: her `/UYELER/...` yolunun en derin anlamlı parçası
  /// (`/UYELER/ARGE/MOBILAB/LIDERLER` → `MOBILAB`). `/ROLLER/...` rol grupları,
  /// kapsayıcılar ve lider alt grupları sayılmıyor.
  List<String> get teams => {
    for (final parts in _groupPaths)
      if (parts.firstOrNull == _membersRoot)
        if (parts.where((part) => !_leaderSubgroups.contains(part)).lastOrNull
            case final team?)
          if (!_hiddenGroups.contains(team)) team,
  }.toList();

  static const String _membersRoot = 'UYELER';

  static const Set<String> _hiddenGroups = {
    'UYELER',
    'ARGE',
    'IGT',
    'ORGANIZASYON',
    'ADMIN',
  };

  String get teamsDisplay => teams.isEmpty ? '' : teams.join(' • ');

  Iterable<List<String>> get _groupPaths => groups.map(_partsOf);

  static List<String> _partsOf(String path) =>
      path.split('/').where((part) => part.isNotEmpty).toList();

  static const Set<String> _leaderSubgroups = {'LIDERLER', 'KOORDINATORLER'};

  /// Core'un yazabilen yetkili kökleri (`AUTHZ_PRIVILEGED_ROOTS`). Yalnızca bu
  /// yollar ve altı; başka yerdeki aynı adlı grup (`/UYELER/ARGE/WEBLAB/ADMIN`)
  /// yetki vermiyor.
  static const List<String> _writerRoots = [
    '/ADMIN',
    '/YK',
    '/UYELER/ADMIN',
    '/UYELER/YK',
  ];

  /// Salt okur yetkili kökler (`AUTHZ_PRIVILEGED_READER_ROOTS`): Denetim
  /// Kurulu her şeyi okuyor, hiçbir şeyi değiştirmiyor.
  static const List<String> _readerRoots = ['/DK', '/UYELER/DK'];

  static bool _isUnder(String path, List<String> roots) =>
      roots.any((root) => path == root || path.startsWith('$root/'));

  /// YK, DK ya da ADMIN kökünde (ya da alt gruplarında) mı. Okuma için
  /// hepsi yetkili; yazma için [canWriteAsPrivileged]'a bakılmalı.
  bool get isPrivileged =>
      canWriteAsPrivileged ||
      groups.any((path) => _isUnder(path, _readerRoots));

  /// YK ya da ADMIN kökünde mi: core'da her şeyi değiştirebilenler. DK
  /// burada yok; DK üyesi aynı zamanda YK'daysa YK üzerinden yazar.
  bool get canWriteAsPrivileged =>
      groups.any((path) => _isUnder(path, _writerRoots));

  /// Lideri ya da koordinatörü olduğu ekipler. Yetkili köklerin altındaki
  /// yollar core'da ekip sayılmıyor.
  Set<String> get leaderTeams => {
    for (final path in groups)
      if (!_isUnder(path, _writerRoots) && !_isUnder(path, _readerRoots))
        for (final parts in [_partsOf(path)])
          for (var i = 1; i < parts.length; i++)
            if (_leaderSubgroups.contains(parts[i])) parts[i - 1],
  };

  /// Verilen grubun (ya da alt gruplarından birinin) üyesi mi.
  bool isInGroup(String name) =>
      _groupPaths.any((parts) => parts.contains(name));

  /// Etkinlik oluştururken seçilebilecek sahip ekipler (core
  /// `internal/authz/policy.go`): YK/ADMIN bütün ekipler, lider kendi ekipleri,
  /// GECEKODU'da düz üyeler de. Boşsa kullanıcı etkinlik oluşturamaz.
  List<String> get eventOwnerOptions {
    if (canWriteAsPrivileged) return List.of(_eventOwnerTeams);

    return {
      ...leaderTeams,
      if (isInGroup(_everyMemberCanCreateTeam)) _everyMemberCanCreateTeam,
    }.toList();
  }

  static const String _everyMemberCanCreateTeam = 'GECEKODU';

  bool get canCreateEvent => eventOwnerOptions.isNotEmpty;

  /// Core'da güncelleme, oluşturmayla aynı kurala bağlı.
  bool canEditEvent(String ownerTeam) =>
      ownerTeam.isNotEmpty &&
      (canWriteAsPrivileged ||
          leaderTeams.contains(ownerTeam) ||
          (ownerTeam == _everyMemberCanCreateTeam && isInGroup(ownerTeam)));

  /// GECEKODU üyeleri düzenleyebiliyor ama silemiyor.
  bool canDeleteEvent(String ownerTeam) =>
      ownerTeam.isNotEmpty &&
      (canWriteAsPrivileged || leaderTeams.contains(ownerTeam));

  /// Kapıda okutabilir mi (core `allowDoorCheckIn`): YK/ADMIN, sahip ekibin
  /// lideri ya da etkinliğin kapı görevlisi. `team_door_scan` açık ekiplerin
  /// üyeleri token'da görünmüyor; onlar `/v1/door/events`'ten anlaşılıyor.
  bool canCheckIn({
    required String ownerTeam,
    List<String> doorStaffIds = const [],
  }) =>
      canWriteAsPrivileged ||
      (ownerTeam.isNotEmpty && leaderTeams.contains(ownerTeam)) ||
      (id.isNotEmpty && doorStaffIds.contains(id));

  String get usernameDisplay =>
      preferredUsername.isEmpty ? '' : '@$preferredUsername';
}

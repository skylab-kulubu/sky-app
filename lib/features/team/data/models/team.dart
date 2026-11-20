import 'package:sky_app/core/constants/app_assets.dart';
import 'package:sky_app/core/services/links_service.dart';

/// SkyCMS'teki bir AR-GE ekibi (`teams`). Alımdan yalnız açık/kapalı
/// kullanılıyor; başvuru adresi CMS'teki `applyUrl` değil kısa link
/// ([applyUrl]). Üyeler core'dan ayrıca geliyor.
class Team {
  const Team({
    required this.slug,
    required this.description,
    required this.longDescription,
    required this.topics,
    required this.stack,
    required this.works,
    this.version = 0,
    this.data = const {},
  });

  /// CMS anahtarı, küçük harf (`mobilab`); core ve Keycloak adı [key].
  final String slug;

  final String description;

  /// Zengin metin; gösterirken [longDescriptionText] kullanılmalı.
  final String longDescription;

  final List<String> topics;
  final List<String> stack;
  final List<TeamWork> works;

  /// Kayıtta gönderiliyor; arada biri değiştirdiyse CMS 409 dönüyor.
  final int version;

  /// Ham `data`. Gösterilmeyen alım alanları buradan aynen geri gönderiliyor;
  /// gönderilmezse CMS siliyor, `recruiting` zorunlu olduğu için reddediyor.
  final Map<String, dynamic> data;

  factory Team.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? const {};

    return Team(
      slug: json['slug'] as String? ?? '',
      version: (json['version'] as num?)?.toInt() ?? 0,
      data: data,
      description: data['desc'] as String? ?? '',
      longDescription: data['longDesc'] as String? ?? '',
      topics: _strings(data['topics']),
      stack: _strings(data['stack']),
      works: (data['works'] as List<dynamic>? ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(TeamWork.fromJson)
          .where((work) => work.title.isNotEmpty)
          .toList(growable: false),
    );
  }

  /// CMS'e gidecek `data`: yalnız şemadaki yazılabilir alanlar (bilinmeyen alan
  /// reddediliyor), alım alanları olduğu gibi.
  Map<String, dynamic> toCmsData() {
    return {
      'desc': description,
      'longDesc': longDescription,
      'topics': topics,
      'stack': stack,
      'works': [for (final work in works) work.toJson()],
      'recruiting': isRecruiting,
      'recruitingFor': data['recruitingFor'] as String? ?? '',
      'applyUrl': data['applyUrl'] as String? ?? '',
    };
  }

  Team copyWith({
    String? description,
    String? longDescription,
    List<String>? topics,
    List<String>? stack,
    List<TeamWork>? works,
    bool? isRecruiting,
  }) {
    return Team(
      slug: slug,
      description: description ?? this.description,
      longDescription: longDescription ?? this.longDescription,
      topics: topics ?? this.topics,
      stack: stack ?? this.stack,
      works: works ?? this.works,
      version: version,
      data: isRecruiting == null ? data : {...data, 'recruiting': isRecruiting},
    );
  }

  /// CMS'te ad alanı yok; kulüpte ekipler büyük harfle yazılıyor.
  String get name => slug.toUpperCase();

  /// Keycloak grup adı; core'da `/v1/teams/{key}/members`, token'da
  /// `User.teams` bununla eşleşiyor.
  String get key => slug.toUpperCase();

  bool get isRecruiting => data['recruiting'] == true;

  /// Başvuru formuna giden kısa link (`skyl.app/<slug>`); form değişince
  /// uygulamaya dokunmak gerekmesin.
  String get applyUrl => '${LinksService.shortLinkBase}/$slug';

  String get aboutText {
    final long = longDescriptionText;
    return long.isNotEmpty ? long : description;
  }

  /// Etiketleri ayıklanmış düz metin; editör HTML üretirse paragraf sonları
  /// korunup etiketler siliniyor.
  String get longDescriptionText {
    if (longDescription.trim().isEmpty) return '';

    return longDescription
        .replaceAll(RegExp(r'<br\s*/?>|</p>', caseSensitive: false), '\n')
        .replaceAll(RegExp(r'<[^>]+>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
  }

  String? get logo => _logos[slug];

  /// Açık temada kullanılan tek renkli sürüm; yalnız logosunda beyaz öğe olan
  /// ekiplerde.
  String? get lightThemeLogo => _lightThemeLogos[slug];

  static const Map<String, String> _logos = {
    'airlab': AppAssets.airlabLogo,
    'algolab': AppAssets.algolabLogo,
    'chainlab': AppAssets.chainlabLogo,
    'gamelab': AppAssets.gamelabLogo,
    'mobilab': AppAssets.mobilabLogo,
    'skysec': AppAssets.skysecLogo,
    'skysis': AppAssets.skysisLogo,
    'weblab': AppAssets.weblabLogo,
  };

  static const Map<String, String> _lightThemeLogos = {
    'algolab': AppAssets.algolabLogoMono,
    'gamelab': AppAssets.gamelabLogoMono,
  };

  static List<String> _strings(Object? value) =>
      (value as List<dynamic>? ?? const [])
          .whereType<String>()
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList(growable: false);
}

class TeamWork {
  const TeamWork({
    required this.title,
    required this.description,
    required this.image,
    required this.tags,
  });

  final String title;
  final String description;

  final String image;
  final List<String> tags;

  factory TeamWork.fromJson(Map<String, dynamic> json) {
    return TeamWork(
      title: (json['title'] as String? ?? '').trim(),
      description: (json['description'] as String? ?? '').trim(),
      image: (json['image'] as String? ?? '').trim(),
      tags: Team._strings(json['tags']),
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
    'image': image,
    'tags': tags,
  };
}

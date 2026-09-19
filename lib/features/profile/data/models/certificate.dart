import 'package:sky_app/core/extensions/date_time_extensions.dart';

/// Sertifikanın durumu. Bilinmeyen (ileride eklenecek) durumlar hiçbir zaman
/// geçerli gösterilmiyor.
enum CertificateStatus { valid, revoked, unknown }

/// Kullanıcıya verilmiş sertifika (core `GET /v1/certificates/me`,
/// `docs/mobile-certificates-v2.md`).
///
/// Uygulama şablon ya da üretimle ilgilenmiyor; yalnızca listeliyor ve
/// core'un verdiği adresleri açıyor. Adresler kurulmuyor, olduğu gibi
/// kullanılıyor.
class Certificate {
  const Certificate({
    required this.serial,
    required this.eventName,
    required this.ownerTeam,
    required this.status,
    required this.issuedAt,
    required this.verifyUrl,
    required this.shareTitle,
    required this.shareText,
    required this.shareUrl,
    this.revokedAt,
    this.pdfUrl,
  });

  factory Certificate.fromJson(Map<String, dynamic> json) {
    final event = json['event'] as Map<String, dynamic>? ?? const {};
    final share = json['share'] as Map<String, dynamic>? ?? const {};
    return Certificate(
      serial: json['serial'] as String? ?? '',
      eventName: (event['name'] as String? ?? '').trim(),
      ownerTeam: (event['ownerTeam'] as String? ?? '').trim(),
      status: switch (json['status']) {
        'valid' => CertificateStatus.valid,
        'revoked' => CertificateStatus.revoked,
        _ => CertificateStatus.unknown,
      },
      issuedAt: ApiDateTime.parse(json['issuedAt'] as String?),
      revokedAt: ApiDateTime.parse(json['revokedAt'] as String?),
      pdfUrl: _https(json['pdfUrl']),
      verifyUrl: _https(json['verifyUrl']),
      shareTitle: share['title'] as String? ?? '',
      shareText: share['text'] as String? ?? '',
      shareUrl: _https(share['url']),
    );
  }

  final String serial;
  final String eventName;
  final String ownerTeam;
  final CertificateStatus status;
  final DateTime? issuedAt;
  final DateTime? revokedAt;

  /// Yalnızca geçerli sertifikada; iptal edilende yok.
  final String? pdfUrl;

  /// Herkese açık doğrulama sayfası (`https://skyl.app/c/{serial}`).
  final String? verifyUrl;

  final String shareTitle;
  final String shareText;

  /// Paylaşılan adres doğrulama sayfası, PDF değil.
  final String? shareUrl;

  bool get isValid => status == CertificateStatus.valid;

  /// Yalnızca `https` adresler açılıyor; başka biçimdeki değer yok sayılıyor.
  static String? _https(Object? value) {
    if (value is! String) return null;
    final uri = Uri.tryParse(value.trim());
    if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) return null;
    return uri.toString();
  }

  static const Set<String> _clubWideTeams = {'', 'YK', 'DK'};

  /// Veren: ekip boşsa, YK ya da DK ise "SKY LAB", değilse ekibin adı.
  String get issuerLabel =>
      _clubWideTeams.contains(ownerTeam) ? 'SKY LAB' : ownerTeam;

  static const List<String> _months = [
    'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran', //
    'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık',
  ];

  /// "24 Eylül 2026"; tarih yoksa boş.
  String get issuedLabel {
    final date = issuedAt;
    if (date == null) return '';
    return '${date.day} ${_months[date.month - 1]} ${date.year}';
  }

  /// Listede adın altındaki satır: "SKY LAB  •  24 Eylül 2026".
  String get subtitle =>
      [issuerLabel, issuedLabel].where((part) => part.isNotEmpty).join('  •  ');
}

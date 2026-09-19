import 'package:sky_app/core/extensions/date_time_extensions.dart';
import 'package:sky_app/features/calendar/data/models/event_model.dart';

/// Kullanıcıya verilmiş katılım sertifikası (core `GET /v1/certificates/me`).
///
/// Sertifikayı core, etkinliğin katılım kuralına göre (`attendanceRule`)
/// oturum yoklamalarından hesaplayıp veriyor; uygulama yalnızca listeliyor.
class Certificate {
  const Certificate({
    required this.serial,
    required this.eventName,
    required this.ownerTeam,
    required this.verifyUrl,
    required this.issuedAt,
    required this.revoked,
  });

  factory Certificate.fromJson(Map<String, dynamic> json) {
    return Certificate(
      serial: json['serial'] as String? ?? '',
      eventName: json['eventName'] as String? ?? '',
      ownerTeam: json['ownerTeam'] as String? ?? '',
      verifyUrl: json['verifyUrl'] as String? ?? '',
      issuedAt: ApiDateTime.parse(json['issuedAt'] as String?),
      revoked: json['revokedAt'] != null,
    );
  }

  /// Doğrulama kodu; sertifikanın herkese açık adresinde kullanılıyor.
  final String serial;
  final String eventName;
  final String ownerTeam;

  /// Herkese açık doğrulama adresi (`/v1/certificates/verify/{serial}`).
  final String verifyUrl;
  final DateTime? issuedAt;

  /// İptal edilmiş sertifika listede gösterilmiyor.
  final bool revoked;

  /// Sertifikanın PDF'i; girişsiz açılıyor.
  String get pdfUrl => verifyUrl.isEmpty ? '' : '$verifyUrl/pdf';

  /// Veren ekip; YK ve DK "SKY LAB" olarak.
  String get issuerLabel => EventModel.ownerLabelFor(ownerTeam);

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

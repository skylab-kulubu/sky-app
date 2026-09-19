import 'package:sky_app/core/extensions/date_time_extensions.dart';

/// Kapıda okutulan imzalı SkyPass kodu (core `POST /v1/skypass/qr`).
///
/// İçerik sunucunun imzaladığı kısa ömürlü bir belirteç; kapı görevlisi
/// imzayı doğruluyor. Süresi dolan kod geçmiyor, bu yüzden kart onu
/// dolmadan yeniliyor. Eski `SKYPASS:<no>:<ad>` biçimi artık reddediliyor.
class SkyPassToken {
  const SkyPassToken({required this.value, required this.expiresAt});

  factory SkyPassToken.fromJson(Map<String, dynamic> json) {
    return SkyPassToken(
      value: json['token'] as String? ?? '',
      expiresAt: ApiDateTime.parse(json['exp'] as String?) ?? DateTime.now(),
    );
  }

  /// QR'a yazılan değer.
  final String value;
  final DateTime expiresAt;

  /// Verilen süre içinde dolacak mı; dolacaksa yenisi alınmalı.
  bool expiresWithin(Duration margin) =>
      DateTime.now().add(margin).isAfter(expiresAt);
}

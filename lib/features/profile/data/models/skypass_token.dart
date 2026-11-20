import 'package:sky_app/core/extensions/date_time_extensions.dart';

/// Kapıda okutulan imzalı SkyPass kodu (`POST /v1/skypass/qr`); kısa ömürlü,
/// kart onu dolmadan yeniliyor.
class SkyPassToken {
  const SkyPassToken({required this.value, required this.expiresAt});

  factory SkyPassToken.fromJson(Map<String, dynamic> json) {
    return SkyPassToken(
      value: json['token'] as String? ?? '',
      expiresAt: ApiDateTime.parse(json['exp'] as String?) ?? DateTime.now(),
    );
  }

  final String value;
  final DateTime expiresAt;

  /// Verilen süre içinde dolacak mı; dolacaksa yenisi alınmalı.
  bool expiresWithin(Duration margin) =>
      DateTime.now().add(margin).isAfter(expiresAt);
}

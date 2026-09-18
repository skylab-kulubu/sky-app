/// Core API'nin tarih biçimi: saat dilimli RFC 3339
/// (`2026-09-20T15:00:00Z`).
///
/// Gönderirken UTC'ye çevriliyor; okurken yerel saate. `DateTime.parse`
/// `Z` ile biten değeri UTC döndürüyor ve saat alanları öyle okunursa
/// Türkiye'de üç saat geri görünüyor; [ApiDateTime.parse] bunu önlüyor.
extension ApiDateTime on DateTime {
  String toApiString() => toUtc().toIso8601String();

  /// Okunamayan ya da boş değerde `null`.
  static DateTime? parse(String? value) {
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value)?.toLocal();
  }
}

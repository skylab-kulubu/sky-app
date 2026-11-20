/// Core'un tarih biçimi: saat dilimli RFC 3339 (`2026-09-20T15:00:00Z`).
///
/// Gönderirken UTC'ye, okurken yerel saate çevriliyor: `DateTime.parse` `Z`'li
/// değeri UTC bıraktığı için saatler üç saat geri görünüyordu.
extension ApiDateTime on DateTime {
  String toApiString() => toUtc().toIso8601String();

  /// Okunamayan ya da boş değerde `null`.
  static DateTime? parse(String? value) {
    if (value == null || value.isEmpty) return null;
    return DateTime.tryParse(value)?.toLocal();
  }
}

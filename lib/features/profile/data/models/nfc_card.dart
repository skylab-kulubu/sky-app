/// YTÜ öğrenci kartı: Mifare Classic 1K, ISO 14443-3A, 4 baytlık (8 HEX) UID.
class NfcCard {
  final String rawUid;
  final DateTime scannedAt;

  const NfcCard({required this.rawUid, required this.scannedAt});

  /// Turnike / veritabanı temiz HEX formatı (örn: `"225FC4C9"`).
  String get normalizedHex {
    return rawUid.replaceAll(RegExp(r'[^0-9a-fA-F]'), '').toUpperCase();
  }

  /// Görsel arayüz formatı (örn: `"22:5F:C4:C9"`).
  String get formattedHex {
    final clean = normalizedHex;
    final buffer = StringBuffer();
    for (int i = 0; i < clean.length; i += 2) {
      if (i > 0) buffer.write(':');
      if (i + 2 <= clean.length) {
        buffer.write(clean.substring(i, i + 2));
      } else {
        buffer.write(clean.substring(i));
      }
    }
    return buffer.toString();
  }

  int get byteLength => normalizedHex.length ~/ 2;

  /// Okumadan kullanılabilir bir UID çıktı mı. Kartın gerçekten YTÜ kartı
  /// olduğu istemcide doğrulanamıyor: UID kimin olduğunu söylemiyor, ATQA/SAK
  /// yalnız Android'de dolu ve iOS Classic'i tanımıyor. Tek kontrol UID'nin
  /// okunabilmesi; `poll` çözemediğinde `id` `"unknown"` dönüyor ve
  /// [normalizedHex] onu boşaltıyor.
  bool get hasReadableUid => normalizedHex.isNotEmpty;
}

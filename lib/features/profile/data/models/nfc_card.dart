/// Yıldız Teknik Üniversitesi (YTÜ) Öğrenci Kartı veri modeli.
///
/// YTÜ Kampüs Kartları: Mifare Classic 1K, ISO 14443-3A, 4-Byte (8 HEX
/// karakter) UID kullanır. Turnike ve yoklama sistemiyle uyumlu normalize
/// formatları sunar.
class NfcCard {
  final String rawUid;
  final String cardType;
  final String cardStandard;
  final String? sak;
  final String? atqa;
  final DateTime scannedAt;

  const NfcCard({
    required this.rawUid,
    required this.cardType,
    required this.cardStandard,
    this.sak,
    this.atqa,
    required this.scannedAt,
  });

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

  /// UID Byte uzunluğu (YTÜ kartları için 4 Byte).
  int get byteLength => normalizedHex.length ~/ 2;

  /// Kartın geçerli bir YTÜ Öğrenci Kartı (Mifare Classic 1K / 4-Byte
  /// ISO 14443-3A) olup olmadığını doğrular.
  bool get isYtuStudentCard {
    return byteLength == 4 &&
        (cardStandard.contains('14443') || cardType.contains('mifare'));
  }
}

/// Yıldız Teknik Üniversitesi (YTÜ) Öğrenci Kartı veri modeli.
///
/// YTÜ Kampüs Kartları: Mifare Classic 1K, ISO 14443-3A, 4-Byte (8 HEX
/// karakter) UID kullanır.
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

  /// UID Byte uzunluğu (YTÜ kartları için 4 Byte).
  int get byteLength => normalizedHex.length ~/ 2;

  /// Okumadan geriye kullanılabilir bir UID çıkıp çıkmadığı.
  ///
  /// Kartın gerçekten bir YTÜ kartı olduğu istemcide **doğrulanamaz**.
  /// Kimlik doğrulaması yapmadan okunabilen tek anlamlı veri UID; kartın
  /// kime ait olduğunu söylemiyor ve piyasadaki her Mifare Classic 1K
  /// kart (otel, toplu taşıma, kargo etiketi) aynı formatta. UID'nin bir
  /// öğrenciye ait olup olmadığı ancak sunucuda, kayıtla eşleştirilerek
  /// anlaşılır. Ki bu da imkansız :)
  ///
  /// Paketin diğer alanları da elemiyor: ATQA/SAK yalnızca Android'de
  /// doluyor, kart tipi ve standardı ise iki platformda ayrışıyor —
  /// CoreNFC'nin `NFCMiFareFamily` enum'unda Classic olmadığı için iOS bir
  /// YTÜ kartına `unknown` diyor.
  ///
  /// Geriye kalan tek gerçek kontrol UID'nin okunabilmiş olması:
  /// `FlutterNfcKit.poll` kimliği çözemediğinde `id` alanını `"unknown"`
  /// döndürüyor, o da [normalizedHex] süzgecinden boş geçiyor.
  bool get hasReadableUid => normalizedHex.isNotEmpty;
}

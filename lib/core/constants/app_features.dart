/// Sürüme göre açılıp kapanan özellikler.
class AppFeatures {
  /// Öğrenci kartı (NFC): profilde "Öğrenci Kartını Eşle" ve kapıda
  /// "Öğrenci Kartı" ile giriş. Kartın okunması için üniversitenin Bilgi
  /// İşlem Daire Başkanlığı'na başvuruldu; onay gelene kadar kapalı
  /// (v0.1). Kapalıyken profilde yerinde "QR Okut" duruyor, kapı ekranı
  /// yalnız QR okutuyor.
  static const bool studentCard = false;
}

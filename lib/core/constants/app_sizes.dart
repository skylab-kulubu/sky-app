class AppSizes {
  static const iconSmall = 18.0;
  static const iconMedium = 22.0;
  static const icon = 26.0;
  static const iconLarge = 40.0;

  /// Profildeki hızlı eylem dairesi ve appbar avatarı.
  static const quickActionCircle = 56.0;

  /// Liste tile'larındaki kare görsel (haber, etkinlik). Metin bloğundan
  /// kasıtlı olarak yüksek: tile yüksekliğini hep görsel belirlesin ve tüm
  /// satırlar eşit boyda kalsın.
  static const thumbnail = 72.0;

  static const settingsIconCircle = 36.0;

  /// Hesap satırının avatarı; ikon dairesinden bilerek büyük.
  static const accountTileAvatar = 48.0;

  /// Sheet başlığındaki kapatma butonunun genişliği; başlığın tam ortada
  /// kalması için karşı tarafa aynı boşluk bırakılıyor.
  static const sheetHeaderAction = 48.0;

  /// Ayracın sol boşluğu: ikonlu satırda metnin başladığı yer (ikon dairesi +
  /// aradaki boşluk + satırın yatay boşluğu).
  static const double dividerIndentIcon = 64.0;
  static const double dividerIndent = 16.0;

  static const authLogo = 280.0;

  static const notificationCircle = 44.0;

  /// Aktivite satırının ikon dairesi; satır kartsız ve iki satırlık olduğu için
  /// ayarlardakinden büyük.
  static const activityIconCircle = 44.0;

  /// Liste kartındaki kapak oranı; kare görsel satırları gereğinden uzatıyordu.
  static const eventCoverAspect = 16 / 10;

  static const badgeDot = 8.0;

  static const double smallSpace = 2.0;
  static const double midSpace = 8.0;
  static const double bigSpace = 12.0;

  /// [bigSpace] ile [sectionSpace] arası: bir bileşen ile ardından gelen eylem
  /// satırı arasında (SkyPass kartı → hızlı eylemler).
  static const double largeSpace = 24.0;

  /// İki bölüm arasındaki boşluk (detay sayfasındaki bilgi kartı ile
  /// açıklama gibi).
  static const double sectionSpace = 40.0;

  /// Yüzen navbar'ın altında kalmasın diye listelerin sonuna eklenen pay.
  static const double navBarClearance = 100.0;
}

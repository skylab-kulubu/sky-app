class AppSizes {
  static const iconSmall = 18.0;
  static const iconMedium = 22.0;
  static const icon = 26.0;
  static const iconLarge = 40.0;

  /// Menü grid'indeki ikon kutusunun kenar uzunluğu ve iç boşluğu.
  static const iconBoxLarge = 52.0;
  static const iconBoxLargePadding = 13.0;

  /// Profildeki hızlı eylem dairesi ve appbar avatarı.
  static const quickActionCircle = 56.0;

  /// Liste tile'larındaki kare görsel (haber, etkinlik). Metin bloğundan
  /// kasıtlı olarak yüksek: tile yüksekliğini hep görsel belirlesin ve tüm
  /// satırlar eşit boyda kalsın.
  static const thumbnail = 72.0;

  /// Ayarlar satırındaki dolu renkli ikon dairesi.
  static const settingsIconCircle = 36.0;

  /// Ayarların en üstündeki hesap satırının avatarı; ikon dairesinden büyük,
  /// satır oradaki sıradan bir ayar değil kullanıcının kendisi.
  static const accountTileAvatar = 48.0;

  /// Hesap sayfasının başındaki büyük avatar.
  static const accountAvatar = 88.0;

  /// Grup içindeki ayracın sol boşluğu. İkonlu satırlarda ikon dairesinin
  /// sağından ([settingsIconCircle] + aradaki boşluk + satırın kendi yatay
  /// boşluğu), ikonsuz satırlarda satırın boşluğundan başlar; ayraç her iki
  /// durumda da metinle hizalanır.
  static const double dividerIndentIcon = 64.0;
  static const double dividerIndent = 16.0;

  /// Giriş sayfasında ortada duran logo animasyonunun kenar uzunluğu.
  static const authLogo = 280.0;

  /// Bildirim satırındaki yuvarlak ikon dairesi.
  static const notificationCircle = 44.0;

  /// Profildeki aktivite satırının ikon dairesi. Ayarlardakinden büyük:
  /// o satırlar kart içinde ve tek satırlık, bu satır kartsız ve iki
  /// satırlık metin taşıyor.
  static const activityIconCircle = 44.0;

  /// Etkinlik kartındaki kapak görselinin en/boy oranı. Detay sayfasındaki
  /// kapak kare; liste kartında kare bir görsel satırları gereğinden uzun
  /// yapıyor.
  static const eventCoverAspect = 16 / 10;

  /// Okunmamış bildirim rozeti.
  static const badgeDot = 8.0;

  static const double smallSpace = 2.0;
  static const double midSpace = 8.0;
  static const double bigSpace = 12.0;

  /// [bigSpace] ile [sectionSpace] arasındaki ara boşluk: bir bileşen ile
  /// onu izleyen eylem satırı arasında kullanılır (SkyPass kartı → hızlı
  /// eylemler).
  static const double largeSpace = 24.0;

  /// İki bölüm arasındaki boşluk (detay sayfasındaki bilgi kartı ile
  /// açıklama gibi).
  static const double sectionSpace = 40.0;

  /// Yüzen navbar'ın altında kalmasın diye listelerin sonuna eklenen pay.
  static const double navBarClearance = 100.0;
}

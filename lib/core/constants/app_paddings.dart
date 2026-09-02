import 'package:flutter/widgets.dart';

class AppPaddings {
  static const mainPaddingAll = EdgeInsets.all(16);
  static const mainPaddingHorizontal = EdgeInsets.symmetric(horizontal: 16);
  static const mainPaddingVertical = EdgeInsets.symmetric(vertical: 16);
  static const newsTile = EdgeInsets.symmetric(horizontal: 16, vertical: 8);

  static const all6 = EdgeInsets.all(6);

  static const horizontal8 = EdgeInsets.symmetric(horizontal: 8);
  static const horizontal16Vertical8 = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 8,
  );
  static const cardContentPaddingHorizontal = EdgeInsets.symmetric(
    horizontal: 8,
  );
  static const buttonInternalPadding = EdgeInsets.symmetric(vertical: 10);

  /// AppBar leading'inin sol kenar boşluğu; actions'ınkiyle simetrik.
  static const appBarLeading = EdgeInsets.only(left: 16);

  /// AppBar actions'ının sağ kenar boşluğu. Başlığın soldaki
  /// `titleSpacing` (16) değeriyle simetrik olsun diye aynı.
  static const appBarActions = EdgeInsets.only(right: 16);

  /// Yüzen navbar'ın ekran kenarlarına uzaklığı.
  static const navBar = EdgeInsets.only(
    left: 16,
    right: 16,
    bottom: 30,
    top: 10,
  );

  /// SkyPass kartının iç boşluğu.
  static const skyPassCard = EdgeInsets.all(20);

  /// SkyPass'in arka yüzündeki QR'ın beyaz zemini ile deseni arasındaki
  /// boşluk (QR'ın sessiz bölgesi).
  static const skyPassQr = EdgeInsets.all(8);

  /// Ayarlar satırının iç boşluğu. Satır yüksekliğini metin değil ikon
  /// dairesi belirlediği için dikeyde dar: 36 + 2×8 = 52.
  static const settingsTile = EdgeInsets.symmetric(horizontal: 16, vertical: 8);

  /// Etiket + değer satırının iç boşluğu (hesap bilgileri, sertifikalar).
  /// İkon dairesi olmadığı için yüksekliği metin belirliyor; [settingsTile]
  /// kadar daraltılırsa satır sıkışık görünüyor.
  static const infoTile = EdgeInsets.symmetric(horizontal: 16, vertical: 12);

  /// Ayarların en üstündeki hesap satırının iç boşluğu. Avatarı diğer
  /// satırların ikon dairesinden büyük; satır bilinçli olarak onlardan uzun
  /// duruyor, listenin başındaki kullanıcı kimliği sıradan bir ayar değil.
  static const accountTile = EdgeInsets.symmetric(horizontal: 16, vertical: 10);

  /// Hesap sayfasının başındaki avatar + ad bloğu. Yatayda [sectionHeader]
  /// ile hizalı kalsın diye 4.
  static const accountHeader = EdgeInsets.only(left: 4, right: 4, bottom: 4);

  /// Hesap sayfasının altındaki bilgilendirme notu.
  static const accountNote = EdgeInsets.only(left: 4, right: 4, top: 20);

  /// Hesap sayfasındaki ekip rozeti.
  static const teamChip = EdgeInsets.symmetric(horizontal: 12, vertical: 6);

  /// Giriş sayfasının içeriği; sayfada tek bir sütun olduğu için ana
  /// boşluktan geniş.
  static const authContent = EdgeInsets.symmetric(horizontal: 32);

  /// Ayarların en altındaki "Developed by" künyesi.
  static const credit = EdgeInsets.only(top: 36, bottom: 8);

  /// Etkinlik kartının iç boşluğu; kapak görselinin dört yanında kart
  /// zemininden bir çerçeve kalmasını sağlıyor. Köşe rozetleri görselin
  /// dışına taştığı için bu boşluk onlara da yer açıyor.
  static const eventCard = EdgeInsets.all(12);

  /// Etkinlik kartında görselin altındaki metin bloğunun ek boşluğu; metin
  /// görselden biraz daha içeride başlasın diye.
  static const eventCardContent = EdgeInsets.fromLTRB(4, 12, 4, 4);

  /// Bildirim satırının iç boşluğu. Sol dairesi haber satırının görselinden
  /// alçak olduğu için dikeyde [newsTile]'dan ferah.
  static const notificationTile = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 12,
  );

  /// Profildeki aktivite satırının iç boşluğu. Yatayda boşluk yok: sayfanın
  /// kendi kenar boşluğu zaten var, satır onu ikinci kez eklemiyor.
  static const activityTile = EdgeInsets.symmetric(vertical: 8);

  /// Ayarlar bölüm başlığının boşluğu.
  static const sectionHeader = EdgeInsets.only(left: 4, top: 24, bottom: 8);

  /// NFC okutma overlay'inde ekranın altında duran durum metninin, güvenli
  /// alanın üstünde bıraktığı pay. Merkezdeki kart yukarı çekilirken metnin
  /// altında kalmasını sağlayacak kadar geniş.
  static const nfcStatus = EdgeInsets.only(bottom: 56);

  /// Navbar hap'ının, öğelerini saran iç boşluğu.
  static const navBarContent = EdgeInsets.all(8);

  /// Navbar öğesinin iç boşluğu. Dikey değer, ikon boyutuyla birlikte
  /// öğe yüksekliğini 48px'e tamamlıyor.
  static const navItem = EdgeInsets.symmetric(horizontal: 12, vertical: 11);

  /// Seçili navbar öğesinin iç boşluğu; hap'ın etiketiyle birlikte daha
  /// ferah durması için yatayda [navItem]'dan geniş.
  static const navItemSelected = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 11,
  );
}

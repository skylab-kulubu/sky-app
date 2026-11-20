import 'package:flutter/widgets.dart';

class AppPaddings {
  static const mainPaddingAll = EdgeInsets.all(16);
  static const mainPaddingHorizontal = EdgeInsets.symmetric(horizontal: 16);
  static const mainPaddingVertical = EdgeInsets.symmetric(vertical: 16);
  static const newsTile = EdgeInsets.symmetric(horizontal: 16, vertical: 8);

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

  /// AppBar actions'ının sağ boşluğu; soldaki `titleSpacing` (16) ile simetrik.
  static const appBarActions = EdgeInsets.only(right: 16);

  /// AppBar'daki arama kutusunun metin boşluğu. Dikeyde boşluk yok; metin
  /// alanı kutunun içinde `Center` ile ortalanıyor.
  static const appBarSearchField = EdgeInsets.symmetric(horizontal: 16);

  /// Yüzen navbar'ın ekran kenarlarına uzaklığı.
  static const navBar = EdgeInsets.only(
    left: 16,
    right: 16,
    bottom: 30,
    top: 10,
  );

  static const skyPassCard = EdgeInsets.all(20);

  /// QR'ın sessiz bölgesi: beyaz zemin ile desen arası.
  static const skyPassQr = EdgeInsets.all(8);

  /// Ayarlar satırının iç boşluğu. Satır yüksekliğini metin değil ikon
  /// dairesi belirlediği için dikeyde dar: 36 + 2×8 = 52.
  static const settingsTile = EdgeInsets.symmetric(horizontal: 16, vertical: 8);

  /// Etiket + değer satırı (hesap bilgileri, sertifikalar). İkon dairesi
  /// olmadığından [settingsTile]'dan ferah; o kadar dar olunca sıkışıyor.
  static const infoTile = EdgeInsets.symmetric(horizontal: 16, vertical: 12);

  /// Hesap satırı; avatarı büyük olduğu için diğer satırlardan bilerek uzun.
  static const accountTile = EdgeInsets.symmetric(horizontal: 16, vertical: 10);

  /// Sheet başlığı: solda kapatma butonu, ortada başlık.
  static const sheetHeader = EdgeInsets.fromLTRB(4, 8, 4, 8);

  static const teamChip = EdgeInsets.symmetric(horizontal: 12, vertical: 6);

  /// Giriş sayfasının içeriği; sayfada tek bir sütun olduğu için ana
  /// boşluktan geniş.
  static const authContent = EdgeInsets.symmetric(horizontal: 32);

  /// Ayarların en altındaki "Developed by" künyesi.
  static const credit = EdgeInsets.only(top: 36, bottom: 8);

  /// Etkinlik kartının iç boşluğu; kapağın çevresinde çerçeve bırakıp köşe
  /// rozetlerine yer açıyor.
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

  static const sectionHeader = EdgeInsets.only(left: 4, top: 24, bottom: 8);

  /// NFC overlay'inin alttaki durum metni; yukarı çekilen kart metnin üstüne
  /// binmesin diye geniş.
  static const nfcStatus = EdgeInsets.only(bottom: 56);

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

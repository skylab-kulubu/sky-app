import 'package:flutter/widgets.dart';

class AppPaddings {
  static const mainPaddingAll = EdgeInsets.all(16);
  static const mainPaddingHorizontal = EdgeInsets.symmetric(horizontal: 16);
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

  /// Hesap bilgisi satırının iç boşluğu; etiket ve değer alt alta durduğu
  /// için dikeyde daha ferah.
  static const profileInfoRow = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 14,
  );

  /// Ayarlar satırının iç boşluğu.
  static const settingsTile = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 12,
  );

  /// Ayarlar bölüm başlığının boşluğu.
  static const sectionHeader = EdgeInsets.only(left: 4, top: 24, bottom: 8);

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

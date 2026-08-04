import 'package:flutter/widgets.dart';

class AppPaddings {
  static const mainPaddingAll = EdgeInsets.all(16);

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

  /// AppBar actions'ının sağ kenar boşluğu. Başlığın soldaki
  /// `titleSpacing` (16) değeriyle simetrik olsun diye aynı.
  static const appBarActions = EdgeInsets.only(right: 16);
}

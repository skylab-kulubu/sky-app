import 'package:flutter/material.dart';

class AppRadiuses {
  static const double buttonRadius = 100;
  static const double navbar = 24;
  static const double navitem = 16;
  static const double navIndicator = 18;

  static const double cardRadius = 16;
  static const double containerRadius = 10;
  //static const double buttonRadius = 8;
  static const BorderRadius cardBorderRadius = BorderRadius.all(
    Radius.circular(cardRadius),
  );
  static const BorderRadius containerBorderRadius = BorderRadius.all(
    Radius.circular(containerRadius),
  );
  static const BorderRadius buttonBorderRadius = BorderRadius.all(
    Radius.circular(8),
  );
  static const double tile = 16;
  static const double iconBox = 12;

  /// Kutunun yarı yüksekliğini aştığı için çizimde otomatik olarak tam yuvarlak
  /// (stadium) hâline iner. Yükseklik değişince peşinden güncellemek gerekmez.
  static const double stadium = 999;
  static const BorderRadius stadiumBorderRadius = BorderRadius.all(
    Radius.circular(stadium),
  );
}

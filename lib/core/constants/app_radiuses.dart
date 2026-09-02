import 'package:flutter/material.dart';

class AppRadiuses {
  static const double cardRadius = 24;
  static const BorderRadius cardBorderRadius = BorderRadius.all(
    Radius.circular(cardRadius),
  );
  static const double tile = 16;

  /// Kart içindeki görselin köşeleri. Kartın kendi yarıçapının içine
  /// oturduğu için ondan küçük; eşit olsaydı iç köşe dıştakinden daha
  /// yuvarlak görünürdü.
  static const double innerTile = 12;
  static const double iconBox = 12;

  /// SkyPass kartı ve hızlı eylem dairesi.
  static const double skyPassCard = 24;
  static const BorderRadius skyPassCardBorderRadius = BorderRadius.all(
    Radius.circular(skyPassCard),
  );

  /// Liste tile'larındaki kare görselin köşeleri.
  static const double thumbnail = 14;

  /// Bottom sheet'in üst köşeleri.
  static const BorderRadius sheetBorderRadius = BorderRadius.vertical(
    top: Radius.circular(24),
  );

  /// Kutunun yarı yüksekliğini aştığı için çizimde otomatik olarak tam yuvarlak
  /// (stadium) hâline iner. Yükseklik değişince peşinden güncellemek gerekmez.
  static const double stadium = 999;
  static const BorderRadius stadiumBorderRadius = BorderRadius.all(
    Radius.circular(stadium),
  );
}

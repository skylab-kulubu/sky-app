import 'dart:math';
import 'package:flutter/material.dart';

extension ScaffoldExtension on BuildContext {
  void openDrawer() => Scaffold.of(this).openDrawer();
  void closeDrawer() => Scaffold.of(this).closeDrawer();
}

extension ContextExtension on BuildContext {
  Container get randomContainer => Container(
    height: 100,
    width: double.infinity,
    margin: EdgeInsets.symmetric(vertical: 8.0),
    color: Colors.primaries[Random().nextInt(Colors.primaries.length)],
  );

  Color get randomColor =>
      Colors.primaries[Random().nextInt(Colors.primaries.length)];
}

extension SizeExtension on BuildContext {
  Size get size => MediaQuery.sizeOf(this);

  EdgeInsets get padding => MediaQuery.paddingOf(this);

  double get height =>
      size.height - padding.bottom - padding.top - 56 /* appbar height*/;

  double get width => size.width;

  double dynamicHeight(double value) => height * value;

  double dynamicWidth(double value) => width * value;
}

extension ThemeExtension on BuildContext {
  ThemeData get theme => Theme.of(this);

  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  TextTheme get textTheme => Theme.of(this).textTheme;

  TextTheme get primaryTextTheme => Theme.of(this).primaryTextTheme;
}

/// Temaya göre değişen renkler.
///
/// Marka ve vurgu renkleri (kırmızı, yeşil, lila ...) `AppColors` içinde
/// sabit kalır; zemin, metin ve ayraç gibi açık/koyu temada farklılaşan
/// her şey buradan okunur.
extension AppColorExtension on BuildContext {
  /// Sayfa zemini.
  Color get backgroundColor => theme.scaffoldBackgroundColor;

  /// Kart, tile ve sheet zemini.
  Color get tileColor => colorScheme.surfaceContainer;

  /// Zeminden bir tık yükseltilmiş yüzey: buton, ikon dairesi, navbar.
  Color get elevatedColor => colorScheme.surfaceContainerHigh;

  /// Başlık ve gövde metni.
  Color get textPrimary => colorScheme.onSurface;

  /// Açıklama, etiket, ikincil metin.
  Color get textSecondary => colorScheme.onSurfaceVariant;

  /// En soluk metin ve ikonlar (trailing chevron gibi).
  Color get textTertiary => colorScheme.outline;

  /// Ayraç ve ince kenarlıklar.
  Color get dividerColor => theme.dividerColor;

  /// Vurgu rengi; açık temada markanın koyu tonuna düşer.
  Color get accentColor => colorScheme.primary;
}

extension PaddingExtension on BuildContext {
  static const double _mainPadding = 0.054;
  static const double _mainPaddingLow = 0.048;
  static const double _mainPaddingLowest = 0.025;

  EdgeInsets get mainHorizontalPadding =>
      EdgeInsets.symmetric(horizontal: width * _mainPadding);

  EdgeInsets get mainHorizontalPaddingRight =>
      EdgeInsets.only(right: width * _mainPadding);
  EdgeInsets get mainHorizontalPaddingRightLow =>
      EdgeInsets.only(right: width * _mainPaddingLow);
  EdgeInsets get mainHorizontalPaddingRightLowest =>
      EdgeInsets.only(right: width * _mainPaddingLowest);

  EdgeInsets get mainHorizontalPaddingLeft =>
      EdgeInsets.only(left: width * _mainPadding);

  EdgeInsets get mainHorizontalPaddingLeftLowest =>
      EdgeInsets.only(left: width * _mainPaddingLowest);

  EdgeInsets get mainHorizontalPaddingLow =>
      EdgeInsets.symmetric(horizontal: width * _mainPaddingLow);

  EdgeInsets get mainHorizontalPaddingLowest =>
      EdgeInsets.symmetric(horizontal: width * _mainPaddingLowest);
}

import 'package:flutter/material.dart';

extension SizeExtension on BuildContext {
  Size get size => MediaQuery.sizeOf(this);

  EdgeInsets get padding => MediaQuery.paddingOf(this);

  double get height =>
      size.height - padding.bottom - padding.top - 56 /* appbar height*/;

  double get width => size.width;
}

extension ThemeExtension on BuildContext {
  ThemeData get theme => Theme.of(this);

  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  TextTheme get textTheme => Theme.of(this).textTheme;
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

  /// [accentColor] zemini üzerindeki metin ve ikon.
  ///
  /// Vurgu rengi temaya göre açık lila ile koyu mor arasında gidip geldiği
  /// için üstündeki içerik de yön değiştirir: koyu temada koyu, açık temada
  /// beyaz. Bu yüzden her iki temada beyaz kalan [AppColors.onAccent]
  /// buranın yerine kullanılamaz.
  Color get onAccentColor => colorScheme.onPrimary;
}

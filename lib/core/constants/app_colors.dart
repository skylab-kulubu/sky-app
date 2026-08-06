import 'package:flutter/material.dart';

/// Temadan bağımsız marka ve vurgu renkleri.
///
/// Zemin, metin, ayraç gibi **temaya göre değişen** renkler burada değil,
/// [ThemeData.colorScheme] içinde tanımlı; onlara `context` üzerinden
/// erişilir (`context.tileColor`, `context.textPrimary` ...).
class AppColors {
  // Marka
  static const primaryColor = Color(0xFFe0c8e5);
  static const primaryDeep = Color(0xFFC9A0D6);

  /// Açık temada zemin beyaz olduğu için lila okunmuyor; vurgu rengi olarak
  /// markanın koyu tonu kullanılıyor.
  static const primaryStrong = Color(0xFF8B5FA3);

  static const secondaryBlue = Color(0xFF00BFFF);
  static const indicatorColor = Color(0xFFe0c8e5);
  static const buttonBackground = Color(0xFF263238);

  // SkyPass Card (açık lila zemin üzerinde koyu metin)
  static const skyPassGradientStart = primaryColor;
  static const skyPassGradientEnd = primaryDeep;
  static const skyPassForeground = Color(0xFF231A2B);
  static final skyPassForegroundMuted = const Color(
    0xFF231A2B,
  ).withValues(alpha: 0.60);
  static final skyPassChip = const Color(0xFF231A2B).withValues(alpha: 0.18);

  // Yüzen navbar'ın gölgesi. Açık temada aynı opaklık beyaz zeminde sert bir
  // leke bırakıyor, o yüzden ağırlık temaya göre ayrışıyor.
  static final navShadowDark = Colors.black.withValues(alpha: 0.6);
  static final navShadowLight = Colors.black.withValues(alpha: 0.22);

  // Temaların ColorScheme'ini besleyen ham değerler. Doğrudan widget'larda
  // kullanılmaz; karşılıkları context üzerinden okunur.
  static const darkBackground = Color(0xFF000000);
  static const darkTile = Color.fromARGB(255, 27, 26, 26);
  static const darkTileHigh = Color(0xFF303032);
  static const darkTextPrimary = Color(0xFFFFFFFF);
  static const darkTextSecondary = Color(0xFF888888);
  static const darkTextTertiary = Color(0xFF666666);
  static const darkDivider = Color(0xFF333333);

  static const lightBackground = Color(0xFFFFFFFF);
  static const lightTile = Color(0xFFF2F2F7);
  static const lightTileHigh = Color(0xFFE8E8ED);
  static const lightTextPrimary = Color(0xFF1A1A1A);
  static const lightTextSecondary = Color(0xFF6B6B6B);
  static const lightTextTertiary = Color(0xFF9A9A9A);
  static const lightDivider = Color(0xFFE3E3E8);

  /// Doygun renkli zeminlerin (ayarlar ikon daireleri gibi) üstündeki
  /// içerik. Temadan bağımsız: her iki temada da beyaz kalır.
  static const onAccent = Color(0xFFFFFFFF);

  /// Etkinlik detayında kapak renklerinin üstüne bindiği koyu taban. Sayfa
  /// her iki temada da koyu kalıyor — kapaktan gelen renk açık bir zemine
  /// karıştırıldığında soluyor ve etkinliğin kimliği kayboluyor.
  ///
  /// Saf siyah değil: renk lekeleri altında taban ne kadar koyuysa sayfa o
  /// kadar ölü görünüyor.
  static const coverBackdropBase = Color(0xFF1C1C21);

  /// [coverBackdropBase] üzerindeki içerik. Zemin temadan bağımsız koyu
  /// olduğu için bu renkler de `context` erişimcilerinden okunmaz.
  static const onCover = onAccent;
  static final onCoverMuted = onAccent.withValues(alpha: 0.74);
  static final onCoverFaint = onAccent.withValues(alpha: 0.55);
  static final onCoverDivider = onAccent.withValues(alpha: 0.15);
  static final onCoverSurface = onAccent.withValues(alpha: 0.14);

  // Status & Icon Colors
  static const blue = Color(0xFF1E90FF);
  static const teal = Color(0xFF1ABC9C);
  static const green = Color(0xFF2ECC71);
  static const purple = Color(0xFF6C5CE7);
  static const darkPurple = Color(0xFF9B59B6);
  static const orange = Color(0xFFE67E22);
  static const pink = Color(0xFFE84393);
  static const coral = Color(0xFFFF6467);
  static const red = Color(0xFFE74C3C);
  static const darkOrange = Color(0xFFF39C12);
  static const brightRed = Color(0xFFFB2C36);

  /// Giriş sayfasındaki alt başlığın gökkuşağı geçişi. Vurgu renklerinden
  /// kuruluyor, temadan bağımsız: iki temada da aynı canlılıkta okunuyor.
  static const brandGradient = <Color>[secondaryBlue, purple, pink, darkOrange];

  // Opacity Backgrounds (For icon boxes)
  static final primaryBlue10 = const Color(0xFF1E90FF).withValues(alpha: 0.1);
  static final secondaryBlue9 = const Color(
    0xFF00BFFF,
  ).withValues(alpha: 0.094);
  static final teal9 = const Color(0xFF1ABC9C).withValues(alpha: 0.094);
  static final green9 = const Color(0xFF2ECC71).withValues(alpha: 0.094);
  static final purple9 = const Color(0xFF6C5CE7).withValues(alpha: 0.094);
  static final darkPurple9 = const Color(0xFF9B59B6).withValues(alpha: 0.094);
  static final orange9 = const Color(0xFFE67E22).withValues(alpha: 0.094);
  static final red9 = const Color(0xFFE74C3C).withValues(alpha: 0.094);
  static final pink9 = const Color(0xFFE84393).withValues(alpha: 0.094);
}

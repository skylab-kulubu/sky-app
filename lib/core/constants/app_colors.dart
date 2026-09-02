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

  // SkyPass Card (açık lila zemin üzerinde koyu metin)
  static const skyPassGradientStart = primaryColor;
  static const skyPassGradientEnd = primaryDeep;
  static const skyPassForeground = Color(0xFF231A2B);
  static final skyPassForegroundMuted = const Color(
    0xFF231A2B,
  ).withValues(alpha: 0.60);

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

  /// Tam ekran overlay'lerin (NFC okutma) arkasındaki karartma. Modal
  /// karartma temadan bağımsız koyu kalır: açık temada beyaza gitseydi hem
  /// öndeki kart zeminden ayrışmaz hem de "arkadaki sayfa devre dışı"
  /// hissi kaybolurdu. Opaklığı karartmayı çizen widget veriyor.
  static const scrim = Color(0xFF000000);

  /// [scrim] üzerindeki metin. Zemin temadan bağımsız koyu olduğu için bu
  /// renk de `context` erişimcilerinden okunmaz.
  static final onScrim = onAccent.withValues(alpha: 0.90);

  // Status & Icon Colors
  static const blue = Color(0xFF1E90FF);
  static const teal = Color(0xFF1ABC9C);
  static const green = Color(0xFF2ECC71);
  static const purple = Color(0xFF6C5CE7);
  static const darkPurple = Color(0xFF9B59B6);
  static const orange = Color(0xFFE67E22);
  static const pink = Color(0xFFE84393);
  static const red = Color(0xFFE74C3C);
  static const darkOrange = Color(0xFFF39C12);

  /// Giriş sayfasındaki alt başlığın gökkuşağı geçişi. Vurgu renklerinden
  /// kuruluyor, temadan bağımsız: iki temada da aynı canlılıkta okunuyor.
  static const brandGradient = <Color>[secondaryBlue, purple, pink, darkOrange];
}

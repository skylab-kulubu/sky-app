/// Reicon'da bulunmayan ikonlar.
///
/// Reicon ile aynı biçimde tutuluyor: 24×24 `viewBox` içinde ham SVG
/// içeriği, renk `currentColor`. Böylece [AppIcon] onları Reicon ikonlarından
/// ayırt etmeden çiziyor ve `String` ad bekleyen her widget'ta
/// (`IconCircle`, `SettingsTile` ...) kullanılabiliyorlar.
///
/// Reicon ikonları 24'lük kutunun içinde 2'şer birim boşluk bırakıyor. Kenara
/// kadar çizilen marka logoları aynı görsel boyda dursun diye 20'ye
/// küçültülüp ortalanıyor (`translate(2 2) scale(20/24)`).
class AppCustomIcons {
  /// LinkedIn logosu (Simple Icons, CC0). Tek ağırlığı var; iki listede de
  /// aynı çiziliyor.
  static const String _linkedin =
      '<g transform="translate(2 2) scale(0.833333)"><path d="M20.447 20.452h-3.554v-5.569c0-1.328-.027-3.037-1.852-3.037-1.853 0-2.136 1.445-2.136 2.939v5.667H9.351V9h3.414v1.561h.046c.477-.9 1.637-1.85 3.37-1.85 3.601 0 4.267 2.37 4.267 5.455v6.286zM5.337 7.433c-1.144 0-2.063-.926-2.063-2.065 0-1.138.92-2.063 2.063-2.063 1.14 0 2.064.925 2.064 2.063 0 1.139-.925 2.065-2.064 2.065zm1.782 13.019H3.555V9h3.564v11.452zM22.225 0H1.771C.792 0 0 .774 0 1.729v20.542C0 23.227.792 24 1.771 24h20.451C23.2 24 24 23.227 24 22.271V1.729C24 .774 23.2 0 22.222 0h.003z" fill="currentColor"/></g>';

  static const Map<String, String> outline = {'linkedin': _linkedin};

  static const Map<String, String> filled = {'linkedin': _linkedin};
}

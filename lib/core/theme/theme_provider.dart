import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Uygulamanın tema tercihi: sistem, açık ya da koyu.
///
/// Tercih [ThemeMode] olarak tutuluyor; açık/koyu temayı Flutter'ın kendisi
/// [MaterialApp.themeMode] üzerinden seçiyor, böylece "sistem" seçeneği
/// cihaz ayarını canlı takip edebiliyor.
class ThemeProvider with ChangeNotifier {
  static const String _prefsKey = 'themeMode';

  /// Tercih tek bir bool olarak saklanırdı; eski kullanıcıların seçimi
  /// kaybolmasın diye ilk açılışta okunup yeni anahtara taşınıyor.
  static const String _legacyPrefsKey = 'isDarkMode';

  /// Açık tema henüz tamamlanmadığı için varsayılan koyu; hazır olduğunda
  /// [ThemeMode.system] yapılabilir.
  static const ThemeMode _defaultMode = ThemeMode.dark;

  ThemeMode _themeMode = _defaultMode;

  ThemeProvider() {
    _load();
  }

  ThemeMode get themeMode => _themeMode;

  Future<void> setThemeMode(ThemeMode mode) async {
    if (mode == _themeMode) return;
    _themeMode = mode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, mode.name);
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_prefsKey);

    if (stored != null) {
      _themeMode = ThemeMode.values.firstWhere(
        (mode) => mode.name == stored,
        orElse: () => _defaultMode,
      );
    } else if (prefs.containsKey(_legacyPrefsKey)) {
      _themeMode = (prefs.getBool(_legacyPrefsKey) ?? true)
          ? ThemeMode.dark
          : ThemeMode.light;
    }

    notifyListeners();
  }
}

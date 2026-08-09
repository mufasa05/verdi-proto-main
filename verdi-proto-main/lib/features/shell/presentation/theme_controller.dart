import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier with WidgetsBindingObserver {
  static const String _themeKey = 'themeMode';

  ThemeMode _themeMode = ThemeMode.system;
  bool _loaded = false;

  ThemeMode get themeMode => _themeMode;
  bool get isDark => effectiveBrightness == Brightness.dark;
  bool get isLoaded => _loaded;

  Brightness get effectiveBrightness {
    if (_themeMode == ThemeMode.dark) return Brightness.dark;
    if (_themeMode == ThemeMode.light) return Brightness.light;
    return WidgetsBinding.instance.platformDispatcher.platformBrightness;
  }

  ThemeController() {
    WidgetsBinding.instance.addObserver(this);
  }

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_themeKey);

    if (saved == 'dark') {
      _themeMode = ThemeMode.dark;
    } else if (saved == 'light') {
      _themeMode = ThemeMode.light;
    } else {
      _themeMode = ThemeMode.system;
    }

    _loaded = true;
    notifyListeners();
  }

  Future<void> setLight() async {
    _themeMode = ThemeMode.light;
    await _saveTheme();
    notifyListeners();
  }

  Future<void> setDark() async {
    _themeMode = ThemeMode.dark;
    await _saveTheme();
    notifyListeners();
  }

  Future<void> setSystem() async {
    _themeMode = ThemeMode.system;
    await _saveTheme();
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.dark) {
      await setLight();
    } else {
      await setDark();
    }
  }

  Future<void> _saveTheme() async {
    final prefs = await SharedPreferences.getInstance();

    if (_themeMode == ThemeMode.system) {
      await prefs.remove(_themeKey);
    } else {
      await prefs.setString(
        _themeKey,
        _themeMode == ThemeMode.dark ? 'dark' : 'light',
      );
    }
  }

  @override
  void didChangePlatformBrightness() {
    if (_themeMode == ThemeMode.system) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
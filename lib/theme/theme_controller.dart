import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier {
  ThemeController(this._prefs, ThemeMode initialMode, this._themeIndex)
      : _mode = initialMode;

  static const _storageKey = 'theme_mode';
  static const _themeKey = 'theme_index';
  final SharedPreferences _prefs;
  ThemeMode _mode;
  int _themeIndex;

  ThemeMode get mode => _mode;
  int get themeIndex => _themeIndex;

  factory ThemeController.fromPreferences(SharedPreferences prefs) {
    final storedValue = prefs.getString(_storageKey);
    final storedMode = ThemeMode.values.firstWhere(
      (mode) => mode.name == storedValue,
      orElse: () => ThemeMode.system,
    );
    final storedThemeIndex = prefs.getInt(_themeKey) ?? 0;
    return ThemeController(prefs, storedMode, storedThemeIndex);
  }

  void setThemeMode(ThemeMode mode) {
    if (_mode == mode) return;
    _mode = mode;
    _prefs.setString(_storageKey, _mode.name);
    notifyListeners();
  }

  void setThemeIndex(int index) {
    if (_themeIndex == index) return;
    _themeIndex = index;
    _prefs.setInt(_themeKey, _themeIndex);
    notifyListeners();
  }

  void toggleThemeMode() {
    final nextMode = _mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    setThemeMode(nextMode);
  }
}

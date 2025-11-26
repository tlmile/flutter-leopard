import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends ChangeNotifier {
  ThemeController(this._prefs, ThemeMode initialMode)
      : _mode = initialMode;

  static const _storageKey = 'theme_mode';
  final SharedPreferences _prefs;
  ThemeMode _mode;

  ThemeMode get mode => _mode;

  factory ThemeController.fromPreferences(SharedPreferences prefs) {
    final storedValue = prefs.getString(_storageKey);
    final storedMode = ThemeMode.values.firstWhere(
      (mode) => mode.name == storedValue,
      orElse: () => ThemeMode.system,
    );
    return ThemeController(prefs, storedMode);
  }

  void setThemeMode(ThemeMode mode) {
    if (_mode == mode) return;
    _mode = mode;
    _prefs.setString(_storageKey, _mode.name);
    notifyListeners();
  }

  void toggleThemeMode() {
    final nextMode = _mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    setThemeMode(nextMode);
  }
}

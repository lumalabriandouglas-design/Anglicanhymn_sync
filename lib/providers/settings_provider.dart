import 'package:flutter/material.dart';
import '../core/services/storage_service.dart';

enum AppThemeMode { light, dark, system }
enum LyricsLanguage { luganda, english, both }

class SettingsProvider extends ChangeNotifier {
  final StorageService _storageService;

  late AppThemeMode _themeMode;
  late LyricsLanguage _lyricsLanguage;
  late bool _isProUser;
  late double _fontSize;

  SettingsProvider(this._storageService) {
    // Light is now the default
    final themeIndex = _storageService.getInt('app_theme_mode') ?? 0;
    _themeMode = AppThemeMode.values[themeIndex.clamp(0, 2)];

    final langIndex = _storageService.getInt('app_lyrics_language') ?? 0;
    _lyricsLanguage = LyricsLanguage.values[langIndex.clamp(0, 2)];

    _isProUser = _storageService.getBool('app_is_pro_user') ?? false;
    _fontSize = _storageService.getDouble('app_font_size') ?? 18.0;
  }

  AppThemeMode get themeMode => _themeMode;
  LyricsLanguage get lyricsLanguage => _lyricsLanguage;
  bool get isProUser => _isProUser;
  double get fontSize => _fontSize;

  // For backward compatibility with existing code
  bool get isDarkMode => _themeMode == AppThemeMode.dark;

  void setThemeMode(AppThemeMode mode) {
    _themeMode = mode;
    _storageService.setInt('app_theme_mode', mode.index);
    notifyListeners();
  }

  void setLyricsLanguage(LyricsLanguage language) {
    _lyricsLanguage = language;
    _storageService.setInt('app_lyrics_language', language.index);
    notifyListeners();
  }

  void toggleProUser() {
    _isProUser = !_isProUser;
    _storageService.setBool('app_is_pro_user', _isProUser);
    notifyListeners();
  }

  void setFontSize(double size) {
    _fontSize = size;
    _storageService.setDouble('app_font_size', _fontSize);
    notifyListeners();
  }
}
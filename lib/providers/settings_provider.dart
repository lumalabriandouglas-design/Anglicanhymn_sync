import 'package:flutter/material.dart';
import '../core/constants/pro_features.dart';
import '../core/services/storage_service.dart';

enum AppThemeMode { light, dark, system }
enum LyricsLanguage { luganda, english, both }

class SettingsProvider extends ChangeNotifier {
  final StorageService _storageService;

  late AppThemeMode _themeMode;
  late LyricsLanguage _lyricsLanguage;
  late double _fontSize;

  SettingsProvider(this._storageService) {
    final themeIndex = _storageService.getInt('app_theme_mode') ?? 0;
    _themeMode = AppThemeMode.values[themeIndex.clamp(0, 2)];

    final langIndex = _storageService.getInt('app_lyrics_language') ?? 0;
    _lyricsLanguage = LyricsLanguage.values[langIndex.clamp(0, 2)];

    _fontSize = _storageService.getDouble('app_font_size') ?? 18.0;
  }

  AppThemeMode get themeMode => _themeMode;
  LyricsLanguage get lyricsLanguage => _lyricsLanguage;
  double get fontSize => _fontSize;

  /// Pro stays open for every visitor until billing ships.
  bool get isProUser => ProFeatures.unlockedForEveryone;

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

  void setFontSize(double size) {
    _fontSize = size;
    _storageService.setDouble('app_font_size', _fontSize);
    notifyListeners();
  }
}

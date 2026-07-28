import 'package:flutter/material.dart';
import '../core/services/storage_service.dart';

class SettingsProvider extends ChangeNotifier {
  final StorageService _storageService;

  late bool _isDarkMode;
  late bool _isProUser;
  late double _fontSize;

  SettingsProvider(this._storageService) {
    _isDarkMode = _storageService.getBool('app_is_dark_mode') ?? true;
    _isProUser = _storageService.getBool('app_is_pro_user') ?? false;
    _fontSize = _storageService.getDouble('app_font_size') ?? 18.0;
  }

  bool get isDarkMode => _isDarkMode;
  bool get isProUser => _isProUser;
  double get fontSize => _fontSize;

  /// Toggles between Light and Dark mode and persists preference
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _storageService.setBool('app_is_dark_mode', _isDarkMode);
    notifyListeners();
  }

  /// Toggles PRO Mode status and persists preference
  void toggleProUser() {
    _isProUser = !_isProUser;
    _storageService.setBool('app_is_pro_user', _isProUser);
    notifyListeners();
  }

  /// Updates reader font size and persists preference
  void setFontSize(double size) {
    _fontSize = size;
    _storageService.setDouble('app_font_size', _fontSize);
    notifyListeners();
  }
}
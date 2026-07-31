import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'features/navigation/screens/main_navigation_wrapper.dart';
import 'providers/settings_provider.dart';

class AnglicanHymnSyncApp extends StatelessWidget {
  const AnglicanHymnSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    ThemeMode themeMode;
    switch (settings.themeMode) {
      case AppThemeMode.light:
        themeMode = ThemeMode.light;
        break;
      case AppThemeMode.dark:
        themeMode = ThemeMode.dark;
        break;
      case AppThemeMode.system:
        themeMode = ThemeMode.system;
        break;
    }

    return MaterialApp(
      title: 'Anglican Hymn Sync',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      home: const MainNavigationWrapper(),
    );
  }
}
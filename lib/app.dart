import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'features/navigation/screens/main_navigation_wrapper.dart';
import 'providers/settings_provider.dart';

class AnglicanHymnSyncApp extends StatelessWidget {
  const AnglicanHymnSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    context.watch<SettingsProvider>();

    return MaterialApp(
      title: 'Anglican Hymn Sync',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MainNavigationWrapper(),
    );
  }
}
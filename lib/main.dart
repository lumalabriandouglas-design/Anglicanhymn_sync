import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'core/services/billing_service.dart';
import 'core/services/storage_service.dart';
import 'providers/billing_provider.dart';
import 'providers/hymn_provider.dart';
import 'providers/setlist_provider.dart';
import 'providers/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storageService = await StorageService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(storageService),
        ),
        ChangeNotifierProvider(
          create: (_) => BillingProvider(BillingService(storageService)),
        ),
        ChangeNotifierProvider(
          create: (_) => HymnProvider(storageService)..loadHymns(),
        ),
        ChangeNotifierProvider(
          create: (_) => SetlistProvider(storageService),
        ),
      ],
      child: const AnglicanHymnSyncApp(),
    ),
  );
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'core/services/audio_player_service.dart';
import 'core/services/storage_service.dart';
import 'providers/audio_provider.dart';
import 'providers/hymn_provider.dart';
import 'providers/setlist_provider.dart';
import 'providers/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storageService = await StorageService.init();
  final audioPlayerService = AudioPlayerService();
  await audioPlayerService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(storageService),
        ),
        ChangeNotifierProvider(
          create: (_) => HymnProvider(storageService)..loadHymns(),
        ),
        ChangeNotifierProvider(
          create: (_) => AudioProvider(audioPlayerService),
        ),
        ChangeNotifierProvider(
          create: (_) => SetlistProvider(storageService),
        ),
      ],
      child: const AnglicanHymnSyncApp(),
    ),
  );
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../providers/audio_provider.dart';
import '../../../providers/hymn_provider.dart';
import '../../../providers/settings_provider.dart';
import '../../library/widgets/hymn_tile.dart';
import '../../reader/screens/hymn_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final hymnProvider = context.watch<HymnProvider>();
    final audioProvider = context.watch<AudioProvider>();
    final settings = context.watch<SettingsProvider>();
    final favorites = hymnProvider.favoriteHymns;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? AppColors.textWhite : AppColors.lightTextPrimary;
    final bodyColor = isDark ? AppColors.textGrey : AppColors.lightTextSecondary;

    if (favorites.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.favorite_border_rounded, size: 48, color: bodyColor),
              const SizedBox(height: 12),
              Text(
                'No favorites yet',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Tap the heart on any hymn to save it here for Sunday.',
                style: TextStyle(color: bodyColor, fontSize: 13, height: 1.4),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final hymn = favorites[index];
        return HymnTile(
          hymn: hymn,
          onPlayTap: () {
            audioProvider.setHymns(hymnProvider.allHymns);
            audioProvider.playHymn(
              hymn,
              language: settings.lyricsLanguage,
            );
          },
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => HymnDetailScreen(hymn: hymn),
              ),
            );
          },
        );
      },
    );
  }
}

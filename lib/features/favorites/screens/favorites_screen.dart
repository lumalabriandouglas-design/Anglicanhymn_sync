import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../providers/audio_provider.dart';
import '../../../providers/hymn_provider.dart';
import '../../library/widgets/hymn_tile.dart';
import '../../reader/screens/hymn_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final hymnProvider = context.watch<HymnProvider>();
    final audioProvider = context.watch<AudioProvider>();
    final favorites = hymnProvider.favoriteHymns;

    if (favorites.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border_rounded, size: 48, color: AppColors.textGrey),
            SizedBox(height: 12),
            Text(
              'No Favorites Saved Yet',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textWhite),
            ),
            SizedBox(height: 6),
            Text(
              'Tap the heart icon on any hymn to save it here for quick access.',
              style: TextStyle(color: AppColors.textGrey, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ],
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
          onPlayTap: () => audioProvider.playHymn(hymn),
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
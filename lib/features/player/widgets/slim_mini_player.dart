import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../providers/audio_provider.dart';
import '../../reader/screens/hymn_detail_screen.dart';

class SlimMiniPlayer extends StatelessWidget {
  const SlimMiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    final audioProvider = context.watch<AudioProvider>();

    if (audioProvider.currentHymn == null) return const SizedBox.shrink();

    final hymn = audioProvider.currentHymn!;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => HymnDetailScreen(hymn: hymn),
          ),
        );
      },
      child: Container(
        height: 60,
        color: AppColors.cardNavy,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            const Icon(Icons.music_note_rounded, color: AppColors.celestialGold),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${hymn.number}. ${hymn.title}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.textWhite, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'Tap to view lyrics',
                    style: TextStyle(color: AppColors.textGrey, fontSize: 11),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                audioProvider.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: AppColors.celestialGold,
              ),
              onPressed: () => audioProvider.togglePlayPause(),
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded, color: AppColors.textGrey),
              onPressed: () => audioProvider.stop(),
            ),
          ],
        ),
      ),
    );
  }
}
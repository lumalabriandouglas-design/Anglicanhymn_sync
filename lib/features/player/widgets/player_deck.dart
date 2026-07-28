import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../providers/audio_provider.dart';
import '../../../providers/settings_provider.dart';

class PlayerDeck extends StatelessWidget {
  const PlayerDeck({super.key});

  @override
  Widget build(BuildContext context) {
    final audioProvider = context.watch<AudioProvider>();
    final settings = context.watch<SettingsProvider>();

    final hymn = audioProvider.currentHymn;

    if (hymn == null) {
      return const Center(
        child: Text('No hymn selected for playback.', style: TextStyle(color: AppColors.textGrey)),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              color: AppColors.cardNavy,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.celestialGold, width: 2),
            ),
            child: const Icon(Icons.menu_book_rounded, size: 80, color: AppColors.celestialGold),
          ),
          const SizedBox(height: 32),
          Text(
            'Hymn ${hymn.number}',
            style: const TextStyle(color: AppColors.celestialGold, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            hymn.title,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textWhite, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 40),

          // Play/Pause Control
          IconButton(
            iconSize: 72,
            icon: Icon(
              audioProvider.isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded,
              color: AppColors.celestialGold,
            ),
            onPressed: () => audioProvider.togglePlayPause(),
          ),

          const SizedBox(height: 32),

          // Speed Control Gated behind PRO
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Playback Speed: ', style: TextStyle(color: AppColors.textGrey)),
              DropdownButton<double>(
                value: audioProvider.currentSpeed,
                dropdownColor: AppColors.cardNavy,
                style: const TextStyle(color: AppColors.celestialGold, fontWeight: FontWeight.bold),
                items: [0.75, 1.0, 1.25, 1.5].map((speed) {
                  return DropdownMenuItem<double>(
                    value: speed,
                    child: Text('${speed}x'),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val == null) return;
                  if (!settings.isProUser) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Custom playback speeds are exclusive to PRO users.')),
                    );
                    return;
                  }
                  audioProvider.setPlaybackSpeed(val);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
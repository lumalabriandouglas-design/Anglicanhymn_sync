import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../providers/audio_provider.dart';
import '../../../providers/settings_provider.dart';

class PlayerDeck extends StatelessWidget {
  const PlayerDeck({super.key});

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final audio = context.watch<AudioProvider>();
    final settings = context.watch<SettingsProvider>();
    final hymn = audio.currentHymn;

    if (hymn == null) {
      return const Center(
        child: Text('No hymn selected', style: TextStyle(color: AppColors.textGrey)),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0B132B),
      body: SafeArea(
        child: Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.only(left: 4, right: 8, top: 4),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 30),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      'NOW PLAYING',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textGrey,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Artwork
            Expanded(
              flex: 5,
              child: Center(
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.celestialGold.withOpacity(0.22),
                        blurRadius: 36,
                        spreadRadius: 1,
                      ),
                    ],
                    color: AppColors.cardNavy,
                  ),
                  child: const Icon(
                    Icons.menu_book_rounded,
                    size: 100,
                    color: AppColors.celestialGold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  Text(
                    'Hymn ${hymn.number}',
                    style: const TextStyle(
                      color: AppColors.celestialGold,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    hymn.title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Progress
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppColors.celestialGold,
                      inactiveTrackColor: Colors.white.withOpacity(0.12),
                      thumbColor: AppColors.celestialGold,
                      overlayColor: AppColors.celestialGold.withOpacity(0.15),
                      trackHeight: 3,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.5),
                    ),
                    child: Slider(
                      value: audio.progress.clamp(0.0, 1.0),
                      onChanged: (value) {
                        final newPos = Duration(
                          milliseconds: (value * audio.duration.inMilliseconds).round(),
                        );
                        audio.seek(newPos);
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(audio.position),
                          style: const TextStyle(color: AppColors.textGrey, fontSize: 12),
                        ),
                        Text(
                          _formatDuration(audio.duration),
                          style: const TextStyle(color: AppColors.textGrey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  iconSize: 34,
                  icon: const Icon(Icons.skip_previous_rounded, color: Colors.white70),
                  onPressed: () {},
                ),
                const SizedBox(width: 16),
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.celestialGold,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.celestialGold.withOpacity(0.35),
                        blurRadius: 18,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: IconButton(
                    iconSize: 40,
                    icon: Icon(
                      audio.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: const Color(0xFF0B132B),
                    ),
                    onPressed: () => audio.togglePlayPause(),
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  iconSize: 34,
                  icon: const Icon(Icons.skip_next_rounded, color: Colors.white70),
                  onPressed: () {},
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Speed
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Speed', style: TextStyle(color: AppColors.textGrey, fontSize: 13)),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.cardNavy,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<double>(
                      value: audio.currentSpeed,
                      dropdownColor: AppColors.cardNavy,
                      style: const TextStyle(
                        color: AppColors.celestialGold,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                      items: const [
                        DropdownMenuItem(value: 0.75, child: Text('0.75x')),
                        DropdownMenuItem(value: 1.0, child: Text('1.0x')),
                        DropdownMenuItem(value: 1.25, child: Text('1.25x')),
                        DropdownMenuItem(value: 1.5, child: Text('1.5x')),
                      ],
                      onChanged: (val) {
                        if (val == null) return;
                        if (!settings.isProUser) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Custom speeds are for PRO users')),
                          );
                          return;
                        }
                        audio.setPlaybackSpeed(val);
                      },
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/hymn_audio.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.primaryNavy : AppColors.lightBackground;
    final titleColor = isDark ? Colors.white : AppColors.lightTextPrimary;
    final muted = isDark ? AppColors.textGrey : AppColors.lightTextSecondary;

    if (hymn == null) {
      return Scaffold(
        backgroundColor: bg,
        body: Center(child: Text('No hymn selected', style: TextStyle(color: muted))),
      );
    }

    final hasLg = HymnAudio.hasLanguage(hymn, 'luganda');
    final hasEn = HymnAudio.hasLanguage(hymn, 'english') || HymnAudio.hasAudio(hymn);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, right: 8, top: 4),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.keyboard_arrow_down_rounded, color: titleColor, size: 30),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      'NOW PLAYING',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: muted,
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
            Expanded(
              flex: 5,
              child: Center(
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    color: isDark ? AppColors.cardNavy : Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.celestialGold.withOpacity(0.18),
                        blurRadius: 36,
                      ),
                    ],
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
                    style: TextStyle(
                      color: titleColor,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  if (hasLg && hasEn) ...[
                    const SizedBox(height: 12),
                    SegmentedButton<LyricsLanguage>(
                      segments: const [
                        ButtonSegment(value: LyricsLanguage.luganda, label: Text('Luganda')),
                        ButtonSegment(value: LyricsLanguage.english, label: Text('English')),
                      ],
                      selected: {
                        audio.audioLanguage == LyricsLanguage.luganda
                            ? LyricsLanguage.luganda
                            : LyricsLanguage.english,
                      },
                      onSelectionChanged: (set) {
                        audio.playHymn(hymn, language: set.first);
                      },
                    ),
                  ],
                  if (audio.error != null) ...[
                    const SizedBox(height: 8),
                    Text(audio.error!, style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppColors.celestialGold,
                      inactiveTrackColor: titleColor.withOpacity(0.12),
                      thumbColor: AppColors.celestialGold,
                      overlayColor: AppColors.celestialGold.withOpacity(0.15),
                      trackHeight: 3,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.5),
                    ),
                    child: Slider(
                      value: audio.progress.clamp(0.0, 1.0),
                      onChanged: (value) {
                        audio.seek(Duration(
                          milliseconds: (value * audio.duration.inMilliseconds).round(),
                        ));
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_formatDuration(audio.position), style: TextStyle(color: muted, fontSize: 12)),
                        Text(_formatDuration(audio.duration), style: TextStyle(color: muted, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  iconSize: 34,
                  icon: Icon(Icons.skip_previous_rounded, color: titleColor.withOpacity(0.75)),
                  onPressed: () => audio.playPrevious(),
                ),
                const SizedBox(width: 16),
                Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.celestialGold,
                  ),
                  child: IconButton(
                    iconSize: 40,
                    icon: Icon(
                      audio.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: AppColors.primaryNavy,
                    ),
                    onPressed: () => audio.togglePlayPause(),
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  iconSize: 34,
                  icon: Icon(Icons.skip_next_rounded, color: titleColor.withOpacity(0.75)),
                  onPressed: () => audio.playNext(),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Speed', style: TextStyle(color: muted, fontSize: 13)),
                const SizedBox(width: 10),
                DropdownButton<double>(
                  value: audio.currentSpeed,
                  items: const [
                    DropdownMenuItem(value: 0.75, child: Text('0.75x')),
                    DropdownMenuItem(value: 1.0, child: Text('1.0x')),
                    DropdownMenuItem(value: 1.25, child: Text('1.25x')),
                    DropdownMenuItem(value: 1.5, child: Text('1.5x')),
                  ],
                  onChanged: (val) {
                    if (val == null) return;
                    if (!settings.isProUser && val != 1.0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Custom speeds are for PRO users')),
                      );
                      return;
                    }
                    audio.setPlaybackSpeed(val);
                  },
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

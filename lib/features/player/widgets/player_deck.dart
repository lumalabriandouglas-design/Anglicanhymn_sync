import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/hymn_audio.dart';
import '../../../core/utils/verse_parser.dart';
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
    final card = isDark ? AppColors.cardNavy : Colors.white;

    if (hymn == null) {
      return Scaffold(
        backgroundColor: bg,
        body: Center(
          child: Text('No hymn selected', style: TextStyle(color: muted)),
        ),
      );
    }

    final hasLg = HymnAudio.hasLanguage(hymn, 'luganda');
    final hasEn =
        HymnAudio.hasLanguage(hymn, 'english') || HymnAudio.hasAudio(hymn);
    final lyrics = audio.audioLanguage == LyricsLanguage.english &&
            hymn.lyricsEnglish.trim().isNotEmpty
        ? hymn.lyricsEnglish
        : hymn.lyricsLuganda;

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
                    icon: Icon(Icons.keyboard_arrow_down_rounded,
                        color: titleColor, size: 30),
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
                  IconButton(
                    tooltip: 'Stop',
                    icon: Icon(Icons.close_rounded, color: muted),
                    onPressed: () {
                      audio.stop();
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 168,
              child: Center(
                child: Container(
                  width: 168,
                  height: 168,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    color: card,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.celestialGold.withOpacity(0.16),
                        blurRadius: 28,
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'HYMN',
                            style: TextStyle(
                              color: AppColors.celestialGold,
                              fontSize: 11,
                              letterSpacing: 2.2,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            hymn.number,
                            style: GoogleFonts.cinzel(
                              fontSize: 48,
                              fontWeight: FontWeight.w700,
                              color: titleColor,
                            ),
                          ),
                        ],
                      ),
                      if (audio.isLoading)
                        Container(
                          decoration: BoxDecoration(
                            color: bg.withOpacity(0.35),
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.celestialGold,
                              strokeWidth: 2.4,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                children: [
                  Text(
                    hymn.title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.lora(
                      color: titleColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  if (hymn.hasEnglishTitle) ...[
                    const SizedBox(height: 4),
                    Text(
                      hymn.titleEnglish,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: muted, fontSize: 13),
                    ),
                  ],
                  if (hasLg && hasEn) ...[
                    const SizedBox(height: 12),
                    SegmentedButton<LyricsLanguage>(
                      segments: const [
                        ButtonSegment(
                          value: LyricsLanguage.luganda,
                          label: Text('Luganda'),
                        ),
                        ButtonSegment(
                          value: LyricsLanguage.english,
                          label: Text('English'),
                        ),
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
                    Text(
                      audio.error!,
                      style: const TextStyle(
                          color: Colors.redAccent, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                    TextButton(
                      onPressed: audio.retry,
                      child: const Text('Retry'),
                    ),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 0),
              child: Column(
                children: [
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppColors.celestialGold,
                      inactiveTrackColor: titleColor.withOpacity(0.12),
                      thumbColor: AppColors.celestialGold,
                      overlayColor: AppColors.celestialGold.withOpacity(0.15),
                      trackHeight: 3,
                      thumbShape:
                          const RoundSliderThumbShape(enabledThumbRadius: 6.5),
                    ),
                    child: Slider(
                      value: audio.duration.inMilliseconds <= 0
                          ? 0
                          : audio.progress.clamp(0.0, 1.0),
                      onChanged: audio.duration.inMilliseconds <= 0
                          ? null
                          : (value) {
                              audio.seek(Duration(
                                milliseconds: (value *
                                        audio.duration.inMilliseconds)
                                    .round(),
                              ));
                            },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_formatDuration(audio.position),
                            style: TextStyle(color: muted, fontSize: 12)),
                        Text(_formatDuration(audio.duration),
                            style: TextStyle(color: muted, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  tooltip: audio.shuffle ? 'Shuffle on' : 'Shuffle off',
                  icon: Icon(
                    Icons.shuffle_rounded,
                    color: audio.shuffle
                        ? AppColors.celestialGold
                        : titleColor.withOpacity(0.45),
                  ),
                  onPressed: audio.toggleShuffle,
                ),
                IconButton(
                  iconSize: 34,
                  icon: Icon(Icons.skip_previous_rounded,
                      color: titleColor.withOpacity(0.75)),
                  onPressed: audio.playPrevious,
                ),
                const SizedBox(width: 8),
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
                      ),
                    ],
                  ),
                  child: IconButton(
                    iconSize: 40,
                    icon: Icon(
                      audio.isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: AppColors.primaryNavy,
                    ),
                    onPressed: audio.togglePlayPause,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  iconSize: 34,
                  icon: Icon(Icons.skip_next_rounded,
                      color: titleColor.withOpacity(0.75)),
                  onPressed: audio.playNext,
                ),
                IconButton(
                  tooltip: 'Repeat ${audio.repeat.name}',
                  icon: Icon(
                    audio.repeat == RepeatMode.one
                        ? Icons.repeat_one_rounded
                        : Icons.repeat_rounded,
                    color: audio.repeat == RepeatMode.off
                        ? titleColor.withOpacity(0.45)
                        : AppColors.celestialGold,
                  ),
                  onPressed: audio.cycleRepeat,
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Row(
                children: [
                  Icon(Icons.volume_down_rounded, color: muted, size: 18),
                  Expanded(
                    child: Slider(
                      value: audio.volume,
                      onChanged: audio.setVolume,
                      activeColor: AppColors.celestialGold,
                    ),
                  ),
                  DropdownButton<double>(
                    value: audio.currentSpeed,
                    underline: const SizedBox.shrink(),
                    items: const [
                      DropdownMenuItem(value: 0.75, child: Text('0.75x')),
                      DropdownMenuItem(value: 1.0, child: Text('1x')),
                      DropdownMenuItem(value: 1.25, child: Text('1.25x')),
                      DropdownMenuItem(value: 1.5, child: Text('1.5x')),
                    ],
                    onChanged: (val) {
                      if (val == null) return;
                      if (!settings.isProUser && val != 1.0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Custom speeds are for PRO users'),
                          ),
                        );
                        return;
                      }
                      audio.setPlaybackSpeed(val);
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
                decoration: BoxDecoration(
                  color: card,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListView(
                  children: [
                    Text(
                      'LYRICS',
                      style: TextStyle(
                        color: AppColors.celestialGold,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    VerseParser.buildFormattedLyrics(lyrics, 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

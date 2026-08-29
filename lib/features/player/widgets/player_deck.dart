import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/hymn_audio.dart';
import '../../../core/utils/verse_parser.dart';
import '../../../models/hymn.dart';
import '../../../providers/audio_provider.dart';
import '../../../providers/settings_provider.dart';

class PlayerDeck extends StatefulWidget {
  const PlayerDeck({super.key});

  @override
  State<PlayerDeck> createState() => _PlayerDeckState();
}

class _PlayerDeckState extends State<PlayerDeck> {
  final _lyrics = ScrollController();
  Timer? _sleepTick;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _sleepTick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final until = context.read<AudioProvider>().sleepUntil;
      if (until != null) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _sleepTick?.cancel();
    _lyrics.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  void _followLyrics(double progress) {
    if (!_lyrics.hasClients) return;
    final max = _lyrics.position.maxScrollExtent;
    if (max <= 0) return;
    final target = (max * progress).clamp(0.0, max);
    if ((target - _lyrics.offset).abs() < 12) return;
    _lyrics.jumpTo(target);
  }

  void _openQueue(BuildContext context, AudioProvider audio) {
    final items = audio.playableHymns;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.cardNavy
          : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.of(ctx).size.height * 0.55,
            child: Column(
              children: [
                ListTile(
                  title: Text(
                    'Queue',
                    style: GoogleFonts.cinzel(fontWeight: FontWeight.w600),
                  ),
                  trailing: TextButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      audio.stop();
                      Navigator.pop(context);
                    },
                    child: const Text('Stop'),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (_, i) {
                      final hymn = items[i];
                      final current =
                          audio.currentHymn?.number == hymn.number;
                      return ListTile(
                        leading: Text(
                          hymn.number,
                          style: GoogleFonts.cinzel(
                            color: AppColors.celestialGold,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        title: Text(hymn.title, maxLines: 1),
                        subtitle: hymn.hasEnglishTitle
                            ? Text(hymn.titleEnglish, maxLines: 1)
                            : null,
                        selected: current,
                        onTap: () {
                          audio.playHymn(hymn, language: audio.audioLanguage);
                          Navigator.pop(ctx);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _pickSleep(BuildContext context, AudioProvider audio) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.cardNavy
          : Colors.white,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ListTile(title: Text('Sleep timer')),
              for (final minutes in [15, 30, 45, 60])
                ListTile(
                  title: Text('$minutes minutes'),
                  onTap: () {
                    audio.setSleepTimer(minutes);
                    Navigator.pop(ctx);
                  },
                ),
              ListTile(
                title: const Text('Off'),
                onTap: () {
                  audio.setSleepTimer(null);
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        );
      },
    );
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

    if (audio.isPlaying) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _followLyrics(audio.progress);
      });
    }

    final sleepLeft = audio.sleepUntil == null
        ? null
        : audio.sleepUntil!.difference(_now);
    final sleepLabel = sleepLeft == null || sleepLeft.isNegative
        ? null
        : _formatDuration(sleepLeft);

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
                    tooltip: 'Queue',
                    icon: Icon(Icons.queue_music_rounded, color: muted),
                    onPressed: () => _openQueue(context, audio),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            HymnNumberArt(
              number: hymn.number,
              loading: audio.isLoading,
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
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 4),
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
                  IconButton(
                    tooltip: 'Sleep timer',
                    icon: Icon(
                      Icons.bedtime_outlined,
                      size: 18,
                      color: audio.sleepUntil != null
                          ? AppColors.celestialGold
                          : muted,
                    ),
                    onPressed: () => _pickSleep(context, audio),
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
            if (sleepLabel != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'Sleep in $sleepLabel',
                  style: const TextStyle(
                    color: AppColors.celestialGold,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            _QueueStrip(
              items: audio.playableHymns,
              current: hymn.number,
              onSelect: (h) =>
                  audio.playHymn(h, language: audio.audioLanguage),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
                decoration: BoxDecoration(
                  color: card,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListView(
                  controller: _lyrics,
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

class _QueueStrip extends StatelessWidget {
  final List<Hymn> items;
  final String current;
  final ValueChanged<Hymn> onSelect;

  const _QueueStrip({
    required this.items,
    required this.current,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    if (items.length < 2) return const SizedBox(height: 4);
    return SizedBox(
      height: 38,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final hymn = items[i];
          final active = hymn.number == current;
          return ActionChip(
            label: Text(hymn.number),
            backgroundColor: active
                ? AppColors.celestialGold
                : AppColors.celestialGold.withOpacity(0.12),
            labelStyle: TextStyle(
              color: active ? AppColors.primaryNavy : AppColors.celestialGold,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
            onPressed: () => onSelect(hymn),
            visualDensity: VisualDensity.compact,
            side: BorderSide.none,
          );
        },
      ),
    );
  }
}

class HymnNumberArt extends StatelessWidget {
  final String number;
  final bool loading;
  final double size;

  const HymnNumberArt({
    super.key,
    required this.number,
    this.loading = false,
    this.size = 168,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: const RadialGradient(
            center: Alignment(0, -0.25),
            radius: 0.9,
            colors: [
              Color(0xFF1C2541),
              AppColors.primaryNavy,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.celestialGold.withOpacity(0.22),
              blurRadius: 28,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.all(size * 0.11),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.celestialGold.withOpacity(0.28),
                    ),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.all(size * 0.18),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.celestialGold.withOpacity(0.62),
                    ),
                  ),
                ),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomPaint(
                  size: const Size(18, 18),
                  painter: _CrossPainter(AppColors.celestialGold),
                ),
                const SizedBox(height: 4),
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
                  number,
                  style: GoogleFonts.cinzel(
                    fontSize: 48,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            if (loading)
              Container(
                decoration: BoxDecoration(
                  color: AppColors.primaryNavy.withOpacity(0.4),
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
    );
  }
}

class _CrossPainter extends CustomPainter {
  final Color color;
  const _CrossPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    canvas.drawCircle(
      Offset(size.width / 2, size.height * 0.42),
      size.width * 0.28,
      stroke,
    );
    final fill = Paint()..color = color;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.width / 2, size.height / 2),
          width: size.width * 0.18,
          height: size.height,
        ),
        const Radius.circular(1),
      ),
      fill,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.width / 2, size.height * 0.42),
          width: size.width * 0.78,
          height: size.height * 0.18,
        ),
        const Radius.circular(1),
      ),
      fill,
    );
  }

  @override
  bool shouldRepaint(covariant _CrossPainter oldDelegate) =>
      oldDelegate.color != color;
}


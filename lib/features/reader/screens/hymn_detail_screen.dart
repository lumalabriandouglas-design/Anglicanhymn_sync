import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/hymn_audio.dart';
import '../../../core/widgets/app_nav.dart';
import '../../../models/hymn.dart';
import '../../../providers/audio_provider.dart';
import '../../../providers/hymn_provider.dart';
import '../../../providers/settings_provider.dart';
import '../../player/widgets/player_deck.dart';
import '../widgets/dual_lyrics_view.dart';
import '../widgets/lyric_report_dialog.dart';

class HymnDetailScreen extends StatefulWidget {
  final Hymn hymn;
  final bool embedded;

  const HymnDetailScreen({
    super.key,
    required this.hymn,
    this.embedded = false,
  });

  @override
  State<HymnDetailScreen> createState() => _HymnDetailScreenState();
}

class _HymnDetailScreenState extends State<HymnDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isAutoScrolling = false;
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
  }

  @override
  void didUpdateWidget(covariant HymnDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.hymn.number != widget.hymn.number) {
      _autoScrollTimer?.cancel();
      _isAutoScrolling = false;
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    }
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    _autoScrollTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _toggleAutoScroll() {
    setState(() {
      _isAutoScrolling = !_isAutoScrolling;
    });

    if (_isAutoScrolling) {
      _autoScrollTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
        if (_scrollController.hasClients) {
          final maxScroll = _scrollController.position.maxScrollExtent;
          final currentScroll = _scrollController.position.pixels;
          if (currentScroll >= maxScroll) {
            timer.cancel();
            setState(() => _isAutoScrolling = false);
          } else {
            _scrollController.jumpTo(currentScroll + 1.5);
          }
        }
      });
    } else {
      _autoScrollTimer?.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final hymnProvider = context.watch<HymnProvider>();
    final audioProvider = context.watch<AudioProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasAudio = HymnAudio.hasAudio(widget.hymn);

    final cleanTitle = widget.hymn.title
        .replaceAll(RegExp(r'^OLUYIMBA\s+\d+:\s*', caseSensitive: false), '')
        .replaceAll(' Song Lyrics', '')
        .trim();

    final titleBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.hymn.hasEnglishTitle
              ? 'Hymn ${widget.hymn.number}  ·  ${widget.hymn.titleEnglish}'
              : 'Hymn ${widget.hymn.number}',
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          cleanTitle,
          style: GoogleFonts.lora(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.textWhite : AppColors.lightTextPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );

    final actions = [
      IconButton(
        icon: Icon(
          widget.hymn.isFavorite ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
          color: widget.hymn.isFavorite
              ? Colors.redAccent
              : (isDark ? AppColors.textWhite : AppColors.primaryNavy),
        ),
        onPressed: () => hymnProvider.toggleFavorite(widget.hymn),
      ),
      IconButton(
        icon: Icon(
          Icons.report_problem_outlined,
          color: isDark ? AppColors.textWhite : AppColors.primaryNavy,
        ),
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => LyricReportDialog(
              hymnNumber: widget.hymn.number,
              hymnTitle: widget.hymn.title,
            ),
          );
        },
      ),
    ];

    return Scaffold(
      backgroundColor: isDark ? AppColors.primaryNavy : AppColors.lightBackground,
      appBar: widget.embedded
          ? null
          : AppBar(
              backgroundColor: isDark ? AppColors.primaryNavy : Colors.white,
              elevation: 0,
              centerTitle: false,
              title: titleBlock,
              actions: actions,
            ),
      body: Column(
        children: [
          if (widget.embedded)
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 4, 4),
              child: Row(
                children: [
                  Expanded(child: titleBlock),
                  ...actions,
                  IconButton(
                    tooltip: 'Close reader',
                    icon: Icon(
                      Icons.close_rounded,
                      color: isDark ? AppColors.textWhite : AppColors.primaryNavy,
                    ),
                    onPressed: () => hymnProvider.selectHymn(null),
                  ),
                ],
              ),
            ),
          Container(
            height: 1,
            color: isDark ? Colors.white.withOpacity(0.08) : Colors.grey.withOpacity(0.15),
          ),
          Expanded(
            child: DualLyricsView(
              lyricsLuganda: widget.hymn.lyricsLuganda,
              lyricsEnglish: widget.hymn.lyricsEnglish,
              fontSize: settings.fontSize,
              language: settings.lyricsLanguage,
              scrollController: _scrollController,
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardNavy : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.celestialGold.withOpacity(0.15)
                          : AppColors.celestialGold.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      tooltip: _isAutoScrolling
                          ? 'Stop auto-scroll'
                          : 'Auto-scroll lyrics',
                      icon: Icon(
                        _isAutoScrolling
                            ? Icons.pause_rounded
                            : Icons.unfold_more_rounded,
                        color: isDark ? AppColors.celestialGold : AppColors.primaryNavy,
                      ),
                      onPressed: _toggleAutoScroll,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: hasAudio
                            ? AppColors.celestialGold
                            : (isDark ? Colors.white12 : Colors.grey.shade300),
                        foregroundColor: hasAudio
                            ? AppColors.primaryNavy
                            : (isDark ? Colors.white54 : Colors.grey.shade600),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: Icon(
                        hasAudio
                            ? Icons.play_arrow_rounded
                            : Icons.hourglass_empty_rounded,
                        size: 22,
                      ),
                      label: Text(
                        hasAudio ? 'Play Audio' : 'Audio coming soon',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      onPressed: hasAudio
                          ? () {
                              audioProvider.setHymns(hymnProvider.allHymns);
                              audioProvider.playHymn(
                                widget.hymn,
                                language: settings.lyricsLanguage,
                              );
                              AppNav.push(
                                context,
                                const PlayerDeck(),
                                fullscreenDialog: true,
                              );
                            }
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

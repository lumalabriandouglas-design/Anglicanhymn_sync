import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../core/constants/app_colors.dart';
import '../../../models/hymn.dart';
import '../../../providers/audio_provider.dart';
import '../../../providers/hymn_provider.dart';
import '../../../providers/settings_provider.dart';
import '../widgets/dual_lyrics_view.dart';
import '../widgets/lyric_report_dialog.dart';

class HymnDetailScreen extends StatefulWidget {
  final Hymn hymn;

  const HymnDetailScreen({super.key, required this.hymn});

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
    // Keep screen awake while reading lyrics in church
    WakelockPlus.enable();
  }

  @override
  void dispose() {
    // Disable wakelock when leaving screen
    WakelockPlus.disable();
    _autoScrollTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _toggleAutoScroll(bool isPro) {
    if (!isPro) {
      _showProGatedDialog();
      return;
    }

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

  void _showProGatedDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardNavy,
        title: const Text('PRO Feature', style: TextStyle(color: AppColors.celestialGold)),
        content: const Text(
          'Hands-free Auto-Scroll is exclusive to PRO users. Enable PRO mode in the Settings menu to unlock.',
          style: TextStyle(color: AppColors.textWhite),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK', style: TextStyle(color: AppColors.celestialGold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final hymnProvider = context.watch<HymnProvider>();
    final audioProvider = context.watch<AudioProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.hymn.number}. ${widget.hymn.title}',
          style: GoogleFonts.cinzel(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(
              widget.hymn.isFavorite ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
              color: widget.hymn.isFavorite ? Colors.redAccent : AppColors.textWhite,
            ),
            onPressed: () => hymnProvider.toggleFavorite(widget.hymn),
          ),
          IconButton(
            icon: const Icon(Icons.report_problem_outlined),
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
        ],
      ),
      body: Column(
        children: [
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: AppColors.cardNavy,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: Icon(
                    _isAutoScrolling ? Icons.pause_circle_filled : Icons.unfold_more_rounded,
                    color: AppColors.celestialGold,
                  ),
                  onPressed: () => _toggleAutoScroll(settings.isProUser),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.celestialGold,
                    foregroundColor: AppColors.primaryNavy,
                  ),
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Play Audio'),
                  onPressed: () => audioProvider.playHymn(widget.hymn),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
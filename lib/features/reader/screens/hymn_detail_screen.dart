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
    WakelockPlus.enable();
  }

  @override
  void dispose() {
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.cardNavy : Colors.white,
        title: Text(
          'PRO Feature',
          style: TextStyle(
            color: isDark ? AppColors.celestialGold : AppColors.primaryNavy,
          ),
        ),
        content: Text(
          'Hands-free Auto-Scroll is exclusive to PRO users. Enable PRO mode in the Settings menu to unlock.',
          style: TextStyle(
            color: isDark ? AppColors.textWhite : AppColors.lightTextPrimary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'OK',
              style: TextStyle(
                color: isDark ? AppColors.celestialGold : AppColors.primaryNavy,
              ),
            ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Clean title for display
    final cleanTitle = widget.hymn.title
        .replaceAll(RegExp(r'^OLUYIMBA\s+\d+:\s*', caseSensitive: false), '')
        .replaceAll(' Song Lyrics', '')
        .trim();

    return Scaffold(
      backgroundColor: isDark ? AppColors.primaryNavy : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.primaryNavy : Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hymn ${widget.hymn.number}',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
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
        ),
        actions: [
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
        ],
      ),
      body: Column(
        children: [
          // Subtle divider under AppBar
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

          // Bottom control bar
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
                  // Auto-scroll button
                  Container(
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.celestialGold.withOpacity(0.15)
                          : AppColors.celestialGold.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: Icon(
                        _isAutoScrolling
                            ? Icons.pause_rounded
                            : Icons.unfold_more_rounded,
                        color: isDark ? AppColors.celestialGold : AppColors.primaryNavy,
                      ),
                      onPressed: () => _toggleAutoScroll(settings.isProUser),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Play Audio button
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.celestialGold,
                        foregroundColor: AppColors.primaryNavy,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.play_arrow_rounded, size: 22),
                      label: const Text(
                        'Play Audio',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      onPressed: () => audioProvider.playHymn(widget.hymn),
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
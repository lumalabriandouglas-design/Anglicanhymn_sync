import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/verse_parser.dart';
import '../../../core/widgets/responsive_center.dart';
import '../../../providers/settings_provider.dart';

class DualLyricsView extends StatefulWidget {
  final String lyricsLuganda;
  final String lyricsEnglish;
  final double fontSize;
  final LyricsLanguage language;
  final ScrollController scrollController;

  const DualLyricsView({
    super.key,
    required this.lyricsLuganda,
    required this.lyricsEnglish,
    required this.fontSize,
    required this.language,
    required this.scrollController,
  });

  @override
  State<DualLyricsView> createState() => _DualLyricsViewState();
}

class _DualLyricsViewState extends State<DualLyricsView> {
  late int _selectedLanguageIndex;

  @override
  void initState() {
    super.initState();
    // Respect the global setting when the screen opens
    switch (widget.language) {
      case LyricsLanguage.luganda:
        _selectedLanguageIndex = 0;
        break;
      case LyricsLanguage.english:
        _selectedLanguageIndex = 1;
        break;
      case LyricsLanguage.both:
        _selectedLanguageIndex = 0; // default to Luganda first when "Both"
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool showBoth = widget.language == LyricsLanguage.both;
    final bool hasEnglish = widget.lyricsEnglish.trim().isNotEmpty;

    return ResponsiveCenter(
      child: Column(
        children: [
          const SizedBox(height: 12),

          // Language switcher (only show if English exists)
          if (hasEnglish)
            Container(
              width: showBoth ? 280 : 220,
              height: 38,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  _buildPillOption('Luganda', 0),
                  _buildPillOption('English', 1),
                  if (showBoth) _buildPillOption('Both', 2),
                ],
              ),
            ),

          const SizedBox(height: 12),

          Expanded(
            child: SingleChildScrollView(
              controller: widget.scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: _buildLyricsContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLyricsContent() {
    // Both mode
    if (_selectedLanguageIndex == 2) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Luganda',
            style: TextStyle(
              fontSize: widget.fontSize - 2,
              fontWeight: FontWeight.bold,
              color: AppColors.celestialGold,
            ),
          ),
          const SizedBox(height: 8),
          VerseParser.buildFormattedLyrics(
            widget.lyricsLuganda,
            widget.fontSize,
          ),
          const SizedBox(height: 28),
          Text(
            'English',
            style: TextStyle(
              fontSize: widget.fontSize - 2,
              fontWeight: FontWeight.bold,
              color: AppColors.celestialGold,
            ),
          ),
          const SizedBox(height: 8),
          VerseParser.buildFormattedLyrics(
            widget.lyricsEnglish,
            widget.fontSize,
          ),
        ],
      );
    }

    // Single language
    final lyrics = _selectedLanguageIndex == 0
        ? widget.lyricsLuganda
        : widget.lyricsEnglish;

    return VerseParser.buildFormattedLyrics(lyrics, widget.fontSize);
  }

  Widget _buildPillOption(String label, int index) {
    final isSelected = _selectedLanguageIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedLanguageIndex = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.celestialGold : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? AppColors.primaryNavy
                  : Theme.of(context).textTheme.bodyMedium?.color,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
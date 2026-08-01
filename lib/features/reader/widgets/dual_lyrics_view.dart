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
  late PageController _pageController;
  late int _currentPage; // 0 = Luganda, 1 = English, 2 = Both

  @override
  void initState() {
    super.initState();
    switch (widget.language) {
      case LyricsLanguage.luganda:
        _currentPage = 0;
        break;
      case LyricsLanguage.english:
        _currentPage = 1;
        break;
      case LyricsLanguage.both:
        _currentPage = 2;
        break;
    }
    _pageController = PageController(initialPage: _currentPage == 2 ? 0 : _currentPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool hasEnglish = widget.lyricsEnglish.trim().isNotEmpty;

    return ResponsiveCenter(
      child: Column(
        children: [
          const SizedBox(height: 10),

          // Language pills
          if (hasEnglish)
            Container(
              width: 270,
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  _buildPill('Luganda', 0),
                  _buildPill('English', 1),
                  _buildPill('Both', 2),
                ],
              ),
            ),

          const SizedBox(height: 14),

          // Content
          Expanded(
            child: _currentPage == 2
                ? _buildSideBySide()
                : PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() => _currentPage = index);
                    },
                    children: [
                      _buildSingleLanguage(widget.lyricsLuganda),
                      _buildSingleLanguage(widget.lyricsEnglish),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPill(String label, int index) {
    final isSelected = _currentPage == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _currentPage = index);
          if (index < 2) {
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
            );
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.celestialGold : Colors.transparent,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? AppColors.primaryNavy
                  : Theme.of(context).textTheme.bodyMedium?.color,
              fontWeight: FontWeight.w700,
              fontSize: 13.5,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSingleLanguage(String lyrics) {
    return SingleChildScrollView(
      controller: widget.scrollController,
      padding: const EdgeInsets.fromLTRB(22, 8, 22, 30),
      child: VerseParser.buildFormattedLyrics(lyrics, widget.fontSize),
    );
  }

  /// Improved side-by-side layout
  Widget _buildSideBySide() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Luganda column
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                right: BorderSide(color: Colors.grey.withOpacity(0.25), width: 1),
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 4, 12, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Luganda',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.celestialGold,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 10),
                  VerseParser.buildFormattedLyrics(
                    widget.lyricsLuganda,
                    widget.fontSize - 1.5,
                  ),
                ],
              ),
            ),
          ),
        ),

        // English column
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(12, 4, 16, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'English',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.celestialGold,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 10),
                VerseParser.buildFormattedLyrics(
                  widget.lyricsEnglish,
                  widget.fontSize - 1.5,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
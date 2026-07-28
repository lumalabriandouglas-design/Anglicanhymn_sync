import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/verse_parser.dart';
import '../../../core/widgets/responsive_center.dart';

class DualLyricsView extends StatefulWidget {
  final String lyricsLuganda;
  final String lyricsEnglish;
  final double fontSize;
  final ScrollController scrollController;

  const DualLyricsView({
    super.key,
    required this.lyricsLuganda,
    required this.lyricsEnglish,
    required this.fontSize,
    required this.scrollController,
  });

  @override
  State<DualLyricsView> createState() => _DualLyricsViewState();
}

class _DualLyricsViewState extends State<DualLyricsView> {
  int _selectedLanguageIndex = 0; // 0 = Luganda, 1 = English

  @override
  Widget build(BuildContext context) {
    return ResponsiveCenter(
      child: Column(
        children: [
          const SizedBox(height: 12),
          // Segmented Pill Control
          Container(
            width: 220,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.cardNavy,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                _buildPillOption('Luganda', 0),
                _buildPillOption('English', 1),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: SingleChildScrollView(
              controller: widget.scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: VerseParser.buildFormattedLyrics(
                _selectedLanguageIndex == 0 ? widget.lyricsLuganda : widget.lyricsEnglish,
                widget.fontSize,
              ),
            ),
          ),
        ],
      ),
    );
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
              color: isSelected ? AppColors.primaryNavy : AppColors.textGrey,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
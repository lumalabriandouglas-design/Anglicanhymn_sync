import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/hymn_audio.dart';
import '../../../models/hymn.dart';
import '../../reader/screens/hymn_detail_screen.dart';

class HymnTile extends StatelessWidget {
  final Hymn hymn;
  final VoidCallback? onTap;
  final VoidCallback? onPlayTap;

  const HymnTile({
    super.key,
    required this.hymn,
    this.onTap,
    this.onPlayTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? AppColors.textWhite : AppColors.lightTextPrimary;
    final subtitleColor = isDark ? Colors.grey.shade400 : AppColors.lightTextSecondary;
    final cardColor = isDark ? AppColors.cardNavy : Colors.white;
    final numberBg = isDark
        ? AppColors.celestialGold.withOpacity(0.15)
        : AppColors.celestialGold.withOpacity(0.12);
    final numberColor = isDark ? AppColors.celestialGold : AppColors.primaryNavy;

    // Get a clean first line for the preview
    final lyricPreview = hymn.lyricsLuganda
        .split('\n')
        .map((e) => e.trim())
        .firstWhere(
          (line) => line.isNotEmpty && !RegExp(r'^\d+\.?$').hasMatch(line),
          orElse: () => 'Tap to view hymn lyrics',
        );

    return Container(
      margin: const EdgeInsets.only(bottom: 10, left: 4, right: 4),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap ??
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HymnDetailScreen(hymn: hymn),
                  ),
                );
              },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                // Number badge
                Container(
                  width: 46,
                  height: 46,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: numberBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    hymn.number,
                    style: TextStyle(
                      color: numberColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Title + preview
                                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hymn.title
                            .replaceAll(RegExp(r'^OLUYIMBA\s+\d+:\s*', caseSensitive: false), '')
                            .replaceAll(' Song Lyrics', '')
                            .trim(),
                        style: GoogleFonts.lora(
                          fontWeight: FontWeight.w700,
                          fontSize: 15.5,
                          color: titleColor,
                          height: 1.25,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        hymn.hasEnglishTitle ? hymn.titleEnglish : lyricPreview,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: subtitleColor,
                          fontSize: 13,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),

                if (HymnAudio.hasAudio(hymn))
                  IconButton(
                    icon: Icon(
                      Icons.play_circle_outline_rounded,
                      color: isDark ? AppColors.celestialGold : AppColors.primaryNavy,
                      size: 28,
                    ),
                    onPressed: onPlayTap,
                  )
                else
                  const SizedBox(width: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
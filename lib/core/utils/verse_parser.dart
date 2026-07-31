import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class VerseParser {
  static Widget buildFormattedLyrics(String rawLyrics, double fontSize) {
    if (rawLyrics.trim().isEmpty) {
      return Center(
        child: Text(
          'Lyrics not available.',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: fontSize - 2,
          ),
        ),
      );
    }

    final stanzas = rawLyrics.split(RegExp(r'\n\s*\n'));

    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final textColor =
            isDark ? AppColors.textWhite : AppColors.lightTextPrimary;
        final chorusBg = isDark
            ? AppColors.surfaceLight.withOpacity(0.4)
            : AppColors.celestialGold.withOpacity(0.13);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: stanzas.map((stanza) {
            final trimmed = stanza.trim();
            final isChorus = trimmed.toLowerCase().startsWith('chorus') ||
                trimmed.toLowerCase().startsWith('ekyitiriddwa');

            if (isChorus) {
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: chorusBg,
                  borderRadius: BorderRadius.circular(10),
                  border: const Border(
                    left: BorderSide(color: AppColors.celestialGold, width: 3),
                  ),
                ),
                child: Text(
                  trimmed,
                  style: GoogleFonts.lora(
                    color: textColor,
                    fontSize: fontSize,
                    fontWeight: FontWeight.w700, // thick
                    fontStyle: FontStyle.italic,
                    height: 1.65,
                  ),
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Text(
                trimmed,
                style: GoogleFonts.lora(
                  color: textColor,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w700, // thick
                  height: 1.65,
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
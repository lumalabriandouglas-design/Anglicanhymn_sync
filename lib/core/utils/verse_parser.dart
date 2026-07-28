import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class VerseParser {
  static Widget buildFormattedLyrics(String rawLyrics, double fontSize) {
    if (rawLyrics.trim().isEmpty) {
      return const Center(
        child: Text('Lyrics not available.', style: TextStyle(color: AppColors.textGrey)),
      );
    }

    // Split text into stanzas separated by double line breaks
    final stanzas = rawLyrics.split(RegExp(r'\n\s*\n'));

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
              color: AppColors.surfaceLight.withOpacity(0.4),
              borderRadius: BorderRadius.circular(10),
              border: const Border(
                left: BorderSide(color: AppColors.celestialGold, width: 3),
              ),
            ),
            child: Text(
              trimmed,
              style: GoogleFonts.lora(
                color: AppColors.textWhite,
                fontSize: fontSize,
                fontStyle: FontStyle.italic,
                height: 1.6,
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: Text(
            trimmed,
            style: GoogleFonts.lora(
              color: AppColors.textWhite,
              fontSize: fontSize,
              height: 1.6,
            ),
          ),
        );
      }).toList(),
    );
  }
}
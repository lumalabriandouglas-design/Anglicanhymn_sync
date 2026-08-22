import '../core/utils/data_cleaner.dart';

class Hymn {
  final String number;
  final String title;
  final String titleEnglish;
  final String lyricsLuganda;
  final String lyricsEnglish;
  final String? audioUrl;
  bool isFavorite;

  Hymn({
    required this.number,
    required this.title,
    this.titleEnglish = '',
    required this.lyricsLuganda,
    this.lyricsEnglish = '',
    this.audioUrl,
    this.isFavorite = false,
  });

  bool get hasEnglishTitle => titleEnglish.trim().isNotEmpty;

  factory Hymn.fromJson(Map<String, dynamic> json, [int? index]) {
    final rawLuganda =
        json['lyrics']?.toString() ?? json['lyricsLuganda']?.toString() ?? '';
    final rawEnglish = json['lyricsEnglish']?.toString() ?? '';
    final lugandaTitle = cleanTitle(
      json['title']?.toString() ?? 'Untitled Hymn',
    );
    final englishTitle = cleanTitle(
      json['titleEnglish']?.toString() ?? '',
    );

    return Hymn(
      number: json['n']?.toString() ??
          json['number']?.toString() ??
          '${(index ?? 0) + 1}',
      title: lugandaTitle,
      titleEnglish: englishTitle,
      lyricsLuganda: cleanHymnLyrics(rawLuganda),
      lyricsEnglish: cleanHymnLyrics(rawEnglish),
      audioUrl: json['audioUrl'] ?? json['audio_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'n': int.tryParse(number) ?? number,
      'title': title,
      'titleEnglish': titleEnglish,
      'lyrics': lyricsLuganda,
      'lyricsEnglish': lyricsEnglish,
      'audioUrl': audioUrl,
    };
  }
}
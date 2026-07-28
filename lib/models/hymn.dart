import '../core/utils/data_cleaner.dart';

class Hymn {
  final String number;
  final String title;
  final String lyricsLuganda;
  final String lyricsEnglish;
  final String? audioUrl;
  bool isFavorite;

  Hymn({
    required this.number,
    required this.title,
    required this.lyricsLuganda,
    this.lyricsEnglish = '',
    this.audioUrl,
    this.isFavorite = false,
  });

  factory Hymn.fromJson(Map<String, dynamic> json, [int? index]) {
    final rawLuganda = json['lyrics']?.toString() ?? json['lyricsLuganda']?.toString() ?? '';
    final rawEnglish = json['lyricsEnglish']?.toString() ?? '';

    return Hymn(
      number: json['n']?.toString() ?? json['number']?.toString() ?? '${(index ?? 0) + 1}',
      title: cleanTitle(json['title']?.toString() ?? json['titleEnglish']?.toString() ?? 'Untitled Hymn'),
      lyricsLuganda: cleanHymnLyrics(rawLuganda),
      lyricsEnglish: cleanHymnLyrics(rawEnglish),
      audioUrl: json['audioUrl'] ?? json['audio_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'n': int.tryParse(number) ?? number,
      'title': title,
      'lyrics': lyricsLuganda,
      'lyricsEnglish': lyricsEnglish,
      'audioUrl': audioUrl,
    };
  }
}
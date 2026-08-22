import '../../models/hymn.dart';

class _RankedHymn {
  final Hymn hymn;
  final int score;

  _RankedHymn({required this.hymn, required this.score});
}

class SearchEngine {
  static String normalize(String input) {
    return input
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static int _textScore(String raw, String rawQuery, String norm, String normQuery,
      {int exact = 80, int contains = 40}) {
    if (raw.isEmpty && norm.isEmpty) return 0;

    if (raw == rawQuery || (norm.isNotEmpty && norm == normQuery)) {
      return exact;
    }
    if (raw.contains(rawQuery) ||
        (normQuery.isNotEmpty && norm.contains(normQuery))) {
      return contains;
    }
    return 0;
  }

  /// Weighted search: number, Luganda title, English title, lyrics
  static List<Hymn> search(List<Hymn> hymns, String query) {
    final rawQuery = query.trim().toLowerCase();
    final normQuery = normalize(query);
    if (rawQuery.isEmpty) return hymns;

    final List<_RankedHymn> rankedResults = [];

    for (final hymn in hymns) {
      int score = 0;

      final numLower = hymn.number.toLowerCase();
      final titleLower = hymn.title.toLowerCase();
      final titleEnLower = hymn.titleEnglish.toLowerCase();
      final titleNorm = normalize(hymn.title);
      final titleEnNorm = normalize(hymn.titleEnglish);
      final lugandaLower = hymn.lyricsLuganda.toLowerCase();
      final englishLower = hymn.lyricsEnglish.toLowerCase();
      final lugandaNorm = normalize(hymn.lyricsLuganda);
      final englishNorm = normalize(hymn.lyricsEnglish);

      // Number matches
      if (numLower == rawQuery) {
        score += 100;
      } else if (numLower.startsWith(rawQuery)) {
        score += 70;
      } else if (numLower.contains(rawQuery)) {
        score += 50;
      }

      // Luganda title
      score += _textScore(
        titleLower,
        rawQuery,
        titleNorm,
        normQuery,
        exact: 80,
        contains: 40,
      );

      // English title (same weight as Luganda title)
      score += _textScore(
        titleEnLower,
        rawQuery,
        titleEnNorm,
        normQuery,
        exact: 80,
        contains: 45,
      );

      // Lyrics
      if (lugandaLower.contains(rawQuery) ||
          (normQuery.isNotEmpty && lugandaNorm.contains(normQuery))) {
        score += 20;
      }
      if (englishLower.contains(rawQuery) ||
          (normQuery.isNotEmpty && englishNorm.contains(normQuery))) {
        score += 15;
      }

      if (score > 0) {
        rankedResults.add(_RankedHymn(hymn: hymn, score: score));
      }
    }

    rankedResults.sort((a, b) => b.score.compareTo(a.score));
    return rankedResults.map((e) => e.hymn).toList();
  }

  static List<Hymn> searchHymns(List<Hymn> hymns, String query) =>
      search(hymns, query);
}
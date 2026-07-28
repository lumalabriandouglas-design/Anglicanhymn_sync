import '../../models/hymn.dart';

class _RankedHymn {
  final Hymn hymn;
  final int score;

  _RankedHymn({required this.hymn, required this.score});
}

class SearchEngine {
  /// Weighted search matching hymn numbers, titles, and verse lyrics
  static List<Hymn> search(List<Hymn> hymns, String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return hymns;

    final List<_RankedHymn> rankedResults = [];

    for (final hymn in hymns) {
      int score = 0;

      final numLower = hymn.number.toLowerCase();
      final titleLower = hymn.title.toLowerCase();
      final lugandaLower = hymn.lyricsLuganda.toLowerCase();
      final englishLower = hymn.lyricsEnglish.toLowerCase();

      // Number matches
      if (numLower == q) {
        score += 100;
      } else if (numLower.startsWith(q)) {
        score += 70;
      } else if (numLower.contains(q)) {
        score += 50;
      }

      // Title matches
      if (titleLower == q) {
        score += 80;
      } else if (titleLower.contains(q)) {
        score += 40;
      }

      // Lyrics matches
      if (lugandaLower.contains(q)) {
        score += 20;
      }
      if (englishLower.contains(q)) {
        score += 15;
      }

      if (score > 0) {
        rankedResults.add(_RankedHymn(hymn: hymn, score: score));
      }
    }

    // Sort descending by relevance score
    rankedResults.sort((a, b) => b.score.compareTo(a.score));

    return rankedResults.map((e) => e.hymn).toList();
  }

  /// Alias method matching HymnProvider calls
  static List<Hymn> searchHymns(List<Hymn> hymns, String query) =>
      search(hymns, query);
}
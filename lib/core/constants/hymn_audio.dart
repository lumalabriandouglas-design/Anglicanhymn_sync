import '../../models/hymn.dart';

class HymnAudio {
  static const String r2Base =
      'https://pub-22426af78c4e41d989b240b35aa21225.r2.dev';

  /// Real Cloudflare R2 files, keyed by hymn number.
  /// Add a new line here whenever you upload another track.
  static const Map<String, String> byNumber = {
    '332':
        'https://pub-22426af78c4e41d989b240b35aa21225.r2.dev/What%20A%20Friend%20We%20Have%20In%20Jesus%20Lyric%20Video%20Lydia%20Walker%20Acoustic%20Hymns%20with%20Lyrics-128.m4a',
  };

  static String? urlFor(Hymn hymn) {
    final fromJson = hymn.audioUrl?.trim();
    if (fromJson != null && fromJson.isNotEmpty) return fromJson;

    final mapped = byNumber[hymn.number];
    if (mapped != null) return mapped;

    // Backup match for 332 if the number is ever off
    final blob =
        '${hymn.title} ${hymn.titleEnglish}'.toLowerCase();
    if (blob.contains('nina omukwano') ||
        blob.contains('nnina omukwano') ||
        blob.contains('nnina-omukwano') ||
        blob.contains('omukwano gwange') ||
        blob.contains('what a friend')) {
      return byNumber['332'];
    }

    return null;
  }

  static bool hasAudio(Hymn hymn) => urlFor(hymn) != null;
}
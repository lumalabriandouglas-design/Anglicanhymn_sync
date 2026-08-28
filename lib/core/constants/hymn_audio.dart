import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../models/audio_track.dart';
import '../../models/hymn.dart';
import '../../providers/settings_provider.dart';

class HymnAudio {
  static const String r2Base =
      'https://pub-22426af78c4e41d989b240b35aa21225.r2.dev';

  static const String remoteCatalogueUrl =
      'https://pub-22426af78c4e41d989b240b35aa21225.r2.dev/audio-catalogue.json';

  static List<AudioTrack> tracks = [];
  static bool _loaded = false;

  static const Map<String, String> byNumber = {
    '332':
        'https://pub-22426af78c4e41d989b240b35aa21225.r2.dev/What%20A%20Friend%20We%20Have%20In%20Jesus%20Lyric%20Video%20Lydia%20Walker%20Acoustic%20Hymns%20with%20Lyrics-128.m4a',
  };

  static Future<void> load() async {
    if (_loaded && tracks.isNotEmpty) return;

    try {
      final raw = await rootBundle.loadString('assets/audio-catalogue.json');
      final decoded = json.decode(raw) as Map<String, dynamic>;
      final list = decoded['tracks'] as List<dynamic>? ?? [];
      tracks = list
          .map((e) => AudioTrack.fromJson(e as Map<String, dynamic>))
          .toList();
      _loaded = true;
    } catch (e) {
      debugPrint('HymnAudio.load failed: $e');
      tracks = [
        AudioTrack(
          id: '332-en',
          hymnNumber: '332',
          language: 'english',
          title: 'What a Friend We Have in Jesus',
          url: byNumber['332']!,
          type: AudioTrackType.hymn,
        ),
      ];
      _loaded = true;
    }
  }

  static List<AudioTrack> tracksForHymn(String number) {
    return tracks.where((t) => t.isHymn && t.hymnNumber == number).toList();
  }

  static List<AudioTrack> get extraTracks =>
      tracks.where((t) => t.isExtra).toList();

  static String? urlFor(Hymn hymn, {LyricsLanguage? language}) {
    final fromJson = hymn.audioUrl?.trim();
    if (fromJson != null && fromJson.isNotEmpty && language == null) {
      return fromJson;
    }

    final lang = language ?? LyricsLanguage.english;
    final matches = tracksForHymn(hymn.number);

    String? pick(String wanted) {
      for (final t in matches) {
        if (t.language == wanted) return t.url;
      }
      return null;
    }

    final fallback = matches.isEmpty ? null : matches.first.url;
    if (lang == LyricsLanguage.luganda) {
      return pick('luganda') ?? pick('english') ?? fallback;
    }
    if (lang == LyricsLanguage.english) {
      return pick('english') ?? pick('luganda') ?? fallback;
    }
    return pick('english') ?? pick('luganda') ?? fallback ?? byNumber[hymn.number];
  }

  static bool hasAudio(Hymn hymn) {
    if (hymn.audioUrl != null && hymn.audioUrl!.trim().isNotEmpty) return true;
    if (tracksForHymn(hymn.number).isNotEmpty) return true;
    if (byNumber.containsKey(hymn.number)) return true;

    final blob = '${hymn.title} ${hymn.titleEnglish}'.toLowerCase();
    if (blob.contains('nina omukwano') ||
        blob.contains('nnina omukwano') ||
        blob.contains('omukwano gwange') ||
        blob.contains('what a friend')) {
      return true;
    }
    return false;
  }

  static bool hasLanguage(Hymn hymn, String language) {
    return tracksForHymn(hymn.number).any((t) => t.language == language);
  }
}

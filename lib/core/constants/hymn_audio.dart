import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../../models/audio_track.dart';
import '../../models/hymn.dart';
import '../../providers/settings_provider.dart';
import '../services/storage_service.dart';

class HymnAudio {
  static const String r2Base =
      'https://pub-22426af78c4e41d989b240b35aa21225.r2.dev';

  static const String remoteCatalogueUrl =
      'https://pub-22426af78c4e41d989b240b35aa21225.r2.dev/audio-catalogue.json';

  static const String cacheKey = 'app_audio_catalogue_json';

  static List<AudioTrack> tracks = [];
  static bool loadedFromRemote = false;

  static const Map<String, String> byNumber = {
    '332':
        'https://pub-22426af78c4e41d989b240b35aa21225.r2.dev/What%20A%20Friend%20We%20Have%20In%20Jesus%20Lyric%20Video%20Lydia%20Walker%20Acoustic%20Hymns%20with%20Lyrics-128.m4a',
  };

  static List<AudioTrack> _parse(String raw) {
    final decoded = json.decode(raw);
    final list = decoded is Map<String, dynamic>
        ? (decoded['tracks'] as List<dynamic>? ?? [])
        : (decoded is List ? decoded : <dynamic>[]);
    return list
        .whereType<Map>()
        .map((e) => AudioTrack.fromJson(Map<String, dynamic>.from(e)))
        .where((t) => t.url.isNotEmpty)
        .toList();
  }

  static List<AudioTrack> _fallback332() {
    return [
      AudioTrack(
        id: '332-en',
        hymnNumber: '332',
        language: 'english',
        title: 'What a Friend We Have in Jesus',
        url: byNumber['332']!,
        type: AudioTrackType.hymn,
      ),
    ];
  }

  /// Instant local load: cache, then bundled asset, then hardcoded 332.
  static Future<void> loadLocal([StorageService? storage]) async {
    try {
      final cached = storage?.getString(cacheKey);
      if (cached != null && cached.trim().isNotEmpty) {
        final parsed = _parse(cached);
        if (parsed.isNotEmpty) {
          tracks = parsed;
          return;
        }
      }
    } catch (e) {
      debugPrint('HymnAudio cache parse failed: $e');
    }

    try {
      final raw = await rootBundle.loadString('assets/audio-catalogue.json');
      final parsed = _parse(raw);
      tracks = parsed.isNotEmpty ? parsed : _fallback332();
    } catch (e) {
      debugPrint('HymnAudio bundled load failed: $e');
      tracks = _fallback332();
    }
  }

  /// Pull latest catalogue from R2. Returns true if tracks changed.
  static Future<bool> refreshFromRemote([StorageService? storage]) async {
    try {
      final response = await http
          .get(Uri.parse(remoteCatalogueUrl))
          .timeout(const Duration(seconds: 8));
      if (response.statusCode != 200 || response.body.trim().isEmpty) {
        debugPrint('HymnAudio remote status ${response.statusCode}');
        return false;
      }

      final parsed = _parse(response.body);
      if (parsed.isEmpty) return false;

      final changed = json.encode(tracks.map((t) => t.toJson()).toList()) !=
          json.encode(parsed.map((t) => t.toJson()).toList());

      tracks = parsed;
      loadedFromRemote = true;
      await storage?.setString(cacheKey, response.body);
      return changed || true;
    } catch (e) {
      debugPrint('HymnAudio remote load failed: $e');
      return false;
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
    return pick('english') ??
        pick('luganda') ??
        fallback ??
        byNumber[hymn.number];
  }

  static bool hasAudio(Hymn hymn) {
    if (hymn.audioUrl != null && hymn.audioUrl!.trim().isNotEmpty) return true;
    if (tracksForHymn(hymn.number).isNotEmpty) return true;
    return byNumber.containsKey(hymn.number);
  }

  static bool hasLanguage(Hymn hymn, String language) {
    return tracksForHymn(hymn.number).any((t) => t.language == language);
  }
}

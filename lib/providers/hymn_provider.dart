import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../core/constants/hymn_audio.dart';
import '../core/services/storage_service.dart';
import '../core/utils/search_engine.dart';
import '../models/hymn.dart';

class HymnProvider extends ChangeNotifier {
  final StorageService _storageService;

  List<Hymn> _allHymns = [];
  String _searchQuery = '';
  bool _isLoading = true;
  String? _errorMessage;
  bool _audioCatalogueReady = false;
  bool _englishOnly = false;

  HymnProvider(this._storageService);

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Hymn> get allHymns => _allHymns;
  String get searchQuery => _searchQuery;
  bool get audioCatalogueReady => _audioCatalogueReady;
  bool get englishOnly => _englishOnly;
  int get englishCount =>
      _allHymns.where((h) => h.hasEnglishLyrics).length;

  List<Hymn> get favoriteHymns =>
      _allHymns.where((h) => h.isFavorite).toList();

  List<Hymn> get filteredHymns {
    var list = _englishOnly
        ? _allHymns.where((h) => h.hasEnglishLyrics).toList()
        : _allHymns;
    if (_searchQuery.trim().isEmpty) {
      return list;
    }
    return SearchEngine.searchHymns(list, _searchQuery);
  }

  Future<void> loadHymns() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await HymnAudio.loadLocal(_storageService);

      final String jsonString =
          await rootBundle.loadString('assets/hymns-full.json');
      final List<dynamic> data = json.decode(jsonString);
      final List<String> favoriteIds = _storageService.getFavorites();

      _allHymns = data.asMap().entries.map((entry) {
        final hymn =
            Hymn.fromJson(entry.value as Map<String, dynamic>, entry.key);
        if (favoriteIds.contains(hymn.number)) {
          hymn.isFavorite = true;
        }
        return hymn;
      }).toList();

      try {
        final overlayRaw =
            await rootBundle.loadString('assets/english-overlay.json');
        final overlay = json.decode(overlayRaw) as Map<String, dynamic>;
        _allHymns = _allHymns.map((h) {
          final extra = overlay[h.number];
          if (extra is Map) {
            final title = extra['titleEnglish']?.toString().trim() ?? '';
            final lyrics = extra['lyricsEnglish']?.toString().trim() ?? '';
            if (title.isEmpty && lyrics.isEmpty) return h;
            return h.copyWith(
              titleEnglish: title.isNotEmpty ? title : h.titleEnglish,
              lyricsEnglish: lyrics.isNotEmpty ? lyrics : h.lyricsEnglish,
            );
          }
          return h;
        }).toList();
      } catch (e) {
        debugPrint('English overlay skipped: $e');
      }

      // 193 is Mugabi w'ebirabo. Rock of Ages belongs on 176.
      _allHymns = _allHymns.map(_correctEnglish).toList();
    } catch (e) {
      _errorMessage = 'Failed to load hymn book. Please check the data file.';
      debugPrint('Error loading hymns database: $e');
      _allHymns = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    // Do not block the hymn book on the network.
    final updated = await HymnAudio.refreshFromRemote(_storageService);
    _audioCatalogueReady =
        HymnAudio.loadedFromRemote || HymnAudio.tracks.isNotEmpty;
    if (updated) notifyListeners();
  }

  Hymn _correctEnglish(Hymn hymn) {
    if (hymn.number == '193') {
      return hymn.copyWith(titleEnglish: '', lyricsEnglish: '');
    }
    return hymn;
  }

  Future<void> refreshAudioCatalogue() async {
    final updated = await HymnAudio.refreshFromRemote(_storageService);
    _audioCatalogueReady =
        HymnAudio.loadedFromRemote || HymnAudio.tracks.isNotEmpty;
    if (updated) notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setEnglishOnly(bool value) {
    _englishOnly = value;
    notifyListeners();
  }

  Future<void> toggleFavorite(Hymn hymn) async {
    hymn.isFavorite = !hymn.isFavorite;
    final favoriteIds =
        _allHymns.where((h) => h.isFavorite).map((h) => h.number).toList();
    await _storageService.saveFavorites(favoriteIds);
    notifyListeners();
  }
}

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

  HymnProvider(this._storageService);

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Hymn> get allHymns => _allHymns;
  String get searchQuery => _searchQuery;

  List<Hymn> get favoriteHymns =>
      _allHymns.where((h) => h.isFavorite).toList();

  List<Hymn> get filteredHymns {
    if (_searchQuery.trim().isEmpty) {
      return _allHymns;
    }
    return SearchEngine.searchHymns(_allHymns, _searchQuery);
  }

  Future<void> loadHymns() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await HymnAudio.load();

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
    } catch (e) {
      _errorMessage = 'Failed to load hymn book. Please check the data file.';
      debugPrint('Error loading hymns database: $e');
      _allHymns = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
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

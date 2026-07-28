import 'package:flutter/material.dart';

import '../core/services/storage_service.dart';
import '../models/service_setlist.dart';

class SetlistProvider extends ChangeNotifier {
  final StorageService _storageService;
  List<ServiceSetlist> _setlists = [];

  SetlistProvider(this._storageService) {
    loadSetlists();
  }

  List<ServiceSetlist> get setlists => _setlists;

  void loadSetlists() {
    _setlists = _storageService.getSetlists();
    notifyListeners();
  }

  Future<void> addSetlist(ServiceSetlist setlist) async {
    _setlists.add(setlist);
    await _storageService.saveSetlists(_setlists);
    notifyListeners();
  }

  Future<void> deleteSetlist(String id) async {
    _setlists.removeWhere((s) => s.id == id);
    await _storageService.saveSetlists(_setlists);
    notifyListeners();
  }

  Future<void> addItemToSetlist(String setlistId, SetlistItem item) async {
    final index = _setlists.indexWhere((s) => s.id == setlistId);
    if (index != -1) {
      final updatedItems = List<SetlistItem>.from(_setlists[index].items)..add(item);
      final updatedSetlist = ServiceSetlist(
        id: _setlists[index].id,
        title: _setlists[index].title,
        date: _setlists[index].date,
        items: updatedItems,
      );
      _setlists[index] = updatedSetlist;
      await _storageService.saveSetlists(_setlists);
      notifyListeners();
    }
  }
}
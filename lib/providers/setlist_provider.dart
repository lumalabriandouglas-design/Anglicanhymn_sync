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

  ServiceSetlist? byId(String id) {
    try {
      return _setlists.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> addSetlist(ServiceSetlist setlist) async {
    _setlists.add(setlist);
    await _persist();
  }

  Future<void> deleteSetlist(String id) async {
    _setlists.removeWhere((s) => s.id == id);
    await _persist();
  }

  Future<void> addItemToSetlist(String setlistId, SetlistItem item) async {
    final index = _setlists.indexWhere((s) => s.id == setlistId);
    if (index == -1) return;
    final items = List<SetlistItem>.from(_setlists[index].items)..add(item);
    _setlists[index] = _setlists[index].copyWith(items: items);
    await _persist();
  }

  Future<void> removeItem(String setlistId, int itemIndex) async {
    final index = _setlists.indexWhere((s) => s.id == setlistId);
    if (index == -1) return;
    final items = List<SetlistItem>.from(_setlists[index].items);
    if (itemIndex < 0 || itemIndex >= items.length) return;
    items.removeAt(itemIndex);
    _setlists[index] = _setlists[index].copyWith(items: items);
    await _persist();
  }

  Future<void> reorderItems(String setlistId, int oldIndex, int newIndex) async {
    final index = _setlists.indexWhere((s) => s.id == setlistId);
    if (index == -1) return;
    final items = List<SetlistItem>.from(_setlists[index].items);
    if (newIndex > oldIndex) newIndex -= 1;
    final item = items.removeAt(oldIndex);
    items.insert(newIndex, item);
    _setlists[index] = _setlists[index].copyWith(items: items);
    await _persist();
  }

  Future<void> updateItemRole(
    String setlistId,
    int itemIndex,
    String role,
  ) async {
    final index = _setlists.indexWhere((s) => s.id == setlistId);
    if (index == -1) return;
    final items = List<SetlistItem>.from(_setlists[index].items);
    if (itemIndex < 0 || itemIndex >= items.length) return;
    final current = items[itemIndex];
    items[itemIndex] = SetlistItem(
      role: role,
      hymnNumber: current.hymnNumber,
      hymnTitle: current.hymnTitle,
    );
    _setlists[index] = _setlists[index].copyWith(items: items);
    await _persist();
  }

  Future<void> _persist() async {
    await _storageService.saveSetlists(_setlists);
    notifyListeners();
  }
}

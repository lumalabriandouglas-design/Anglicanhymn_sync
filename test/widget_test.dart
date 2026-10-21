import 'dart:convert';
import 'dart:io';

import 'package:anglican_hymn_sync/models/billing.dart';
import 'package:anglican_hymn_sync/models/hymn.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('bundled hymnal parses into hymns', () {
    final data =
        json.decode(File('assets/hymns-full.json').readAsStringSync()) as List;
    expect(data, isNotEmpty);
    final hymns = data
        .asMap()
        .entries
        .map((e) => Hymn.fromJson(e.value as Map<String, dynamic>, e.key))
        .toList();
    expect(hymns.length, data.length);
    expect(hymns.first.number, isNotEmpty);
  });

  test('billing config parses and stays free for everyone', () {
    final raw = json.decode(File('assets/billing.json').readAsStringSync())
        as Map<String, dynamic>;
    final config = BillingConfig.fromJson(raw);
    expect(config.plans, isNotEmpty);
    expect(raw['unlockedForEveryone'], isTrue);
  });

  test('both translations load: Luganda for every hymn, English for many', () {
    final data =
        json.decode(File('assets/hymns-full.json').readAsStringSync()) as List;
    final overlay = json.decode(
            File('assets/english-overlay.json').readAsStringSync())
        as Map<String, dynamic>;
    final hymns = data
        .asMap()
        .entries
        .map((e) => Hymn.fromJson(e.value as Map<String, dynamic>, e.key))
        .map((h) {
      final extra = overlay[h.number];
      if (extra is Map) {
        return h.copyWith(
          titleEnglish: extra['titleEnglish']?.toString() ?? h.titleEnglish,
          lyricsEnglish: extra['lyricsEnglish']?.toString() ?? h.lyricsEnglish,
        );
      }
      return h;
    }).toList();

    expect(hymns.every((h) => h.lyricsLuganda.trim().isNotEmpty), isTrue,
        reason: 'every hymn needs Luganda lyrics');
    final english = hymns.where((h) => h.hasEnglishLyrics).toList();
    expect(english.length, greaterThan(50),
        reason: 'English translations should load from the book and overlay');
    expect(english.first.lyricsEnglish, isNot(equals(english.first.lyricsLuganda)));
  });
}

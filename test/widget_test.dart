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

  test('audio catalogue is valid JSON', () {
    expect(
      () => json.decode(File('assets/audio-catalogue.json').readAsStringSync()),
      returnsNormally,
    );
  });
}

import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../models/billing.dart';
import '../constants/pro_features.dart';
import 'storage_service.dart';

class BillingService {
  BillingService(this._storage);

  final StorageService _storage;

  static const _claimsKey = 'app_payment_claims';
  static const _plusUntilKey = 'app_plus_until';
  static const _plusPhoneKey = 'app_plus_phone';
  static const _pinKey = 'app_steward_pin';
  static const _numbersKey = 'app_pay_numbers';
  static const _whatsappKey = 'app_pay_whatsapp';

  Future<BillingConfig> loadConfig() async {
    final raw = await rootBundle.loadString('assets/billing.json');
    final config = BillingConfig.fromJson(json.decode(raw) as Map<String, dynamic>);
    final savedNumbers = _storage.getString(_numbersKey);
    final savedWhatsapp = _storage.getString(_whatsappKey);
    var numbers = config.numbers;
    var whatsapp = config.whatsapp;
    if (savedNumbers != null && savedNumbers.trim().isNotEmpty) {
      try {
        final list = json.decode(savedNumbers) as List<dynamic>;
        numbers = list
            .whereType<Map>()
            .map((e) => PayNumber.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      } catch (e) {
        debugPrint('Pay numbers overlay skipped: $e');
      }
    }
    if (savedWhatsapp != null && savedWhatsapp.trim().isNotEmpty) {
      whatsapp = savedWhatsapp.trim();
    }
    return BillingConfig(
      currency: config.currency,
      whatsapp: whatsapp,
      numbers: numbers.isEmpty
          ? const [
              PayNumber(network: 'MTN', number: ''),
              PayNumber(network: 'Airtel', number: ''),
            ]
          : numbers,
      plans: config.plans,
      freeListening: config.freeListening,
      plusListening: config.plusListening,
    );
  }

  Future<void> saveNumbers(List<PayNumber> numbers, String whatsapp) {
    return Future.wait([
      _storage.setString(_numbersKey, jsonEncode(numbers.map((n) => n.toJson()).toList())),
      _storage.setString(_whatsappKey, whatsapp),
    ]).then((_) {});
  }

  String pin() => _storage.getString(_pinKey) ?? ProFeatures.defaultPin;

  Future<void> setPin(String value) => _storage.setString(_pinKey, value.trim());

  List<PaymentClaim> claims() {
    final raw = _storage.getString(_claimsKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = json.decode(raw) as List<dynamic>;
      return list
          .whereType<Map>()
          .map((e) => PaymentClaim.fromJson(Map<String, dynamic>.from(e)))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (_) {
      return [];
    }
  }

  Future<void> saveClaims(List<PaymentClaim> claims) {
    return _storage.setString(
      _claimsKey,
      jsonEncode(claims.map((c) => c.toJson()).toList()),
    );
  }

  DateTime? plusUntil() {
    final raw = _storage.getString(_plusUntilKey);
    if (raw == null || raw.isEmpty) return null;
    return DateTime.tryParse(raw);
  }

  String? plusPhone() => _storage.getString(_plusPhoneKey);

  bool get plusActive {
    final until = plusUntil();
    return until != null && until.isAfter(DateTime.now());
  }

  Future<void> activatePlus({required String phone, required int days}) async {
    final until = DateTime.now().add(Duration(days: days));
    await _storage.setString(_plusUntilKey, until.toIso8601String());
    await _storage.setString(_plusPhoneKey, phone);
  }

  static String digits(String phone) => phone.replaceAll(RegExp(r'\D'), '');

  static String activationCode({required String phone, required String planId}) {
    final raw = '${ProFeatures.codeSecret}|${digits(phone)}|$planId';
    var hash = 5381;
    for (final code in raw.codeUnits) {
      hash = ((hash << 5) + hash) + code;
      hash = hash & 0x7fffffff;
    }
    return (hash % 100000000).toString().padLeft(8, '0');
  }

  static String newClaimId() {
    final rand = Random();
    return 'P${DateTime.now().millisecondsSinceEpoch}${rand.nextInt(90) + 10}';
  }

  static String whatsappLink({required String whatsapp, required String text}) {
    final digitsOnly = digits(whatsapp);
    final intl = digitsOnly.startsWith('0')
        ? '256${digitsOnly.substring(1)}'
        : digitsOnly;
    return 'https://wa.me/$intl?text=${Uri.encodeComponent(text)}';
  }

  static String formatAmount(int amount, String currency) {
    final raw = amount.toString();
    final buf = StringBuffer();
    for (var i = 0; i < raw.length; i++) {
      final fromEnd = raw.length - i;
      buf.write(raw[i]);
      if (fromEnd > 1 && fromEnd % 3 == 1) buf.write(',');
    }
    return '$currency ${buf.toString()}';
  }
}

import 'package:flutter/material.dart';

import '../core/constants/pro_features.dart';
import '../core/services/billing_service.dart';
import '../models/billing.dart';

class BillingProvider extends ChangeNotifier {
  BillingProvider(this._service) {
    _load();
  }

  final BillingService _service;

  BillingConfig? _config;
  List<PaymentClaim> _claims = [];
  bool _ready = false;

  BillingConfig? get config => _config;
  List<PaymentClaim> get claims => _claims;
  bool get ready => _ready;
  bool get plusActive => _service.plusActive;
  DateTime? get plusUntil => _service.plusUntil();
  String? get plusPhone => _service.plusPhone();
  String get pin => _service.pin();

  bool get allOpen => ProFeatures.unlockedForEveryone;

  bool canUse(ListeningFeature feature) =>
      ProFeatures.canUse(feature, plusActive: plusActive);

  Future<void> _load() async {
    _config = await _service.loadConfig();
    _claims = _service.claims();
    _ready = true;
    notifyListeners();
  }

  Future<void> reload() => _load();

  Future<void> savePayIn({
    required List<PayNumber> numbers,
    required String whatsapp,
  }) async {
    await _service.saveNumbers(numbers, whatsapp);
    await _load();
  }

  Future<void> changePin(String value) async {
    await _service.setPin(value);
    notifyListeners();
  }

  bool checkPin(String value) => value.trim() == pin;

  Future<PaymentClaim> submitPaid({
    required String name,
    required String phone,
    required String network,
    required BillingPlan plan,
    String? txId,
  }) async {
    final claim = PaymentClaim(
      id: BillingService.newClaimId(),
      name: name.trim(),
      phone: phone.trim(),
      network: network,
      planId: plan.id,
      amount: plan.amount,
      txId: txId?.trim().isEmpty == true ? null : txId?.trim(),
      createdAt: DateTime.now(),
    );
    _claims = [claim, ..._claims];
    await _service.saveClaims(_claims);
    notifyListeners();
    return claim;
  }

  String codeFor(PaymentClaim claim) =>
      BillingService.activationCode(phone: claim.phone, planId: claim.planId);

  Future<String> markPaid(PaymentClaim claim) async {
    final code = codeFor(claim);
    claim.status = 'paid';
    claim.code = code;
    await _service.saveClaims(_claims);
    notifyListeners();
    return code;
  }

  Future<bool> redeem({required String phone, required String code}) async {
    final trimmed = code.replaceAll(RegExp(r'\s'), '');
    final config = _config;
    if (config == null) return false;
    for (final plan in config.plans) {
      final expected = BillingService.activationCode(phone: phone, planId: plan.id);
      if (expected == trimmed) {
        await _service.activatePlus(phone: phone, days: plan.days);
        notifyListeners();
        return true;
      }
    }
    return false;
  }

  String paidMessage(PaymentClaim claim) {
    BillingPlan? plan;
    for (final p in _config?.plans ?? const <BillingPlan>[]) {
      if (p.id == claim.planId) plan = p;
    }
    final amount = BillingService.formatAmount(
      claim.amount,
      _config?.currency ?? 'UGX',
    );
    return [
      'Anglican Hymn Sync — I have paid.',
      'Name: ${claim.name}',
      'Phone: ${claim.phone}',
      'Sent via: ${claim.network}',
      'Plan: ${plan?.name ?? claim.planId} ($amount)',
      if (claim.txId != null && claim.txId!.isNotEmpty) 'Tx ID: ${claim.txId}',
      'Claim: ${claim.id}',
    ].join('\n');
  }
}

class PayNumber {
  final String network;
  final String number;

  const PayNumber({required this.network, required this.number});

  PayNumber copyWith({String? network, String? number}) => PayNumber(
        network: network ?? this.network,
        number: number ?? this.number,
      );

  Map<String, dynamic> toJson() => {'network': network, 'number': number};

  factory PayNumber.fromJson(Map<String, dynamic> json) => PayNumber(
        network: json['network']?.toString() ?? '',
        number: json['number']?.toString() ?? '',
      );
}

class BillingPlan {
  final String id;
  final String name;
  final int amount;
  final int days;

  const BillingPlan({
    required this.id,
    required this.name,
    required this.amount,
    required this.days,
  });

  factory BillingPlan.fromJson(Map<String, dynamic> json) => BillingPlan(
        id: json['id']?.toString() ?? 'monthly',
        name: json['name']?.toString() ?? 'Plus',
        amount: int.tryParse(json['amount']?.toString() ?? '') ?? 0,
        days: int.tryParse(json['days']?.toString() ?? '') ?? 31,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'amount': amount,
        'days': days,
      };
}

class PaymentClaim {
  final String id;
  final String name;
  final String phone;
  final String network;
  final String planId;
  final int amount;
  final String? txId;
  final DateTime createdAt;
  String status;
  String? code;

  PaymentClaim({
    required this.id,
    required this.name,
    required this.phone,
    required this.network,
    required this.planId,
    required this.amount,
    this.txId,
    required this.createdAt,
    this.status = 'pending',
    this.code,
  });

  factory PaymentClaim.fromJson(Map<String, dynamic> json) => PaymentClaim(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        phone: json['phone']?.toString() ?? '',
        network: json['network']?.toString() ?? '',
        planId: json['planId']?.toString() ?? 'monthly',
        amount: int.tryParse(json['amount']?.toString() ?? '') ?? 0,
        txId: json['txId']?.toString(),
        createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
            DateTime.now(),
        status: json['status']?.toString() ?? 'pending',
        code: json['code']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'network': network,
        'planId': planId,
        'amount': amount,
        'txId': txId,
        'createdAt': createdAt.toIso8601String(),
        'status': status,
        'code': code,
      };
}

class BillingConfig {
  final String currency;
  final String whatsapp;
  final List<PayNumber> numbers;
  final List<BillingPlan> plans;
  final List<String> freeListening;
  final List<String> plusListening;

  const BillingConfig({
    required this.currency,
    required this.whatsapp,
    required this.numbers,
    required this.plans,
    required this.freeListening,
    required this.plusListening,
  });

  factory BillingConfig.fromJson(Map<String, dynamic> json) {
    return BillingConfig(
      currency: json['currency']?.toString() ?? 'UGX',
      whatsapp: json['whatsapp']?.toString() ?? '',
      numbers: (json['numbers'] as List<dynamic>? ?? [])
          .whereType<Map>()
          .map((e) => PayNumber.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      plans: (json['plans'] as List<dynamic>? ?? [])
          .whereType<Map>()
          .map((e) => BillingPlan.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      freeListening: (json['freeListening'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      plusListening: (json['plusListening'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }
}

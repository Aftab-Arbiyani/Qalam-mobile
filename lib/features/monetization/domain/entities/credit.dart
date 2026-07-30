/// Credit entities (AF5) — the AI credit wallet + ledger (`GET /monetization/credits`
/// and `/credits/transactions`).
library;

import '../../../../core/utils/typedefs.dart';

class CreditBalance {
  const CreditBalance({
    required this.balance,
    required this.lifetimeGranted,
    required this.lifetimeConsumed,
    required this.creditsPerUsd,
  });

  final int balance;
  final int lifetimeGranted;
  final int lifetimeConsumed;
  final int creditsPerUsd;

  factory CreditBalance.fromJson(Json json) => CreditBalance(
    balance: (json['balance'] as num?)?.toInt() ?? 0,
    lifetimeGranted: (json['lifetimeGranted'] as num?)?.toInt() ?? 0,
    lifetimeConsumed: (json['lifetimeConsumed'] as num?)?.toInt() ?? 0,
    creditsPerUsd: (json['creditsPerUsd'] as num?)?.toInt() ?? 100,
  );

  static const CreditBalance zero = CreditBalance(
    balance: 0,
    lifetimeGranted: 0,
    lifetimeConsumed: 0,
    creditsPerUsd: 100,
  );
}

class CreditTransaction {
  const CreditTransaction({
    required this.id,
    required this.type,
    required this.reason,
    required this.delta,
    required this.balanceAfter,
    required this.tokens,
    required this.costUsd,
    required this.createdAt,
    this.feature,
  });

  final String id;
  final String type;
  final String reason;
  final int delta;
  final int balanceAfter;
  final int tokens;
  final double costUsd;
  final DateTime createdAt;
  final String? feature;

  bool get isGrant => delta >= 0;

  factory CreditTransaction.fromJson(Json json) => CreditTransaction(
    id: json['id'] as String? ?? '',
    type: json['type'] as String? ?? '',
    reason: json['reason'] as String? ?? '',
    delta: (json['delta'] as num?)?.toInt() ?? 0,
    balanceAfter: (json['balanceAfter'] as num?)?.toInt() ?? 0,
    tokens: (json['tokens'] as num?)?.toInt() ?? 0,
    costUsd: (json['costUsd'] as num?)?.toDouble() ?? 0,
    createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0),
    feature: json['feature'] as String?,
  );
}

/// Billing entities (AF5) — invoices, payments, purchases, and the checkout result.
library;

import '../../../../core/utils/typedefs.dart';
import 'subscription.dart';

class Invoice {
  const Invoice({
    required this.id,
    required this.number,
    required this.status,
    required this.currency,
    required this.subtotal,
    required this.tax,
    required this.total,
    required this.createdAt,
    this.paidAt,
    this.hostedUrl,
    this.pdfUrl,
  });

  final String id;
  final String number;
  final String status;
  final String currency;
  final int subtotal;
  final int tax;
  final int total;
  final DateTime createdAt;
  final DateTime? paidAt;
  final String? hostedUrl;
  final String? pdfUrl;

  factory Invoice.fromJson(Json json) => Invoice(
    id: json['id'] as String? ?? '',
    number: json['number'] as String? ?? '',
    status: json['status'] as String? ?? '',
    currency: json['currency'] as String? ?? 'usd',
    subtotal: (json['subtotal'] as num?)?.toInt() ?? 0,
    tax: (json['tax'] as num?)?.toInt() ?? 0,
    total: (json['total'] as num?)?.toInt() ?? 0,
    createdAt:
        _date(json['createdAt']) ?? DateTime.fromMillisecondsSinceEpoch(0),
    paidAt: _date(json['paidAt']),
    hostedUrl: json['hostedUrl'] as String?,
    pdfUrl: json['pdfUrl'] as String?,
  );
}

class Payment {
  const Payment({
    required this.id,
    required this.provider,
    required this.status,
    required this.amount,
    required this.currency,
    required this.createdAt,
    this.description,
  });

  final String id;
  final String provider;
  final String status;
  final int amount;
  final String currency;
  final DateTime createdAt;
  final String? description;

  factory Payment.fromJson(Json json) => Payment(
    id: json['id'] as String? ?? '',
    provider: json['provider'] as String? ?? '',
    status: json['status'] as String? ?? '',
    amount: (json['amount'] as num?)?.toInt() ?? 0,
    currency: json['currency'] as String? ?? 'usd',
    createdAt:
        _date(json['createdAt']) ?? DateTime.fromMillisecondsSinceEpoch(0),
    description: json['description'] as String?,
  );
}

class Purchase {
  const Purchase({
    required this.id,
    required this.kind,
    required this.status,
    required this.provider,
    required this.amount,
    required this.currency,
    required this.creditsGranted,
    required this.createdAt,
  });

  final String id;
  final String kind;
  final String status;
  final String provider;
  final int amount;
  final String currency;
  final int creditsGranted;
  final DateTime createdAt;

  factory Purchase.fromJson(Json json) => Purchase(
    id: json['id'] as String? ?? '',
    kind: json['kind'] as String? ?? '',
    status: json['status'] as String? ?? '',
    provider: json['provider'] as String? ?? '',
    amount: (json['amount'] as num?)?.toInt() ?? 0,
    currency: json['currency'] as String? ?? 'usd',
    creditsGranted: (json['creditsGranted'] as num?)?.toInt() ?? 0,
    createdAt:
        _date(json['createdAt']) ?? DateTime.fromMillisecondsSinceEpoch(0),
  );
}

/// The result of starting a checkout — a Stripe URL to open, a client secret for an
/// on-device confirmation step, or an activated (store) subscription.
class CheckoutResult {
  const CheckoutResult({
    required this.subscription,
    this.checkoutUrl,
    this.clientSecret,
  });

  final Subscription subscription;
  final String? checkoutUrl;
  final String? clientSecret;

  bool get needsRedirect => checkoutUrl != null && checkoutUrl!.isNotEmpty;

  /// A provider path that needs an on-device confirmation step mobile does not
  /// implement (docs/48 §3.22a, AF5-cs). Neither `checkoutUrl` nor `clientSecret`
  /// set means the subscription is already active — see [needsRedirect].
  bool get needsClientConfirmation =>
      clientSecret != null && clientSecret!.isNotEmpty;

  factory CheckoutResult.fromJson(Json json) => CheckoutResult(
    subscription: Subscription.fromJson(
      json['subscription'] as Json? ?? const <String, Object?>{},
    ),
    checkoutUrl: json['checkoutUrl'] as String?,
    clientSecret: json['clientSecret'] as String?,
  );
}

/// The result of restoring store purchases.
class RestoreResult {
  const RestoreResult({required this.restored, this.expiresAt});

  final int restored;
  final DateTime? expiresAt;

  factory RestoreResult.fromJson(Json json) => RestoreResult(
    restored: (json['restored'] as num?)?.toInt() ?? 0,
    expiresAt: _date(json['expiresAt']),
  );
}

DateTime? _date(Object? raw) =>
    raw is String && raw.isNotEmpty ? DateTime.tryParse(raw) : null;

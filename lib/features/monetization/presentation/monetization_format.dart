/// Presentation helpers (AF5) — money + label formatting for monetization UI. Amounts
/// are minor units (cents). Pure display helpers (no I/O), kept out of widgets.
library;

/// Re-export the label helpers so screens import formatting from one place.
export 'domain_labels.dart';

/// Format a minor-unit amount + currency for display (e.g. 1499,'usd' → "$14.99").
String formatMoney(int minor, String currency) {
  final double major = minor / 100;
  final String symbol = _currencySymbol(currency);
  return '$symbol${major.toStringAsFixed(2)}';
}

/// Compact token/credit counts (1234 → "1.2K").
String formatCount(int value) {
  if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
  if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}K';
  return '$value';
}

String _currencySymbol(String currency) => switch (currency.toLowerCase()) {
  'usd' => r'$',
  'eur' => '€',
  'gbp' => '£',
  'inr' => '₹',
  'pkr' => '₨',
  _ => '${currency.toUpperCase()} ',
};

/// A human date (yyyy-mm-dd) for periods/renewals.
String formatDate(DateTime date) =>
    '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

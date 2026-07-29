/// Presentation helpers (AF5) — money + label formatting for monetization UI. Amounts
/// are minor units (cents). Pure display helpers (no I/O), kept out of widgets.
library;

import 'dart:math' as math;

import 'package:intl/intl.dart';

/// Re-export the label helpers so screens import formatting from one place.
export 'domain_labels.dart';

/// Minor units in one major unit, for the currencies that are not hundredths.
///
/// Almost every currency is 2 decimal places, but not all: JPY and KRW have none, so ¥1499 is
/// ¥1499 and not ¥14.99 — dividing by a blanket 100 under-reports a yen price by two orders of
/// magnitude, and the result still looks like a plausible price. The three-decimal dinars are
/// here for completeness.
///
/// `intl` knows each currency's *display* digits, but not this conversion — that has to happen
/// before the number reaches it.
const Map<String, int> _minorUnits = <String, int>{
  'bif': 1,
  'clp': 1,
  'djf': 1,
  'gnf': 1,
  'isk': 1,
  'jpy': 1,
  'kmf': 1,
  'krw': 1,
  'pyg': 1,
  'rwf': 1,
  'ugx': 1,
  'vnd': 1,
  'vuv': 1,
  'xaf': 1,
  'xof': 1,
  'xpf': 1,
  'bhd': 1000,
  'iqd': 1000,
  'jod': 1000,
  'kwd': 1000,
  'lyd': 1000,
  'omr': 1000,
  'tnd': 1000,
};

/// Format a minor-unit amount + currency for display (e.g. 1499,'usd' → "$14.99").
///
/// Uses `intl`'s currency formatting rather than a hand-written symbol table. The table only knew
/// five currencies and fell back to a bare code for the rest, and it divided everything by 100 —
/// so a sixth currency rendered as `"PKR 14.99"` and a zero-decimal one was wrong by 100×.
///
/// **The decimal count comes from [_minorUnits], not from the locale.** `intl` follows CLDR, which
/// renders PKR with zero decimals by local convention — so 1499 paisa would display as "PKR 15", a
/// rounded figure that does not match the amount charged. Pinning the digits to the currency's real
/// minor unit keeps the displayed figure equal to what the server holds. (Same fix as web's
/// `monetization-format.ts`; found there first, in W4.)
String formatMoney(int minor, String currency) {
  final int per = _minorUnits[currency.toLowerCase()] ?? 100;
  final double major = minor / per;
  // 1 → 0 digits, 100 → 2, 1000 → 3.
  final int digits = (math.log(per) / math.ln10).round();
  // `simpleCurrency`, not `currency`: the latter uses `name` as the literal symbol, so USD renders as
  // "USD14.99". `simpleCurrency` resolves the code to its symbol ($, £, ¥) and falls back to the code
  // itself for anything it does not know — which is the old table's behaviour for unknown currencies,
  // now applied only where it is actually needed.
  return NumberFormat.simpleCurrency(
    locale: 'en',
    name: currency.toUpperCase(),
    decimalDigits: digits,
  ).format(major);
}

/// Compact token/credit counts (1234 → "1.2K").
String formatCount(int value) {
  if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
  if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}K';
  return '$value';
}

/// A human date (yyyy-mm-dd) for periods/renewals.
String formatDate(DateTime date) =>
    '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

/// Small, dependency-free formatters for analytics surfaces (docs/41 §30). Compact
/// counts (1.2K / 3.4M), human read-time, and percentages — used by the metric
/// cards, charts and semantic labels so numbers read consistently everywhere.
library;

/// A compact count: 999 → "999", 1_200 → "1.2K", 3_400_000 → "3.4M".
String compactNumber(num value) {
  final double v = value.toDouble();
  final double abs = v.abs();
  if (abs < 1000) return v.toInt().toString();
  if (abs < 1000000) return '${_trim(v / 1000)}K';
  if (abs < 1000000000) return '${_trim(v / 1000000)}M';
  return '${_trim(v / 1000000000)}B';
}

String _trim(double v) {
  final String s = v.toStringAsFixed(1);
  return s.endsWith('.0') ? s.substring(0, s.length - 2) : s;
}

/// Human read-time from seconds: "0m", "45m", "3h 20m", "2d 4h".
String readDuration(int seconds) {
  if (seconds <= 0) return '0m';
  final int days = seconds ~/ 86400;
  final int hours = (seconds % 86400) ~/ 3600;
  final int minutes = (seconds % 3600) ~/ 60;
  if (days > 0) return hours > 0 ? '${days}d ${hours}h' : '${days}d';
  if (hours > 0) return minutes > 0 ? '${hours}h ${minutes}m' : '${hours}h';
  return '${minutes}m';
}

/// A percentage from a 0.0–1.0 rate: 0.734 → "73%".
String percentLabel(double rate) => '${(rate.clamp(0, 1) * 100).round()}%';

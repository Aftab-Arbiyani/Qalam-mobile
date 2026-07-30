/// Human, compact time formatting for card meta + reading surfaces (docs/41 §35).
///
/// [relativeTime] is the short byline form ("3h", "2d"); [readableDate] is the
/// reader's publication date ("14 Jul 2026"). Latin (ASCII) digits are used in
/// chrome/meta regardless of content script (docs/41 §4.4). `now` is injectable so
/// tests are deterministic (docs/40 §38.4).
library;

import 'package:intl/intl.dart';

String relativeTime(DateTime time, {DateTime? now}) {
  final DateTime reference = (now ?? DateTime.now()).toUtc();
  final Duration diff = reference.difference(time.toUtc());
  if (diff.isNegative || diff.inSeconds < 45) return 'now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m';
  if (diff.inHours < 24) return '${diff.inHours}h';
  if (diff.inDays < 7) return '${diff.inDays}d';
  if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w';
  if (diff.inDays < 365) return '${(diff.inDays / 30).floor()}mo';
  return '${(diff.inDays / 365).floor()}y';
}

/// A readable absolute date for the reader's publication line ("14 Jul 2026").
String readableDate(DateTime date) =>
    DateFormat('d MMM yyyy').format(date.toLocal());

/// A readable absolute date + time ("14 Jul 2026, 3:30 PM") for schedule display.
String readableDateTime(DateTime date) =>
    DateFormat('d MMM yyyy, h:mm a').format(date.toLocal());

/// Reading-time label ("5 min read"); empty for a zero estimate.
String readingTimeLabel(int minutes) => minutes <= 0 ? '' : '$minutes min read';

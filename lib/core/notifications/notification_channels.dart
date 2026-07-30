/// Android notification channels (docs/40 §33, docs/41 §37) — the calm, quiet
/// channel set Qalam presents on. Channels are created once at initialization;
/// each on-device notification declares which channel it belongs to. iOS has no
/// channel concept, so these ids/names are Android-only but the catalogue is the
/// single source of truth both platforms map onto.
///
/// "Quiet numbers": notifications inform, they don't nag — default importance,
/// the OS default sound, gentle vibration; no alarm-style channels.
library;

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// The notification category a channel serves, mapped from a notification's
/// domain type by the local-notification service.
enum NotificationChannelKind {
  /// Social activity — follows, comments, likes, mentions, responses.
  social(
    id: 'qalam_social',
    name: 'Activity',
    description: 'Follows, comments, reactions, and mentions.',
  ),

  /// System announcements + account/moderation updates.
  system(
    id: 'qalam_system',
    name: 'Announcements',
    description: 'Service announcements and account updates.',
  ),

  /// Opt-in scheduled reminders (the Phase-2 writing/reading-reminder seam).
  reminders(
    id: 'qalam_reminders',
    name: 'Reminders',
    description: 'Gentle writing and reading reminders you opt into.',
  );

  const NotificationChannelKind({
    required this.id,
    required this.name,
    required this.description,
  });

  final String id;
  final String name;
  final String description;

  /// The Android channel spec — default importance (informing, not alarming),
  /// OS-default sound + gentle vibration (docs/41 §37 "no sounds beyond the OS
  /// default").
  AndroidNotificationChannel get androidChannel =>
      AndroidNotificationChannel(id, name, description: description);
}

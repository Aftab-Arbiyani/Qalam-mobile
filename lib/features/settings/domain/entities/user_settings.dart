/// The server-side preference bag (`GET/PATCH /settings`) — `user_settings` on the
/// backend. Only the fields this client actually uses are modelled.
///
/// Mobile had NO client for this endpoint before B5: theme and text size are on-device
/// preferences here, and the notification toggles live behind the separate
/// `/notification-preferences` route. B5 is the first setting that MUST be server-side,
/// because the server enforces it (`platfrom/docs/45` §4.10), so this is the minimum
/// client that reads and writes it.
library;

import '../../../../core/utils/typedefs.dart';

class UserSettings {
  const UserSettings({required this.aiEnabled});

  /// B5 — whether the writer has AI turned on for their own account.
  ///
  /// **Decodes to `true` when absent**, matching the column default and the server's
  /// own read path: a missing row, an older server, or a trimmed payload must never be
  /// read as "this writer opted out" — that would silently hide every AI affordance
  /// from someone who never asked for it. Off is only ever an explicit `false`.
  final bool aiEnabled;

  factory UserSettings.fromJson(Json json) =>
      UserSettings(aiEnabled: json['aiEnabled'] as bool? ?? true);

  UserSettings copyWith({bool? aiEnabled}) =>
      UserSettings(aiEnabled: aiEnabled ?? this.aiEnabled);
}

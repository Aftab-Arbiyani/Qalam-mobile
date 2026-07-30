/// Per-category in-app notification preferences (docs/40 §32, backend
/// `notification-preferences`). Seven boolean toggles — one per notification
/// category the backend groups types into. There is deliberately NO push / email
/// / in-app channel toggle and NO reading-reminder / quiet-hours field: the
/// backend is in-app-only (ADR §10) and exposes only these categories. When the
/// FCM push seam lands (Phase 2, §32.2), channel toggles are added here additively.
///
/// The category → notification-type grouping mirrors the backend `TYPE_PREFERENCE`
/// map: `follow` covers follow / follow-request / follow-accepted / collection-
/// follow; `reaction` covers like / clap / repost; `system` covers system /
/// featured; the rest map one-to-one.
library;

import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_preferences.freezed.dart';
part 'notification_preferences.g.dart';

@freezed
abstract class NotificationPreferences with _$NotificationPreferences {
  const NotificationPreferences._();

  const factory NotificationPreferences({
    @Default(true) bool follow,
    @Default(true) bool comment,
    @Default(true) bool reply,
    @Default(true) bool reaction,
    @Default(true) bool mention,
    @Default(true) bool response,
    @Default(true) bool system,
  }) = _NotificationPreferences;

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) =>
      _$NotificationPreferencesFromJson(json);
}

/// The seven preference categories, each with its wire key. A stable, ordered
/// catalogue the settings screen renders and the partial PATCH body is built from.
enum NotificationPreferenceCategory {
  follow('follow'),
  comment('comment'),
  reply('reply'),
  reaction('reaction'),
  mention('mention'),
  response('response'),
  system('system');

  const NotificationPreferenceCategory(this.wire);
  final String wire;

  /// Read this category's current value off a [NotificationPreferences].
  bool valueOf(NotificationPreferences prefs) => switch (this) {
    NotificationPreferenceCategory.follow => prefs.follow,
    NotificationPreferenceCategory.comment => prefs.comment,
    NotificationPreferenceCategory.reply => prefs.reply,
    NotificationPreferenceCategory.reaction => prefs.reaction,
    NotificationPreferenceCategory.mention => prefs.mention,
    NotificationPreferenceCategory.response => prefs.response,
    NotificationPreferenceCategory.system => prefs.system,
  };

  /// A copy of [prefs] with this category set to [value].
  NotificationPreferences apply(
    NotificationPreferences prefs,
    bool value,
  ) => switch (this) {
    NotificationPreferenceCategory.follow => prefs.copyWith(follow: value),
    NotificationPreferenceCategory.comment => prefs.copyWith(comment: value),
    NotificationPreferenceCategory.reply => prefs.copyWith(reply: value),
    NotificationPreferenceCategory.reaction => prefs.copyWith(reaction: value),
    NotificationPreferenceCategory.mention => prefs.copyWith(mention: value),
    NotificationPreferenceCategory.response => prefs.copyWith(response: value),
    NotificationPreferenceCategory.system => prefs.copyWith(system: value),
  };
}

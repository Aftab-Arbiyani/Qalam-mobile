// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_preferences.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NotificationPreferences _$NotificationPreferencesFromJson(
  Map<String, dynamic> json,
) => _NotificationPreferences(
  follow: json['follow'] as bool? ?? true,
  comment: json['comment'] as bool? ?? true,
  reply: json['reply'] as bool? ?? true,
  reaction: json['reaction'] as bool? ?? true,
  mention: json['mention'] as bool? ?? true,
  response: json['response'] as bool? ?? true,
  system: json['system'] as bool? ?? true,
);

Map<String, dynamic> _$NotificationPreferencesToJson(
  _NotificationPreferences instance,
) => <String, dynamic>{
  'follow': instance.follow,
  'comment': instance.comment,
  'reply': instance.reply,
  'reaction': instance.reaction,
  'mention': instance.mention,
  'response': instance.response,
  'system': instance.system,
};

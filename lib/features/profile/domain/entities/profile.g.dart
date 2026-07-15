// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Profile _$ProfileFromJson(Map<String, dynamic> json) => _Profile(
  id: json['id'] as String,
  username: json['username'] as String,
  penName: json['penName'] as String? ?? '',
  avatarKey: json['avatarKey'] as String?,
  coverKey: json['coverKey'] as String?,
  isPrivate: json['isPrivate'] as bool? ?? false,
  restricted: json['restricted'] as bool? ?? false,
  bio: json['bio'] as String?,
  websiteUrl: json['websiteUrl'] as String?,
  location: json['location'] as String?,
  socialLinks:
      (json['socialLinks'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as String),
      ) ??
      const <String, String>{},
  defaultLanguageId: json['defaultLanguageId'] as String?,
  genres:
      (json['genres'] as List<dynamic>?)
          ?.map((e) => GenreRef.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <GenreRef>[],
  counts: json['counts'] == null
      ? const ProfileCounts()
      : ProfileCounts.fromJson(json['counts'] as Map<String, dynamic>),
  viewerRelation: json['viewerRelation'] == null
      ? const ViewerRelation()
      : ViewerRelation.fromJson(json['viewerRelation'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ProfileToJson(_Profile instance) => <String, dynamic>{
  'id': instance.id,
  'username': instance.username,
  'penName': instance.penName,
  'avatarKey': instance.avatarKey,
  'coverKey': instance.coverKey,
  'isPrivate': instance.isPrivate,
  'restricted': instance.restricted,
  'bio': instance.bio,
  'websiteUrl': instance.websiteUrl,
  'location': instance.location,
  'socialLinks': instance.socialLinks,
  'defaultLanguageId': instance.defaultLanguageId,
  'genres': instance.genres.map((e) => e.toJson()).toList(),
  'counts': instance.counts.toJson(),
  'viewerRelation': instance.viewerRelation.toJson(),
};

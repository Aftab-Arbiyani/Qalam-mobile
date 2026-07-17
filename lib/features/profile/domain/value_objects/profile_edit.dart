/// The editable subset of a profile (docs/40 §19.2) — the typed inputs for a
/// `PATCH /me`. Every field is nullable: a `null` field is "leave unchanged", so
/// the same value object serves both the full edit form (all fields set) and a
/// single-field update such as the privacy toggle (only [isPrivate] set).
///
/// Pure domain data — the wire body is built by the data-layer mapper
/// `profilePatchBody` (which also encodes the frozen-`v1` quirk that a blank
/// `websiteUrl` must be omitted rather than sent, since the server validates it as
/// a URL). `genres` carries slugs; `defaultLanguageCode` a BCP-47 code.
library;

import 'package:flutter/foundation.dart';

@immutable
class ProfileEdit {
  const ProfileEdit({
    this.penName,
    this.bio,
    this.websiteUrl,
    this.location,
    this.socialLinks,
    this.isPrivate,
    this.defaultLanguageCode,
    this.genreSlugs,
  });

  /// A privacy-only edit (used by the privacy settings screen).
  const ProfileEdit.privacy(bool isPrivate)
    : penName = null,
      bio = null,
      websiteUrl = null,
      location = null,
      socialLinks = null,
      isPrivate = isPrivate,
      defaultLanguageCode = null,
      genreSlugs = null;

  /// Reconstruct from a queued-sync payload (docs/40 §23) — the inverse of
  /// [toJson]. Only keys present are set; absent keys stay `null` ("unchanged").
  factory ProfileEdit.fromJson(Map<String, dynamic> json) => ProfileEdit(
    penName: json['penName'] as String?,
    bio: json['bio'] as String?,
    websiteUrl: json['websiteUrl'] as String?,
    location: json['location'] as String?,
    socialLinks: (json['socialLinks'] as Map<dynamic, dynamic>?)
        ?.map((Object? k, Object? v) => MapEntry<String, String>('$k', '$v')),
    isPrivate: json['isPrivate'] as bool?,
    defaultLanguageCode: json['defaultLanguageCode'] as String?,
    genreSlugs: (json['genreSlugs'] as List<dynamic>?)
        ?.map((Object? e) => '$e')
        .toList(growable: false),
  );

  final String? penName;
  final String? bio;
  final String? websiteUrl;
  final String? location;
  final Map<String, String>? socialLinks;
  final bool? isPrivate;
  final String? defaultLanguageCode;
  final List<String>? genreSlugs;

  /// Serialize for the offline sync outbox — omit `null` fields so a merge of two
  /// queued edits (via the handler) accumulates set fields rather than clobbering.
  Map<String, dynamic> toJson() => <String, dynamic>{
    'penName': ?penName,
    'bio': ?bio,
    'websiteUrl': ?websiteUrl,
    'location': ?location,
    'socialLinks': ?socialLinks,
    'isPrivate': ?isPrivate,
    'defaultLanguageCode': ?defaultLanguageCode,
    'genreSlugs': ?genreSlugs,
  };
}

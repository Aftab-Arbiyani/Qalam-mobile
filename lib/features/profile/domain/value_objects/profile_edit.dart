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

  final String? penName;
  final String? bio;
  final String? websiteUrl;
  final String? location;
  final Map<String, String>? socialLinks;
  final bool? isPrivate;
  final String? defaultLanguageCode;
  final List<String>? genreSlugs;
}

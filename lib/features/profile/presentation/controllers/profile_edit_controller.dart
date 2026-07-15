/// The profile edit form (docs/40 §19.2, docs/41 §29). A freezed-state notifier
/// seeded from the loaded `/me` profile. Text/genre/language/privacy edits are
/// staged and saved together via `PATCH /me` ([save]); avatar/cover uploads happen
/// immediately on their own endpoints ([uploadAvatar]/[uploadCover]) and push an
/// optimistic profile back through [MyProfileController]. Validation is live
/// (on-change after first submit); server field errors map back onto fields.
///
/// The frozen `v1` returns the default language as an opaque UUID with no way to
/// resolve it to a picker option, so the language field seeds empty — picking a
/// language sets it; leaving it untouched omits it from the PATCH (unchanged).
library;

import 'package:flutter/foundation.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/utils/result.dart';
import '../../../../shared/api/api_envelope.dart';
import '../../../../shared/domain/entities/taxonomy.dart';
import '../../../../shared/domain/limits.dart';
import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/value_objects/profile_edit.dart';
import '../providers/profile_providers.dart';
import 'my_profile_controller.dart';

part 'profile_edit_controller.freezed.dart';
part 'profile_edit_controller.g.dart';

/// An immutable snapshot of the editable fields — compared against the seed to
/// detect unsaved changes (the "discard changes?" guard).
@immutable
class ProfileEditSnapshot {
  const ProfileEditSnapshot({
    required this.penName,
    required this.bio,
    required this.websiteUrl,
    required this.location,
    required this.isPrivate,
    required this.genreSlugs,
    required this.languageCode,
  });

  final String penName;
  final String bio;
  final String websiteUrl;
  final String location;
  final bool isPrivate;
  final List<String> genreSlugs;
  final String? languageCode;

  @override
  bool operator ==(Object other) =>
      other is ProfileEditSnapshot &&
      other.penName == penName &&
      other.bio == bio &&
      other.websiteUrl == websiteUrl &&
      other.location == location &&
      other.isPrivate == isPrivate &&
      other.languageCode == languageCode &&
      listEquals(other.genreSlugs, genreSlugs);

  @override
  int get hashCode => Object.hash(
    penName,
    bio,
    websiteUrl,
    location,
    isPrivate,
    languageCode,
    Object.hashAll(genreSlugs),
  );
}

@freezed
abstract class ProfileEditState with _$ProfileEditState {
  const factory ProfileEditState({
    @Default('') String penName,
    @Default('') String bio,
    @Default('') String websiteUrl,
    @Default('') String location,
    @Default(<GenreRef>[]) List<GenreRef> genres,
    LanguageRef? defaultLanguage,
    @Default(false) bool isPrivate,
    String? penNameError,
    String? websiteError,
    @Default(false) bool submitting,
    @Default(false) bool saved,
    double? avatarProgress,
    double? coverProgress,
    Failure? formError,
    ProfileEditSnapshot? seed,
  }) = _ProfileEditState;

  const ProfileEditState._();

  /// True while an avatar or cover upload is in flight.
  bool get uploading => avatarProgress != null || coverProgress != null;

  ProfileEditSnapshot get _current => ProfileEditSnapshot(
    penName: penName.trim(),
    bio: bio.trim(),
    websiteUrl: websiteUrl.trim(),
    location: location.trim(),
    isPrivate: isPrivate,
    genreSlugs: <String>[for (final GenreRef g in genres) g.slug],
    languageCode: defaultLanguage?.code,
  );

  /// Whether the staged fields differ from the seeded profile.
  bool get dirty => seed != null && _current != seed;
}

@riverpod
class ProfileEditController extends _$ProfileEditController {
  @override
  ProfileEditState build() {
    // Cancel any in-flight uploads if the edit screen is left.
    final ProfileRepository repo = ref.watch(profileRepositoryProvider);
    ref.onDispose(() {
      repo
        ..cancelUpload(_avatarKey)
        ..cancelUpload(_coverKey);
    });
    final Profile? profile = ref
        .read(myProfileControllerProvider)
        .asData
        ?.value;
    return profile == null ? const ProfileEditState() : _seededFrom(profile);
  }

  static const String _avatarKey = 'profile-avatar';
  static const String _coverKey = 'profile-cover';

  ProfileEditState _seededFrom(Profile p) {
    final ProfileEditState seeded = ProfileEditState(
      penName: p.penName,
      bio: p.bio ?? '',
      websiteUrl: p.websiteUrl ?? '',
      location: p.location ?? '',
      genres: p.genres,
      isPrivate: p.isPrivate,
    );
    return seeded.copyWith(seed: seeded._current);
  }

  // ── Field edits (live validation after first submit surfaces an error) ────────

  void changePenName(String value) => state = state.copyWith(
    penName: value,
    penNameError: state.penNameError == null ? null : _validatePenName(value),
    formError: null,
    saved: false,
  );

  void changeBio(String value) =>
      state = state.copyWith(bio: value, formError: null, saved: false);

  void changeLocation(String value) =>
      state = state.copyWith(location: value, formError: null, saved: false);

  void changeWebsite(String value) => state = state.copyWith(
    websiteUrl: value,
    websiteError: state.websiteError == null ? null : _validateWebsite(value),
    formError: null,
    saved: false,
  );

  void toggleGenre(GenreRef genre) {
    final List<GenreRef> next = <GenreRef>[...state.genres];
    final int index = next.indexWhere((GenreRef g) => g.slug == genre.slug);
    if (index >= 0) {
      next.removeAt(index);
    } else {
      if (next.length >= Limits.maxGenresPerProfile) return;
      next.add(genre);
    }
    state = state.copyWith(genres: next, saved: false);
  }

  void setLanguage(LanguageRef language) =>
      state = state.copyWith(defaultLanguage: language, saved: false);

  void setPrivate(bool value) =>
      state = state.copyWith(isPrivate: value, saved: false);

  // ── Uploads (immediate; optimistic push to the live profile on success) ───────

  Future<void> uploadAvatar(String filePath) =>
      _upload(filePath, isAvatar: true);

  Future<void> uploadCover(String filePath) =>
      _upload(filePath, isAvatar: false);

  Future<void> _upload(String filePath, {required bool isAvatar}) async {
    if (state.uploading) return;
    state = isAvatar
        ? state.copyWith(avatarProgress: 0, formError: null)
        : state.copyWith(coverProgress: 0, formError: null);
    final ProfileRepository repo = ref.read(profileRepositoryProvider);
    void onProgress(double p) => state = isAvatar
        ? state.copyWith(avatarProgress: p)
        : state.copyWith(coverProgress: p);
    final Result<String> result = isAvatar
        ? await repo.uploadAvatar(
            filePath: filePath,
            uploadKey: _avatarKey,
            onProgress: onProgress,
          )
        : await repo.uploadCover(
            filePath: filePath,
            uploadKey: _coverKey,
            onProgress: onProgress,
          );
    state = isAvatar
        ? state.copyWith(avatarProgress: null)
        : state.copyWith(coverProgress: null);
    switch (result) {
      case Ok(:final String value):
        final Profile? current = ref
            .read(myProfileControllerProvider)
            .asData
            ?.value;
        if (current != null) {
          ref
              .read(myProfileControllerProvider.notifier)
              .applyProfile(
                isAvatar
                    ? current.copyWith(avatarKey: value)
                    : current.copyWith(coverKey: value),
              );
        }
      case Err(:final Failure failure):
        state = state.copyWith(formError: failure);
    }
  }

  // ── Save (PATCH /me) ──────────────────────────────────────────────────────────

  Future<void> save() async {
    if (state.submitting) return;
    final String? penErr = _validatePenName(state.penName);
    final String? webErr = _validateWebsite(state.websiteUrl);
    if (penErr != null || webErr != null) {
      state = state.copyWith(penNameError: penErr, websiteError: webErr);
      return;
    }
    state = state.copyWith(submitting: true, formError: null, saved: false);
    final ProfileEdit edit = ProfileEdit(
      penName: state.penName,
      bio: state.bio,
      location: state.location,
      websiteUrl: state.websiteUrl,
      isPrivate: state.isPrivate,
      defaultLanguageCode: state.defaultLanguage?.code,
      genreSlugs: <String>[for (final GenreRef g in state.genres) g.slug],
    );
    final Result<Profile> result = await ref
        .read(profileRepositoryProvider)
        .updateProfile(edit);
    switch (result) {
      case Ok(:final Profile value):
        ref.read(myProfileControllerProvider.notifier).applyProfile(value);
        state = state.copyWith(
          submitting: false,
          saved: true,
          penName: value.penName,
          genres: value.genres,
          isPrivate: value.isPrivate,
          seed: state.copyWith(penName: value.penName)._current,
        );
      case Err(:final Failure failure):
        _applyFailure(failure);
    }
  }

  void _applyFailure(Failure failure) {
    String? penErr;
    String? webErr;
    if (failure is ValidationFailure) {
      for (final FieldError fe in failure.fieldErrors) {
        if (fe.field.endsWith('penName')) penErr = fe.message;
        if (fe.field.endsWith('websiteUrl')) webErr = fe.message;
      }
    }
    state = state.copyWith(
      submitting: false,
      penNameError: penErr ?? state.penNameError,
      websiteError: webErr ?? state.websiteError,
      formError: (penErr == null && webErr == null) ? failure : null,
    );
  }

  String? _validatePenName(String value) {
    final String trimmed = value.trim();
    if (trimmed.isEmpty) return 'Display name is required.';
    if (trimmed.length > Limits.penNameMax) {
      return 'Keep it under ${Limits.penNameMax} characters.';
    }
    return null;
  }

  String? _validateWebsite(String value) {
    final String trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    final Uri? uri = Uri.tryParse(trimmed);
    if (uri == null ||
        !uri.hasScheme ||
        !(uri.isScheme('http') || uri.isScheme('https')) ||
        !uri.hasAuthority) {
      return 'Enter a full URL (https://…).';
    }
    if (trimmed.length > Limits.websiteUrlMax) {
      return 'That URL is too long.';
    }
    return null;
  }
}

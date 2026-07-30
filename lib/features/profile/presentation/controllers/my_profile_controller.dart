/// The signed-in user's own profile (docs/40 §19). An `AsyncValue<Profile>` over
/// `GET /me` (cache-then-network in the repository, so it resolves offline from the
/// cached copy). Page-1 load/error is the `AsyncValue` → skeleton / error view.
/// [applyProfile] lets edit + upload flows push an optimistic/fresh profile without
/// a refetch; [refresh] backs pull-to-refresh.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/value_objects/profile_edit.dart';
import '../providers/profile_providers.dart';

part 'my_profile_controller.g.dart';

@riverpod
class MyProfileController extends _$MyProfileController {
  @override
  Future<Profile> build() => _load();

  Future<Profile> _load() async {
    final Result<CachedProfile> result = await ref
        .read(profileRepositoryProvider)
        .myProfile();
    return result.fold(
      (CachedProfile cached) => cached.profile,
      (Failure failure) => throw failure,
    );
  }

  /// Pull-to-refresh — re-fetch and replace, keeping old content painted.
  Future<void> refresh() async {
    state = await AsyncValue.guard(_load);
  }

  /// Replace the profile in place (optimistic edit / post-upload / post-save).
  void applyProfile(Profile profile) => state = AsyncData<Profile>(profile);

  /// Toggle the private-account flag via `PATCH /me`, optimistically. Reverts and
  /// returns the [Failure] on error (null on success) so the screen can surface it.
  Future<Failure?> setPrivate(bool value) async {
    final Profile? current = state.asData?.value;
    if (current == null || current.isPrivate == value) return null;
    state = AsyncData<Profile>(current.copyWith(isPrivate: value));
    final Result<Profile> result = await ref
        .read(profileRepositoryProvider)
        .updateProfile(ProfileEdit.privacy(value));
    return result.fold(
      (Profile updated) {
        state = AsyncData<Profile>(updated);
        return null;
      },
      (Failure failure) {
        state = AsyncData<Profile>(current);
        return failure;
      },
    );
  }
}

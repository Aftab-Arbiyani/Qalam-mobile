/// A public profile by username (docs/40 §19), keyed by a family arg. An
/// `AsyncValue<Profile>` over `GET /users/:username` (cache-then-network, resolves
/// offline). A private account viewed by a stranger comes back with
/// `restricted == true` and detail fields omitted — the screen renders a teaser.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../providers/profile_providers.dart';

part 'public_profile_controller.g.dart';

@riverpod
class PublicProfileController extends _$PublicProfileController {
  @override
  Future<Profile> build(String username) => _load(username);

  Future<Profile> _load(String username) async {
    final Result<CachedProfile> result = await ref
        .read(profileRepositoryProvider)
        .publicProfile(username);
    return result.fold(
      (CachedProfile cached) => cached.profile,
      (Failure failure) => throw failure,
    );
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(() => _load(username));
  }
}

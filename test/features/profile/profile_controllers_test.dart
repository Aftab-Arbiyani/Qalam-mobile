import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/core/error/failure.dart';
import 'package:qalam_mobile/features/profile/domain/entities/profile.dart';
import 'package:qalam_mobile/features/profile/domain/entities/profile_piece.dart';
import 'package:qalam_mobile/features/profile/presentation/controllers/my_pieces_controller.dart';
import 'package:qalam_mobile/features/profile/presentation/controllers/my_profile_controller.dart';
import 'package:qalam_mobile/features/profile/presentation/controllers/profile_edit_controller.dart';
import 'package:qalam_mobile/features/profile/presentation/controllers/profile_stats_controller.dart';
import 'package:qalam_mobile/features/profile/presentation/controllers/public_profile_controller.dart';
import 'package:qalam_mobile/shared/api/api_envelope.dart';

import '../../support/fake_profile_repository.dart';
import '../../support/harness.dart';

Future<ProviderContainer> _container(FakeProfileRepository repo) async {
  final ProviderContainer c = await buildTestContainer(profileRepository: repo);
  addTearDown(c.dispose);
  return c;
}

void main() {
  group('MyProfileController', () {
    test('loads the profile from the repository', () async {
      final ProviderContainer c = await _container(FakeProfileRepository());
      final Profile profile = await c.read(myProfileControllerProvider.future);
      expect(profile.username, 'meera_k');
    });

    test('surfaces a repository failure as AsyncError', () async {
      final ProviderContainer c = await _container(
        FakeProfileRepository(
          failure: const Failure.network(code: 'API_OFFLINE', isOffline: true),
        ),
      );
      final ProviderSubscription<AsyncValue<Profile>> sub = c.listen(
        myProfileControllerProvider,
        (_, _) {},
      );
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(sub.read().hasError, isTrue);
      expect(sub.read().error, isA<Failure>());
    });

    test('setPrivate updates optimistically and persists', () async {
      final FakeProfileRepository repo = FakeProfileRepository();
      final ProviderContainer c = await _container(repo);
      await c.read(myProfileControllerProvider.future);

      final Failure? error = await c
          .read(myProfileControllerProvider.notifier)
          .setPrivate(true);
      expect(error, isNull);
      expect(repo.updateCalls, 1);
      expect(
        c.read(myProfileControllerProvider).asData?.value.isPrivate,
        isTrue,
      );
    });

    test('setPrivate reverts on failure and returns the Failure', () async {
      final FakeProfileRepository repo = FakeProfileRepository();
      final ProviderContainer c = await _container(repo);
      await c.read(myProfileControllerProvider.future);

      repo.failure = const Failure.network(code: 'API_OFFLINE');
      final Failure? error = await c
          .read(myProfileControllerProvider.notifier)
          .setPrivate(true);
      expect(error, isA<NetworkFailure>());
      expect(
        c.read(myProfileControllerProvider).asData?.value.isPrivate,
        isFalse,
      );
    });
  });

  group('PublicProfileController', () {
    test('loads a profile by username', () async {
      final ProviderContainer c = await _container(FakeProfileRepository());
      final Profile p = await c.read(
        publicProfileControllerProvider('meera_k').future,
      );
      expect(p.handle, '@meera_k');
    });
  });

  group('ProfileStatsController', () {
    test('exposes bounded draft/bookmark counts', () async {
      final ProviderContainer c = await _container(
        FakeProfileRepository(
          draftCount: (count: 50, hasMore: true),
          bookmarkCount: (count: 4, hasMore: false),
        ),
      );
      final ProfileStats stats = await c.read(
        profileStatsControllerProvider.future,
      );
      expect(stats.drafts?.count, 50);
      expect(stats.drafts?.hasMore, isTrue);
      expect(stats.bookmarks?.count, 4);
    });
  });

  group('MyPiecesController', () {
    test('loads the first page of published pieces', () async {
      final ProviderContainer c = await _container(
        FakeProfileRepository(
          publishedPieces: <ProfilePiece>[
            const ProfilePiece(id: 'p1', title: 'A'),
            const ProfilePiece(id: 'p2', title: 'B'),
          ],
        ),
      );
      final state = await c.read(myPiecesControllerProvider.future);
      expect(state.items.length, 2);
      expect(state.isEmpty, isFalse);
    });
  });

  group('ProfileEditController', () {
    test('seeds from the loaded profile', () async {
      final ProviderContainer c = await _container(FakeProfileRepository());
      await c.read(myProfileControllerProvider.future);
      final ProfileEditState state = c.read(profileEditControllerProvider);
      expect(state.penName, 'Meera K.');
      expect(state.dirty, isFalse);
    });

    test('editing a field marks the form dirty', () async {
      final ProviderContainer c = await _container(FakeProfileRepository());
      await c.read(myProfileControllerProvider.future);
      c.read(profileEditControllerProvider.notifier).changePenName('New name');
      expect(c.read(profileEditControllerProvider).dirty, isTrue);
    });

    test('empty display name blocks save with a field error', () async {
      final FakeProfileRepository repo = FakeProfileRepository();
      final ProviderContainer c = await _container(repo);
      await c.read(myProfileControllerProvider.future);
      final ProfileEditController ctrl = c.read(
        profileEditControllerProvider.notifier,
      );
      ctrl.changePenName('   ');
      await ctrl.save();
      expect(c.read(profileEditControllerProvider).penNameError, isNotNull);
      expect(repo.updateCalls, 0);
    });

    test('invalid website blocks save', () async {
      final FakeProfileRepository repo = FakeProfileRepository();
      final ProviderContainer c = await _container(repo);
      await c.read(myProfileControllerProvider.future);
      final ProfileEditController ctrl = c.read(
        profileEditControllerProvider.notifier,
      );
      ctrl.changeWebsite('not-a-url');
      await ctrl.save();
      expect(c.read(profileEditControllerProvider).websiteError, isNotNull);
      expect(repo.updateCalls, 0);
    });

    test('valid save patches the profile and flips saved', () async {
      final FakeProfileRepository repo = FakeProfileRepository();
      final ProviderContainer c = await _container(repo);
      await c.read(myProfileControllerProvider.future);
      final ProfileEditController ctrl = c.read(
        profileEditControllerProvider.notifier,
      );
      ctrl.changePenName('Meera Kaur');
      await ctrl.save();
      expect(repo.updateCalls, 1);
      expect(repo.lastEdit?.penName, 'Meera Kaur');
      expect(c.read(profileEditControllerProvider).saved, isTrue);
      expect(
        c.read(myProfileControllerProvider).asData?.value.penName,
        'Meera Kaur',
      );
    });

    test('server validation failure maps onto the field', () async {
      final FakeProfileRepository repo = FakeProfileRepository();
      final ProviderContainer c = await _container(repo);
      await c.read(myProfileControllerProvider.future);
      c.listen(profileEditControllerProvider, (_, _) {});
      // The seed load succeeded; now make the PATCH fail with a field error.
      repo.failure = const Failure.validation(
        code: 'VALIDATION_FAILED',
        fieldErrors: <FieldError>[
          FieldError(field: 'penName', message: 'Too edgy'),
        ],
      );
      final ProfileEditController ctrl = c.read(
        profileEditControllerProvider.notifier,
      );
      ctrl.changePenName('Valid');
      await ctrl.save();
      expect(c.read(profileEditControllerProvider).penNameError, 'Too edgy');
    });

    test('uploadAvatar pushes the new key onto the live profile', () async {
      final FakeProfileRepository repo = FakeProfileRepository();
      final ProviderContainer c = await _container(repo);
      await c.read(myProfileControllerProvider.future);
      // Keep the edit controller alive so its state mutations stick.
      c.listen(profileEditControllerProvider, (_, _) {});
      await c
          .read(profileEditControllerProvider.notifier)
          .uploadAvatar('/tmp/a.png');
      expect(repo.avatarUploads, 1);
      expect(
        c.read(myProfileControllerProvider).asData?.value.avatarKey,
        'profiles/avatar.webp',
      );
    });
  });
}

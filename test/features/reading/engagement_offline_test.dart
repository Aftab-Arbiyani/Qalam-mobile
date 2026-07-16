import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/features/reading/domain/entities/piece_engagement.dart';
import 'package:qalam_mobile/features/reading/presentation/controllers/engagement_controller.dart';
import 'package:qalam_mobile/shared/social/social_providers.dart';

import '../../support/fake_reading_repository.dart';
import '../../support/harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('offline like is applied optimistically and queued (no rollback)', () async {
    final ProviderContainer c = await buildTestContainer(
      online: false,
      readingRepository: FakeReadingRepository(
        engagement: const PieceEngagement(likes: 5),
      ),
      engagementRepository: FakeEngagementRepository(),
    );
    addTearDown(c.dispose);
    c.listen(socialSyncEngineProvider, (_, _) {});
    c.listen(engagementControllerProvider('p1'), (_, _) {});

    await c.read(engagementControllerProvider('p1').future);
    await c.read(engagementControllerProvider('p1').notifier).toggleLike();

    // Optimistic UI applied.
    final PieceEngagement e =
        c.read(engagementControllerProvider('p1')).asData!.value;
    expect(e.hasLiked, isTrue);
    expect(e.likes, 6);

    // Queued for reconnect (not rolled back).
    expect(c.read(socialOutboxStoreProvider).count, 1);
    expect(c.read(socialOutboxStoreProvider).readAll().single.targetId, 'p1');
  });

  test('offline bookmark is applied optimistically and queued', () async {
    final ProviderContainer c = await buildTestContainer(
      online: false,
      readingRepository: FakeReadingRepository(
        engagement: const PieceEngagement(bookmarks: 2),
      ),
      engagementRepository: FakeEngagementRepository(),
    );
    addTearDown(c.dispose);
    c.listen(socialSyncEngineProvider, (_, _) {});
    c.listen(engagementControllerProvider('p1'), (_, _) {});

    await c.read(engagementControllerProvider('p1').future);
    await c.read(engagementControllerProvider('p1').notifier).toggleBookmark();

    final PieceEngagement e =
        c.read(engagementControllerProvider('p1')).asData!.value;
    expect(e.hasBookmarked, isTrue);
    expect(c.read(socialOutboxStoreProvider).count, 1);
  });
}

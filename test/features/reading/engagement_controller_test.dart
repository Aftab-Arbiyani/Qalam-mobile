import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/features/reading/domain/entities/piece_engagement.dart';
import 'package:qalam_mobile/features/reading/presentation/controllers/engagement_controller.dart';
import 'package:qalam_mobile/shared/domain/enums.dart';

import '../../support/fake_reading_repository.dart';
import '../../support/harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<(ProviderContainer, FakeEngagementRepository)> setup(
    PieceEngagement initial,
  ) async {
    final FakeEngagementRepository eng =
        FakeEngagementRepository(); // likeTotal defaults to 11
    final ProviderContainer c = await buildTestContainer(
      readingRepository: FakeReadingRepository(engagement: initial),
      engagementRepository: eng,
    );
    addTearDown(c.dispose);
    await c.read(engagementControllerProvider('p1').future);
    return (c, eng);
  }

  PieceEngagement current(ProviderContainer c) =>
      c.read(engagementControllerProvider('p1')).asData!.value;

  test('like is optimistic then reconciles to the server total', () async {
    final (ProviderContainer c, FakeEngagementRepository _) = await setup(
      const PieceEngagement(likes: 5),
    );
    await c.read(engagementControllerProvider('p1').notifier).toggleLike();
    expect(current(c).hasLiked, isTrue);
    expect(current(c).likes, 11); // server total
  });

  test('unlike decrements optimistically', () async {
    final (ProviderContainer c, FakeEngagementRepository _) = await setup(
      const PieceEngagement(likes: 5, hasLiked: true),
    );
    await c.read(engagementControllerProvider('p1').notifier).toggleLike();
    expect(current(c).hasLiked, isFalse);
    expect(current(c).likes, 4);
  });

  test('like failure rolls back', () async {
    final (ProviderContainer c, FakeEngagementRepository eng) = await setup(
      const PieceEngagement(likes: 5),
    );
    eng.nextFails = true;
    await c.read(engagementControllerProvider('p1').notifier).toggleLike();
    expect(current(c).hasLiked, isFalse);
    expect(current(c).likes, 5);
  });

  test('bookmark is optimistic; failure rolls back', () async {
    final (ProviderContainer c, FakeEngagementRepository eng) = await setup(
      const PieceEngagement(bookmarks: 2),
    );
    await c.read(engagementControllerProvider('p1').notifier).toggleBookmark();
    expect(current(c).hasBookmarked, isTrue);
    expect(current(c).bookmarks, 3);

    eng.nextFails = true;
    await c.read(engagementControllerProvider('p1').notifier).toggleBookmark();
    expect(current(c).hasBookmarked, isTrue); // rolled back to marked
    expect(current(c).bookmarks, 3);
  });

  test('share records the server total', () async {
    final (ProviderContainer c, FakeEngagementRepository _) = await setup(
      const PieceEngagement(shares: 1),
    );
    await c
        .read(engagementControllerProvider('p1').notifier)
        .recordShare(ShareChannel.copyLink);
    expect(current(c).shares, 3);
  });
}

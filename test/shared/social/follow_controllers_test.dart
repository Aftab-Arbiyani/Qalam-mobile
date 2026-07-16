import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/shared/pagination/paged_list_state.dart';
import 'package:qalam_mobile/shared/social/domain/entities/follow_user.dart';
import 'package:qalam_mobile/shared/social/presentation/controllers/follow_controllers.dart';

import '../../support/fake_social.dart';
import '../../support/harness.dart';

FollowUser _u(String id) => FollowUser(id: id, username: 'u$id');
FollowRequest _req(String id) =>
    FollowRequest(id: id, requester: FollowUser(id: 'r$id', username: 'r$id'));

void main() {
  test('followers list loads the seeded page', () async {
    final ProviderContainer c = await buildTestContainer(
      followRepository: FakeFollowRepository(
        followerUsers: <FollowUser>[_u('1'), _u('2')],
      ),
    );
    addTearDown(c.dispose);
    final PagedListState<FollowUser> page = await c.read(
      followersControllerProvider('meera').future,
    );
    expect(page.items.length, 2);
  });

  test('accepting a request removes it optimistically', () async {
    final ProviderContainer c = await buildTestContainer(
      followRepository: FakeFollowRepository(
        pendingRequests: <FollowRequest>[_req('1'), _req('2')],
      ),
    );
    addTearDown(c.dispose);
    await c.read(followRequestsControllerProvider.future);
    await c.read(followRequestsControllerProvider.notifier).accept('1');
    final PagedListState<FollowRequest> after =
        c.read(followRequestsControllerProvider).asData!.value;
    expect(after.items.map((FollowRequest r) => r.id), <String>['2']);
  });

  test('a failed reject restores the request', () async {
    final FakeFollowRepository repo = FakeFollowRepository(
      pendingRequests: <FollowRequest>[_req('1'), _req('2')],
    );
    final ProviderContainer c = await buildTestContainer(followRepository: repo);
    addTearDown(c.dispose);
    await c.read(followRequestsControllerProvider.future);
    repo.failNext = true;
    await c.read(followRequestsControllerProvider.notifier).reject('1');
    final PagedListState<FollowRequest> after =
        c.read(followRequestsControllerProvider).asData!.value;
    expect(after.items.length, 2); // rolled back
  });
}

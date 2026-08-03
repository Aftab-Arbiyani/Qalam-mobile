/// Regression guard for defect **M-4** (`platfrom/docs/48` §3.3).
///
/// Mobile's trust layer has been complete since AF6 — `TrustRemoteDataSource`,
/// `TrustRepository`, `BlockEntry`, `myBlocksProvider` — and **nothing rendered any of
/// it**. There was no blocks/mutes surface on mobile at all, so a reader could not see
/// who they had blocked, let alone undo it.
///
/// The tests cover the three things that make it actually shipped rather than merely
/// written:
///
/// 1. **The wire shape** — removal passes `blockedId` (the USER), never `id` (the block
///    relationship). Passing `id` is defect **T-1**: the route reaches the service with
///    the wrong UUID and 404s `BLOCK_NOT_FOUND`, so unblocking silently never works.
/// 2. **The screen renders both kinds** and offers the matching action.
/// 3. **Reachability** — a settings tile pushes `/settings/blocks` AND the app's own
///    router serves that path. This is the assertion mobile's tests have repeatedly
///    missed: R-1 registered six AF6 routes that nothing navigated to, and M5-1 shipped
///    a widget with no call site.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:qalam_mobile/app/router/app_router.dart';
import 'package:qalam_mobile/app/router/routes.dart';
import 'package:qalam_mobile/core/config/app_config.dart';
import 'package:qalam_mobile/core/config/app_flavor.dart';
import 'package:qalam_mobile/core/di/providers.dart';
import 'package:qalam_mobile/core/network/api_client.dart';
import 'package:qalam_mobile/features/collaboration/data/datasources/trust_remote_data_source.dart';
import 'package:qalam_mobile/features/collaboration/domain/entities/block_entry.dart';
import 'package:qalam_mobile/features/collaboration/domain/entities/collaboration_enums.dart';
import 'package:qalam_mobile/features/collaboration/domain/entities/trust_summary.dart';
import 'package:qalam_mobile/features/collaboration/presentation/providers/collaboration_providers.dart';
import 'package:qalam_mobile/features/collaboration/presentation/screens/blocks_screen.dart';
import 'package:qalam_mobile/features/settings/presentation/screens/settings_hub_screen.dart';
import 'package:qalam_mobile/shared/theme/app_theme.dart';

import '../../support/harness.dart';

class _MockApiClient extends Mock implements ApiClient {}

const AppConfig _collaborationOn = AppConfig(
  flavor: AppFlavor.development,
  apiUrl: 'http://localhost:4000',
  cdnUrl: '',
  webUrl: '',
  sentryDsn: '',
  enablePush: false,
  enableAi: false,
  enableMonetization: false,
  enableCollaboration: true,
);

/// The two ids are deliberately different — the whole point of T-1 is that both are
/// UUIDs, so the wrong one reaches the service and fails at the database, not the type
/// system.
final BlockEntry _block = BlockEntry(
  id: 'relationship-1111',
  blockerId: 'me-0000',
  blockedId: 'user-2222',
  kind: 'block',
  createdAt: DateTime.utc(2026, 7, 10),
);

final BlockEntry _mute = BlockEntry(
  id: 'relationship-3333',
  blockerId: 'me-0000',
  blockedId: 'user-4444',
  kind: 'mute',
  createdAt: DateTime.utc(2026, 7, 2),
);

Future<void> _pumpBlocks(
  WidgetTester tester, {
  required List<BlockEntry> blocks,
  TrustSummary trust = TrustSummary.healthy,
  AppConfig config = _collaborationOn,
}) async {
  tester.view.physicalSize = const Size(600, 2000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appConfigProvider.overrideWithValue(config),
        myBlocksProvider.overrideWith((_) async => blocks),
        trustSummaryProvider.overrideWith((_) async => trust),
      ],
      child: MaterialApp(
        theme: buildQalamTheme(brightness: Brightness.light),
        home: const BlocksScreen(),
      ),
    ),
  );
  await tester.pump();
  await tester.pump();
}

void main() {
  group('removal targets the user, not the relationship (M-4 / T-1)', () {
    late _MockApiClient api;
    late TrustRemoteDataSource remote;

    setUp(() {
      api = _MockApiClient();
      remote = TrustRemoteDataSource(api);
      when(() => api.delete(any())).thenAnswer((_) async {});
    });

    test('unblock deletes /users/{blockedId}/block', () async {
      await remote.unblock(_block.blockedId);
      verify(() => api.delete('/users/user-2222/block')).called(1);
      // The row id must never appear in the path.
      verifyNever(() => api.delete('/users/relationship-1111/block'));
    });

    test('unmute deletes /users/{blockedId}/mute', () async {
      await remote.unmute(_mute.blockedId);
      verify(() => api.delete('/users/user-4444/mute')).called(1);
    });

    test('BlockEntry keeps the two ids apart on the way in', () {
      final BlockEntry parsed = BlockEntry.fromJson(<String, dynamic>{
        'id': 'relationship-1111',
        'blockerId': 'me-0000',
        'blockedId': 'user-2222',
        'kind': 'mute',
        'createdAt': '2026-07-01T00:00:00.000Z',
      });
      expect(parsed.blockedId, 'user-2222');
      expect(parsed.id, isNot(parsed.blockedId));
      expect(parsed.isMute, isTrue);
    });
  });

  group('the screen renders the list (M-4)', () {
    testWidgets('shows both kinds with the matching action', (
      WidgetTester tester,
    ) async {
      await _pumpBlocks(tester, blocks: <BlockEntry>[_block, _mute]);

      // One endpoint returns both, distinguished by `kind`; they are different
      // promises, so each row says which it is.
      expect(find.text('Unblock'), findsOneWidget);
      expect(find.text('Unmute'), findsOneWidget);
      expect(find.textContaining('Blocked · '), findsOneWidget);
      expect(find.textContaining('Muted · '), findsOneWidget);
    });

    testWidgets('an empty list says where blocking starts', (
      WidgetTester tester,
    ) async {
      await _pumpBlocks(tester, blocks: <BlockEntry>[]);
      expect(
        find.textContaining('haven’t blocked or muted anyone'),
        findsOneWidget,
      );
    });

    testWidgets('good standing reads as reassurance, not a warning', (
      WidgetTester tester,
    ) async {
      await _pumpBlocks(tester, blocks: <BlockEntry>[]);
      expect(find.text('Good standing'), findsOneWidget);
      expect(find.textContaining('full access'), findsOneWidget);
    });

    testWidgets('a restriction is named with its scope', (
      WidgetTester tester,
    ) async {
      await _pumpBlocks(
        tester,
        blocks: <BlockEntry>[],
        trust: const TrustSummary(
          score: 40,
          level: 'limited',
          status: TrustStatus.limited,
          activeStrikeWeight: 2,
          restrictions: <UserRestriction>[
            UserRestriction(
              id: 'r1',
              type: RestrictionType.muted,
              scope: RestrictionScope.comments,
              reason: 'Repeated reports',
            ),
          ],
        ),
      );
      // The scope is what says *what* is restricted — without it "Muted" is ambiguous.
      expect(find.textContaining('Comments'), findsOneWidget);
      expect(find.textContaining('Repeated reports'), findsOneWidget);
    });

    testWidgets('a dark build says so instead of showing an empty list', (
      WidgetTester tester,
    ) async {
      await _pumpBlocks(
        tester,
        blocks: <BlockEntry>[_block],
        config: testConfig,
      );
      expect(find.text('Blocking isn’t available yet'), findsOneWidget);
      expect(find.text('Unblock'), findsNothing);
    });
  });

  group('the screen is reachable (M-4)', () {
    testWidgets('the settings hub pushes /settings/blocks', (
      WidgetTester tester,
    ) async {
      // Half of the chain: the hub navigates to exactly the route constant. Paired with
      // the router assertion below, that closes the loop the R-1 defect left open —
      // a registered route nothing navigates to, or a tile pointing nowhere.
      // The hub is a long list and the tile sits in its Collaboration section, so the
      // view has to be tall enough to reach it without scrolling.
      tester.view.physicalSize = const Size(600, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final GoRouter router = GoRouter(
        initialLocation: Routes.settings,
        routes: <RouteBase>[
          GoRoute(
            path: Routes.settings,
            builder: (_, _) => const SettingsHubScreen(),
          ),
          GoRoute(
            path: Routes.settingsBlocks,
            builder: (_, _) => const Scaffold(body: Text('blocks-target')),
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [appConfigProvider.overrideWithValue(_collaborationOn)],
          child: MaterialApp.router(
            theme: buildQalamTheme(brightness: Brightness.light),
            routerConfig: router,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Safety'), findsOneWidget);
      await tester.tap(find.text('Safety'));
      await tester.pumpAndSettle();
      expect(find.text('blocks-target'), findsOneWidget);
    });

    testWidgets('the tile is hidden while collaboration is dark', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(600, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [appConfigProvider.overrideWithValue(testConfig)],
          child: MaterialApp(
            theme: buildQalamTheme(brightness: Brightness.light),
            home: const SettingsHubScreen(),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Safety'), findsNothing);
    });

    test('the app router serves that same path', () async {
      // The other half. `namedLocation` throws for an unregistered name, so this fails
      // loudly if the route is dropped while the tile survives.
      final ProviderContainer container = await buildTestContainer();
      addTearDown(container.dispose);

      final GoRouter router = container.read(goRouterProvider);
      expect(router.namedLocation('settingsBlocks'), Routes.settingsBlocks);
      // And it is behind the session guard, like every other `/settings` surface.
      expect(Routes.isProtected(Routes.settingsBlocks), isTrue);
    });
  });
}

/// The clap control on the reader action bar (M7-3).
///
/// Covers what the surface owes on top of the controller's behaviour: an
/// optimistic increment under the thumb, an inert control at the cap, the
/// sign-out prompt every other action on this bar uses, and — because an
/// accumulating control that does not announce its count is unusable with a
/// screen reader — the semantics label.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/core/connectivity/connectivity_service.dart';
import 'package:qalam_mobile/core/di/providers.dart';
import 'package:qalam_mobile/core/session/session_controller.dart';
import 'package:qalam_mobile/core/session/session_state.dart';
import 'package:qalam_mobile/features/reading/domain/entities/piece_engagement.dart';
import 'package:qalam_mobile/features/reading/presentation/controllers/engagement_controller.dart';
import 'package:qalam_mobile/features/reading/presentation/providers/reading_providers.dart';
import 'package:qalam_mobile/features/reading/presentation/widgets/reader_action_bar.dart';
import 'package:qalam_mobile/l10n/generated/app_localizations.dart';
import 'package:qalam_mobile/shared/domain/enums.dart';
import 'package:qalam_mobile/shared/domain/limits.dart';
import 'package:qalam_mobile/shared/social/social_providers.dart';
import 'package:qalam_mobile/shared/theme/app_theme.dart';

import '../../support/fake_reading_repository.dart';

class _OnlineConnectivity implements ConnectivityService {
  @override
  bool get isOnline => true;
  @override
  Stream<bool> get onStatusChange => const Stream<bool>.empty();
  @override
  Future<void> initialize() async {}
  @override
  Future<void> dispose() async {}
}

class _AuthedSession extends SessionController {
  @override
  Future<SessionState> build() async =>
      const SessionState.authenticated(role: Role.user);
}

class _AnonSession extends SessionController {
  @override
  Future<SessionState> build() async => const SessionState.anonymous();
}

ProviderContainer _container({
  required bool authed,
  required PieceEngagement engagement,
  FakeEngagementRepository? eng,
}) => ProviderContainer(
  overrides: [
    connectivityServiceProvider.overrideWithValue(_OnlineConnectivity()),
    engagementRepositoryProvider.overrideWithValue(
      eng ?? FakeEngagementRepository(),
    ),
    readingRepositoryProvider.overrideWithValue(
      FakeReadingRepository(engagement: engagement),
    ),
    sessionControllerProvider.overrideWith(
      authed ? _AuthedSession.new : _AnonSession.new,
    ),
  ],
);

Widget _wrap(ProviderContainer c) => UncontrolledProviderScope(
  container: c,
  child: MaterialApp(
    theme: buildQalamTheme(brightness: Brightness.light),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: const Scaffold(
      body: ReaderActionBar(pieceId: 'p1', slug: 'a-ghazal'),
    ),
  ),
);

Future<ProviderContainer> _pump(
  WidgetTester tester, {
  required bool authed,
  required PieceEngagement engagement,
  FakeEngagementRepository? eng,
}) async {
  final ProviderContainer c = _container(
    authed: authed,
    engagement: engagement,
    eng: eng,
  );
  addTearDown(c.dispose);
  // Hold both — an autoDispose provider disposes between plain `read`s, and its
  // scheduler leaves a pending Timer the widget binding then fails on.
  c.listen(sessionControllerProvider, (_, _) {});
  c.listen(engagementControllerProvider('p1'), (_, _) {});
  await c.read(sessionControllerProvider.future);
  await c.read(engagementControllerProvider('p1').future);
  await tester.pumpWidget(_wrap(c));
  await tester.pump();
  return c;
}

/// The clap control, found by the stable half of its accessible name.
Finder clapAction() => find.bySemanticsLabel(RegExp('^Clap'));

void main() {
  testWidgets('a tap increments both counts optimistically', (
    WidgetTester tester,
  ) async {
    final ProviderContainer c = await _pump(
      tester,
      authed: true,
      engagement: const PieceEngagement(claps: 40, clapCount: 3),
    );

    expect(find.text('40'), findsOneWidget);
    expect(find.text('· 3'), findsOneWidget);

    await tester.tap(clapAction());
    await tester.pump();

    expect(find.text('41'), findsOneWidget, reason: 'the piece total');
    expect(find.text('· 4'), findsOneWidget, reason: "the viewer's own");

    // Settle the debounce timer so it does not fire into a torn-down tree.
    await c.read(engagementControllerProvider('p1').notifier).flushClaps();
  });

  testWidgets('at the cap the control is inert — no increment, no request', (
    WidgetTester tester,
  ) async {
    final FakeEngagementRepository eng = FakeEngagementRepository()
      ..viewerClaps = Limits.maxClapsPerUserPerPiece;
    await _pump(
      tester,
      authed: true,
      engagement: const PieceEngagement(
        claps: 500,
        clapCount: Limits.maxClapsPerUserPerPiece,
      ),
      eng: eng,
    );

    await tester.tap(clapAction(), warnIfMissed: false);
    await tester.pump();

    expect(find.text('500'), findsOneWidget, reason: 'the total did not move');
    expect(eng.clapCalls, isEmpty);
  });

  testWidgets('the semantics label announces the count, and the cap', (
    WidgetTester tester,
  ) async {
    await _pump(
      tester,
      authed: true,
      engagement: const PieceEngagement(claps: 40, clapCount: 12),
    );
    // The count must be IN the accessible name — an accumulating control that
    // announces only "Clap" tells a screen-reader user nothing about their 12.
    expect(find.bySemanticsLabel(RegExp('^Clap.*given 12')), findsOneWidget);

    await _pump(
      tester,
      authed: true,
      engagement: const PieceEngagement(
        claps: 500,
        clapCount: Limits.maxClapsPerUserPerPiece,
      ),
    );
    expect(
      find.bySemanticsLabel(
        RegExp('^Clap.*given all ${Limits.maxClapsPerUserPerPiece}'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('a signed-out tap prompts sign-in instead of clapping', (
    WidgetTester tester,
  ) async {
    final FakeEngagementRepository eng = FakeEngagementRepository();
    await _pump(
      tester,
      authed: false,
      engagement: const PieceEngagement(claps: 40),
      eng: eng,
    );

    await tester.tap(clapAction());
    await tester.pump();

    expect(find.text('Sign in to do that.'), findsOneWidget);
    expect(find.text('40'), findsOneWidget, reason: 'nothing was incremented');
    expect(eng.clapCalls, isEmpty);
  });

  testWidgets('the counts are PUBLIC — a signed-out reader still sees them', (
    WidgetTester tester,
  ) async {
    await _pump(
      tester,
      authed: false,
      engagement: const PieceEngagement(claps: 128),
    );
    expect(find.text('128'), findsOneWidget);
  });

  testWidgets('More offers all-or-nothing removal, labelled with the count', (
    WidgetTester tester,
  ) async {
    final FakeEngagementRepository eng = FakeEngagementRepository()
      ..viewerClaps = 7
      ..clapTotal = 30;
    await _pump(
      tester,
      authed: true,
      engagement: const PieceEngagement(claps: 30, clapCount: 7),
      eng: eng,
    );

    await tester.tap(find.bySemanticsLabel('More actions'));
    await tester.pumpAndSettle();

    // Never a "−1": the endpoint has no decrement.
    expect(find.text('Remove my 7 claps'), findsOneWidget);

    await tester.tap(find.text('Remove my 7 claps'));
    await tester.pumpAndSettle();

    expect(eng.unclapCalls, 1);
    expect(find.text('23'), findsOneWidget, reason: '30 − my 7');
  });

  testWidgets('More offers no removal when the reader has no claps', (
    WidgetTester tester,
  ) async {
    await _pump(
      tester,
      authed: true,
      engagement: const PieceEngagement(claps: 30),
    );

    await tester.tap(find.bySemanticsLabel('More actions'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Remove my'), findsNothing);
  });
}

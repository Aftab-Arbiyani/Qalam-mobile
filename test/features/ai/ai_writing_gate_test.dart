/// **D3** — the free tier gets no AI writing (owner, 2026-08-08; `platfrom/docs/45` §4 row D3,
/// `docs/48` §5.2 item 4 and §6.13).
///
/// ⚠️ These tests encode a deliberate behaviour REGRESSION: a free writer who could use the
/// assistant and the coach yesterday cannot today. It was flagged before the decision was taken
/// and accepted — nothing here softens it.
///
/// Four things are pinned, and the third matters as much as the first:
///
/// 1. **The map is total.** Dart cannot check a `Map` literal for exhaustiveness the way the
///    server's `satisfies Record<AiFeature, …>` does, so `aiPremiumMapIsTotal` stands in for it
///    and is asserted here. A new AI id must DECLARE that it is free, never inherit it.
/// 2. **Both AF2 panels are gated**, and a denied writer gets the writing copy — not the
///    allowance copy, which would be false as well as the wrong remedy.
/// 3. **Nothing else is gated.** `ask_book`, `semantic_search` and `recommendations` belong to
///    **D4**, whose scope the owner deferred; §5.2 consequence 1 forbids a client-side wall in
///    front of a route the server still serves.
/// 4. **All four remedies stay apart.** There are now four ways AI can be off, each with a
///    different fix. Conflating any two is the W4 defect recorded in §3.6.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/core/config/app_config.dart';
import 'package:qalam_mobile/core/config/app_flavor.dart';
import 'package:qalam_mobile/core/di/providers.dart';
import 'package:qalam_mobile/features/ai/domain/value_objects/ai_feature_ids.dart';
import 'package:qalam_mobile/features/ai/domain/value_objects/ai_writing_context.dart';
import 'package:qalam_mobile/features/ai/presentation/controllers/craft_coach_controller.dart';
import 'package:qalam_mobile/features/ai/presentation/panels/craft_coach_panel.dart';
import 'package:qalam_mobile/features/ai/presentation/support/ai_error_copy.dart';
import 'package:qalam_mobile/features/ai/presentation/widgets/ai_writing_lock_card.dart';
import 'package:qalam_mobile/features/monetization/domain/entities/entitlement.dart';
import 'package:qalam_mobile/features/monetization/domain/entities/monetization_enums.dart';
import 'package:qalam_mobile/features/monetization/presentation/providers/monetization_providers.dart';
import 'package:qalam_mobile/features/monetization/presentation/widgets/premium_gate.dart';
import 'package:qalam_mobile/shared/domain/error_codes.dart';
import 'package:qalam_mobile/shared/theme/app_theme.dart';

const AppConfig _config = AppConfig(
  flavor: AppFlavor.development,
  apiUrl: 'http://localhost:4000',
  cdnUrl: '',
  webUrl: '',
  sentryDsn: '',
  enablePush: false,
  enableAi: true,
  enableMonetization: true,
  enableCollaboration: false,
);

EntitlementDecision _decision(String feature, {required bool allowed}) =>
    EntitlementDecision(
      feature: feature,
      status: allowed ? EntitlementStatus.allow : EntitlementStatus.deny,
      allowed: allowed,
      reason: allowed
          ? EntitlementReason.planIncludes
          : EntitlementReason.planExcludes,
    );

/// A snapshot where `ai_writing` is decided and `ai_budget` is ALWAYS granted.
///
/// That combination is DECISION 2a and it is the shape a real free account has: 48 §5.2 asked
/// for free's allowance to be removed as "unspendable", but `ask_book` and semantic-search
/// synthesis both meter against `ai_budget` and are live on both clients, so it is spendable.
/// Removing it would have denied free users every metered AI feature — far wider than D3.
EntitlementSnapshot _snapshot({required bool writingAllowed}) =>
    EntitlementSnapshot(
      tier: writingAllowed ? PlanTier.plus : PlanTier.free,
      status: EntitlementStatus.allow,
      features: <EntitlementDecision>[
        _decision(PremiumFeature.aiWriting, allowed: writingAllowed),
        _decision(PremiumFeature.aiBudget, allowed: true),
      ],
    );

const AiWritingContext _writingContext = AiWritingContext(
  chapterText: 'The cartographer folded the last map.',
  title: 'The Cartographer',
  language: 'en',
  wordCount: 6,
);

/// A coach controller frozen in a terminal error state, so the panel renders the branch a
/// mid-flight failure produces without running a generation.
class _FailedCoachController extends CraftCoachController {
  _FailedCoachController(this._code);

  final String _code;

  @override
  CraftCoachState build() =>
      CraftCoachState(phase: CoachPhase.error, errorCode: _code);
}

Future<void> _pumpCoach(
  WidgetTester tester, {
  required bool writingAllowed,
  String? failedWith,
}) async {
  tester.view.physicalSize = const Size(800, 2000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appConfigProvider.overrideWithValue(_config),
        entitlementSnapshotProvider.overrideWith(
          (_) async => _snapshot(writingAllowed: writingAllowed),
        ),
        if (failedWith != null)
          craftCoachControllerProvider.overrideWith(
            () => _FailedCoachController(failedWith),
          ),
      ],
      child: MaterialApp(
        theme: buildQalamTheme(brightness: Brightness.light),
        home: const Scaffold(
          body: CraftCoachPanel(writingContext: _writingContext),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump();
}

void main() {
  group('the AiFeature → PremiumFeature map', () {
    test('is TOTAL over every id this client knows', () {
      // The stand-in for the server's compile-time totality pin. If this fails, an id was added
      // to `AiFeatureIds` without deciding whether it is paid — and the default must never be
      // "free by omission".
      expect(aiPremiumMapIsTotal(), isTrue);
    });

    test('sells exactly the two AF2 surfaces behind ai_writing', () {
      expect(
        premiumCodeFor(AiFeatureIds.writingAssistant),
        PremiumFeature.aiWriting,
      );
      expect(premiumCodeFor(AiFeatureIds.craftCoach), PremiumFeature.aiWriting);
    });

    test('leaves D4 codes and the playground UNGATED — scope was deferred', () {
      // The scope regression test. Gating any of these would put a client-only wall in front of
      // a route the server serves (docs/48 §5.2 consequence 1) and pre-empt D4.
      for (final String id in <String>[
        AiFeatureIds.askBook,
        AiFeatureIds.semanticSearch,
        AiFeatureIds.recommendations,
        AiFeatureIds.playground,
      ]) {
        expect(premiumCodeFor(id), isNull, reason: '$id must not be gated');
      }
    });

    test('answers null for an unknown id rather than throwing', () {
      // A server that has learned a feature this build has not must not crash a panel.
      expect(premiumCodeFor('a_feature_from_the_future'), isNull);
      expect(premiumCodeFor(null), isNull);
    });
  });

  group('the four remedies stay apart (docs/48 §3.6)', () {
    test('each of the four ways AI can be off has its own title and remedy', () {
      final AiErrorCopy platformOff = AiErrorCopy.forCode(
        ErrorCodes.aiDisabled,
      );
      final AiErrorCopy selfOff = AiErrorCopy.forCode(
        ErrorCodes.aiDisabledByUser,
      );
      final AiErrorCopy quota = AiErrorCopy.forCode(ErrorCodes.quotaExceeded);
      final AiErrorCopy writing = AiErrorCopy.forCode(
        ErrorCodes.entitlementDenied,
        feature: AiFeatureIds.writingAssistant,
      );

      final Set<String> titles = <String>{
        platformOff.title,
        selfOff.title,
        quota.title,
        writing.title,
      };
      expect(titles.length, 4);

      // Only the writing one is resolvable by the writer through a plan; quota resolves itself,
      // and the two "off" states are a switch (theirs or an admin's).
      expect(writing.canUpgrade, isTrue);
      expect(quota.canUpgrade, isFalse);
      expect(selfOff.canUpgrade, isFalse);
      expect(platformOff.canUpgrade, isFalse);
      // None of the four is retryable — retrying is never the remedy for any of them.
      expect(<bool>[
        platformOff.canRetry,
        selfOff.canRetry,
        quota.canRetry,
        writing.canRetry,
      ], everyElement(isFalse));
    });

    test('the writing remedy names the tier and never the allowance', () {
      const AiErrorCopy copy = AiErrorCopy.aiWritingLocked;

      expect(copy.title.toLowerCase(), contains('plus'));
      expect(copy.message.toLowerCase(), contains('ai writing'));
      // Free KEEPS its allowance (DECISION 2a), so claiming otherwise would be untrue as well
      // as the wrong remedy — the writer can still use search and Ask my book.
      expect(copy.message.toLowerCase(), isNot(contains('allowance')));
      expect(copy.message.toLowerCase(), isNot(contains('resets')));
      expect(copy.message.toLowerCase(), isNot(contains('settings')));
    });

    test('an ENTITLEMENT_DENIED on an AF4 surface keeps the allowance copy', () {
      // `ask_book`'s denial is an `ai_budget` denial, not a writing one, so it must not be
      // reworded — and a caller that names no feature keeps the pre-D3 behaviour exactly.
      final AiErrorCopy ask = AiErrorCopy.forCode(
        ErrorCodes.entitlementDenied,
        feature: AiFeatureIds.askBook,
      );
      final AiErrorCopy unnamed = AiErrorCopy.forCode(
        ErrorCodes.entitlementDenied,
      );

      expect(ask.title, 'This needs a paid plan');
      expect(unnamed.title, 'This needs a paid plan');
      expect(ask.title, isNot(AiErrorCopy.aiWritingLocked.title));
    });
  });

  group('the Craft Coach panel is gated (DECISION 1)', () {
    testWidgets('mounts a PremiumGate on ai_writing', (
      WidgetTester tester,
    ) async {
      await _pumpCoach(tester, writingAllowed: true);

      final PremiumGate gate = tester.widget<PremiumGate>(
        find.byType(PremiumGate),
      );
      expect(gate.feature, PremiumFeature.aiWriting);
    });

    testWidgets('withholds the coaching lenses from a FREE writer', (
      WidgetTester tester,
    ) async {
      await _pumpCoach(tester, writingAllowed: false);

      expect(find.byType(AiWritingLockCard), findsOneWidget);
      expect(find.text(AiErrorCopy.aiWritingLocked.title), findsOneWidget);
      expect(find.text('See plans'), findsOneWidget);
      // The panel's own chrome is gone too — the writer is not offered a lens they cannot run.
      expect(find.text('Craft coach'), findsNothing);
    });

    testWidgets('lets an ENTITLED writer straight through', (
      WidgetTester tester,
    ) async {
      await _pumpCoach(tester, writingAllowed: true);

      expect(find.byType(AiWritingLockCard), findsNothing);
      expect(find.text('Craft coach'), findsOneWidget);
    });

    testWidgets('shows the writing lock, NOT the allowance lock', (
      WidgetTester tester,
    ) async {
      await _pumpCoach(tester, writingAllowed: false);

      // `FeatureLockCard` is monetization's generic lock; using it here would compose copy from
      // the server's reason and say something different from what the mid-flight 402 says on
      // this same surface.
      expect(find.byType(FeatureLockCard), findsNothing);
      expect(find.textContaining('needs a paid plan'), findsNothing);
    });
  });

  group('a 402 arriving MID-FLIGHT, after the gate opened', () {
    /// The window the gate cannot cover: the entitlement can be revoked — or the payments flag
    /// raised — between opening the panel and the generation finishing. The refusal then arrives
    /// as an error code on the request, not as a denial in the snapshot, and it has to read as
    /// the same wall the gate would have shown.
    testWidgets('renders the AI-writing remedy, not the allowance one', (
      WidgetTester tester,
    ) async {
      await _pumpCoach(
        tester,
        writingAllowed: true,
        failedWith: ErrorCodes.entitlementDenied,
      );

      expect(find.text(AiErrorCopy.aiWritingLocked.title), findsOneWidget);
      expect(find.text('This needs a paid plan'), findsNothing);
      expect(find.text('See plans'), findsOneWidget);
    });

    testWidgets('still calls a spent allowance a spent allowance', (
      WidgetTester tester,
    ) async {
      // The neighbouring code must not be dragged along by D3 — its remedy is waiting.
      await _pumpCoach(
        tester,
        writingAllowed: true,
        failedWith: ErrorCodes.quotaExceeded,
      );

      expect(find.text('You’ve used your AI allowance'), findsOneWidget);
      expect(find.text(AiErrorCopy.aiWritingLocked.title), findsNothing);
    });
  });
}

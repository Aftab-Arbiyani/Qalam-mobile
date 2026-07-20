import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:qalam_mobile/core/utils/result.dart';
import 'package:qalam_mobile/features/collaboration/domain/entities/collaboration_enums.dart';
import 'package:qalam_mobile/features/collaboration/domain/entities/policy_capability.dart';
import 'package:qalam_mobile/features/collaboration/domain/entities/trust_summary.dart';
import 'package:qalam_mobile/features/collaboration/domain/repositories/collaboration_repository.dart';
import 'package:qalam_mobile/features/collaboration/domain/repositories/trust_repository.dart';
import 'package:qalam_mobile/features/collaboration/presentation/screens/restricted_state_screen.dart';
import 'package:qalam_mobile/features/collaboration/presentation/widgets/capability_gate.dart';
import 'package:qalam_mobile/shared/theme/app_theme.dart';

import '../../support/harness.dart';

class _MockCollaborationRepository extends Mock
    implements CollaborationRepository {}

class _MockTrustRepository extends Mock implements TrustRepository {}

StoryCapabilities _caps({required bool allowComment}) => StoryCapabilities(
  capabilities: <String, PolicyCapability>{
    PolicyAction.storyComment: PolicyCapability(
      action: PolicyAction.storyComment,
      effect: allowComment ? PolicyEffect.allow : PolicyEffect.deny,
      allowed: allowComment,
      reason: allowComment ? 'role_allows' : 'role_denies',
      obligations: const <String>[],
    ),
  },
);

Widget _wrap(ProviderContainer container, Widget child) =>
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: buildQalamTheme(brightness: Brightness.light),
        home: Scaffold(body: child),
      ),
    );

void main() {
  group('CapabilityGate', () {
    testWidgets('renders the child when the action is allowed', (
      WidgetTester tester,
    ) async {
      final _MockCollaborationRepository repo = _MockCollaborationRepository();
      when(() => repo.capabilities('s1')).thenAnswer(
        (_) async => Ok<StoryCapabilities>(_caps(allowComment: true)),
      );

      late final ProviderContainer container;
      await tester.runAsync(() async {
        container = await buildTestContainer(collaborationRepository: repo);
      });
      addTearDown(container.dispose);

      await tester.pumpWidget(
        _wrap(
          container,
          const CapabilityGate(
            storyId: 's1',
            action: PolicyAction.storyComment,
            child: Text('gated-content'),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('gated-content'), findsOneWidget);
    });

    testWidgets('hides the child when the action is denied', (
      WidgetTester tester,
    ) async {
      final _MockCollaborationRepository repo = _MockCollaborationRepository();
      when(() => repo.capabilities('s1')).thenAnswer(
        (_) async => Ok<StoryCapabilities>(_caps(allowComment: false)),
      );

      late final ProviderContainer container;
      await tester.runAsync(() async {
        container = await buildTestContainer(collaborationRepository: repo);
      });
      addTearDown(container.dispose);

      await tester.pumpWidget(
        _wrap(
          container,
          const CapabilityGate(
            storyId: 's1',
            action: PolicyAction.storyComment,
            child: Text('gated-content'),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('gated-content'), findsNothing);
    });
  });

  group('RestrictedStateScreen', () {
    testWidgets('renders the restricted wall for a read-only account', (
      WidgetTester tester,
    ) async {
      final _MockTrustRepository repo = _MockTrustRepository();
      const TrustSummary restricted = TrustSummary(
        score: 20,
        level: 'limited',
        status: TrustStatus.readOnly,
        activeStrikeWeight: 3,
        restrictions: <UserRestriction>[
          UserRestriction(
            id: 'r1',
            type: RestrictionType.readOnly,
            reason: 'Repeated guideline violations',
            active: true,
          ),
        ],
      );
      when(
        repo.myTrust,
      ).thenAnswer((_) async => const Ok<TrustSummary>(restricted));

      late final ProviderContainer container;
      await tester.runAsync(() async {
        container = await buildTestContainer(trustRepository: repo);
      });
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container, const RestrictedStateScreen()));
      await tester.pump();

      expect(find.text('Your account is read-only'), findsOneWidget);
      expect(find.textContaining('Read-only'), findsWidgets);
    });

    testWidgets('renders good-standing state when unrestricted', (
      WidgetTester tester,
    ) async {
      final _MockTrustRepository repo = _MockTrustRepository();
      when(
        repo.myTrust,
      ).thenAnswer((_) async => const Ok<TrustSummary>(TrustSummary.healthy));

      late final ProviderContainer container;
      await tester.runAsync(() async {
        container = await buildTestContainer(trustRepository: repo);
      });
      addTearDown(container.dispose);

      await tester.pumpWidget(_wrap(container, const RestrictedStateScreen()));
      await tester.pump();

      expect(find.textContaining('good standing'), findsOneWidget);
    });
  });
}

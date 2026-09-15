/// How an allowance is put into words (**D5**, M3).
///
/// Two things are pinned here, and the second matters more than it looks.
///
/// [allowanceLine] is ordinary copy. [planLimitSpec] is an **allowlist** — the gate
/// that decides which `PlanLimits` keys may appear on a plan card at all. The tempting
/// implementation is to render every entry and prettify the key, and that is precisely
/// how "aiMonthlyTokens: 250000" ends up back on a plan card. D5 exists to stop a
/// writer being sold a token budget, so a key nobody has decided how to present is
/// simply not shown.
///
/// The sentinel tests are the other half. `0` means unlimited nearly everywhere, but
/// `maxCollaborators` is inverted (`-1` unlimited, `0` none) — a single shared rule
/// would advertise "Unlimited collaborators" on a plan that allows none.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:umberleaf_mobile/features/monetization/domain/entities/usage_summary.dart';
import 'package:umberleaf_mobile/features/monetization/presentation/allowance_labels.dart';

FeatureAllowance _allowance({
  String key = 'polishActionsPerDay',
  String label = 'Polish',
  String window = 'daily',
  int used = 12,
  int? limit = 30,
}) => FeatureAllowance(
  key: key,
  label: label,
  window: window,
  used: used,
  limit: limit,
);

void main() {
  group('allowanceLine', () {
    test('reads as a sentence a writer can act on', () {
      expect(allowanceLine(_allowance()), '12 of 30 today');
      expect(
        allowanceLine(
          _allowance(
            key: 'storyAnalysesPerMonth',
            window: 'monthly',
            used: 3,
            limit: 20,
          ),
        ),
        '3 of 20 this month',
      );
    });

    test('says Unlimited rather than counting toward nothing', () {
      expect(allowanceLine(_allowance(limit: null)), 'Unlimited');
    });

    /// A window the client has not learned yet still produces a usable line rather
    /// than a dangling "12 of 30 " — these vocabularies are open on the wire.
    test('an unknown window degrades to the bare count', () {
      expect(allowanceLine(_allowance(window: 'weekly')), '12 of 30');
    });
  });

  group('allowanceNoun', () {
    test('prefers the server label, so the two halves cannot drift', () {
      expect(allowanceNoun(_allowance()), 'Polish');
    });

    test('falls back per key, never to a camelCase wire string', () {
      expect(
        allowanceNoun(_allowance(key: 'feedbackReportsPerDay', label: '')),
        'Manuscript feedback',
      );
    });
  });

  /// A spent allowance NEVER offers a plan: it resets on its own, and pointing at the
  /// plans page sells someone something they do not need (docs/48 §5.2, consequence 2).
  test('an exhausted allowance names the window and offers no upgrade', () {
    final String daily = allowanceExhaustedLine(_allowance(used: 30));
    final String monthly = allowanceExhaustedLine(
      _allowance(
        key: 'storyAnalysesPerMonth',
        window: 'monthly',
        used: 20,
        limit: 20,
      ),
    );

    expect(daily, contains('today'));
    expect(monthly, contains('month'));
    for (final String line in <String>[daily, monthly]) {
      expect(line.toLowerCase(), isNot(contains('plan')));
      expect(line.toLowerCase(), isNot(contains('upgrade')));
    }
  });

  group('planLimitSpec — the allowlist', () {
    test('renders the three tool allowances with their windows', () {
      expect(
        planLimitSpec('polishActionsPerDay')!.describe(100),
        '100 polish actions a day',
      );
      expect(
        planLimitSpec('storyAnalysesPerMonth')!.describe(20),
        '20 story analyses a month',
      );
    });

    /// **The load-bearing case.** Every token/credit key must be absent, and so must
    /// anything unrecognised — an omission is the safe default here, not a gap.
    test('refuses every key nobody has decided how to present', () {
      for (final String key in <String>[
        'aiMonthlyTokens',
        'aiDailyTokens',
        'aiMonthlyCredits',
        'somethingTheServerAddedYesterday',
      ]) {
        expect(
          planLimitSpec(key),
          isNull,
          reason: '$key must not reach a plan card',
        );
      }
      expect(planLimitLines(<String, int>{'aiMonthlyTokens': 250000}), isEmpty);
    });

    test('0 means unlimited for the ordinary keys', () {
      expect(
        planLimitSpec('polishActionsPerDay')!.describe(0),
        'Unlimited polish actions',
      );
      expect(planLimitSpec('maxPieces')!.describe(0), 'Unlimited pieces');
      expect(
        planLimitSpec('maxSnapshotHistory')!.describe(0),
        'Unlimited saved versions',
      );
    });

    /// The one inverted key in the catalogue. Getting this wrong advertises unlimited
    /// collaborators to a plan that allows none — the failure is silent and inverted,
    /// which is the worst combination.
    test('maxCollaborators inverts: -1 unlimited, 0 none', () {
      final PlanLimitSpec spec = planLimitSpec('maxCollaborators')!;
      expect(spec.describe(-1), 'Unlimited collaborators');
      expect(spec.describe(0), 'No collaborators');
      expect(spec.describe(3), '3 collaborators');
    });

    test(
      'lines come out in a stable order so two plans compare row by row',
      () {
        final List<String> lines = planLimitLines(<String, int>{
          'maxCollaborators': 3,
          'polishActionsPerDay': 100,
          'aiMonthlyTokens': 250000,
          'storyAnalysesPerMonth': 20,
        });
        expect(lines, <String>[
          '100 polish actions a day',
          '20 story analyses a month',
          '3 collaborators',
        ]);
      },
    );
  });
}

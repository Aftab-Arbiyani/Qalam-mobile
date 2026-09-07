/// B5 (`platfrom/docs/45` §4.10) — the per-account AI switch, as this client reads it.
///
/// The decode defaults matter more than they look: mobile's `AiFeatures.fromJson` is the
/// value every AI affordance gates on, and the AF6 audit (`docs/56`) recorded a capability
/// map that decoded empty and made every gate deny. The same mistake here — defaulting
/// `userAiEnabled` to `false`, or reading a missing key as opted-out — would silently
/// strip AI from writers who never asked for it.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/features/ai/domain/entities/ai_feature_flag.dart';
import 'package:qalam_mobile/features/ai/domain/value_objects/ai_feature_ids.dart';
import 'package:qalam_mobile/features/ai/presentation/support/ai_error_copy.dart';
import 'package:qalam_mobile/shared/domain/error_codes.dart';

AiFeatures _decode({
  required bool aiEnabled,
  bool? userAiEnabled,
  bool assistant = true,
}) => AiFeatures.fromJson(<String, dynamic>{
  'aiEnabled': aiEnabled,
  // Null omits the key entirely — the "older server / trimmed payload" case below.
  'userAiEnabled': ?userAiEnabled,
  'features': <dynamic>[
    <String, dynamic>{
      'feature': AiFeatureIds.writingAssistant,
      'flagKey': 'feature.ai.writingAssistant.enabled',
      'enabled': assistant,
    },
  ],
});

void main() {
  group('AiFeatures decode (B5)', () {
    test('an opted-out writer reads as off, everywhere', () {
      final AiFeatures flags = _decode(aiEnabled: false, userAiEnabled: false);

      expect(flags.aiEnabled, isFalse);
      // Every per-feature gate ANDs the master value, so one server field turns the
      // whole client off — which is why the client halves of B5 are small.
      expect(flags.isEnabled(AiFeatureIds.writingAssistant), isFalse);
      expect(flags.disabledByUser, isTrue);
    });

    test('the PLATFORM switch being down is not blamed on the writer', () {
      final AiFeatures flags = _decode(aiEnabled: false, userAiEnabled: true);

      expect(flags.aiEnabled, isFalse);
      // Admin off beats user on. Reporting this as the writer's doing would send them
      // to a switch that is already on.
      expect(flags.disabledByUser, isFalse);
    });

    test(
      'an ordinary writer is untouched — AI on, features follow their flags',
      () {
        final AiFeatures flags = _decode(aiEnabled: true, userAiEnabled: true);

        expect(flags.aiEnabled, isTrue);
        expect(flags.disabledByUser, isFalse);
        expect(flags.isEnabled(AiFeatureIds.writingAssistant), isTrue);
      },
    );

    test('a MISSING userAiEnabled defaults to on, never to opted-out', () {
      // An older server, or a trimmed payload. Defaulting the other way would hide AI
      // from every writer on a deployment that has not shipped the B5 backend yet.
      final AiFeatures flags = _decode(aiEnabled: true);

      expect(flags.userAiEnabled, isTrue);
      expect(flags.disabledByUser, isFalse);
      expect(flags.isEnabled(AiFeatureIds.writingAssistant), isTrue);
    });
  });

  /// **D5 changed what this group can assert, and the change is a real loss.**
  ///
  /// B5's whole point was that `AI_DISABLED_BY_USER` had a remedy the writer owned: a
  /// switch one screen away, which the copy named. D5 deleted that screen. So the two
  /// tests that pinned the distinct sentence are gone, replaced by one that pins the
  /// merge — because the alternative was keeping copy that sends a writer looking for a
  /// control that no longer exists, which is worse than saying less.
  ///
  /// The distinct CODE survives on the wire, and that still matters: an unmapped code
  /// falls through to the generic retryable failure and invites an infinite retry.
  group('AI_DISABLED_BY_USER copy (D5)', () {
    test('reads the same as the platform switch, and points nowhere', () {
      final AiErrorCopy self = AiErrorCopy.forCode(ErrorCodes.aiDisabledByUser);
      final AiErrorCopy platform = AiErrorCopy.forCode(ErrorCodes.aiDisabled);

      expect(self.title, 'Writing tools aren’t available');
      expect(self.title, platform.title);
      expect(self.message, platform.message);
      // The remedy it used to name is gone; nothing replaces it, and the copy does not
      // pretend otherwise.
      expect(self.message, isNot(contains('Settings')));
      expect(self.canRetry, isFalse);
      expect(self.canUpgrade, isFalse);
    });

    test('stays distinct from the quota and plan walls', () {
      // Three walls, three sentences. Collapsing THESE would still be the W4 defect
      // (docs/48 §3.6) — their remedies genuinely differ.
      final AiErrorCopy off = AiErrorCopy.forCode(ErrorCodes.aiDisabledByUser);
      final AiErrorCopy quota = AiErrorCopy.forCode(
        ErrorCodes.aiUsageLimitExceeded,
      );
      final AiErrorCopy plan = AiErrorCopy.forCode(
        ErrorCodes.entitlementDenied,
      );

      expect(<String>{off.title, quota.title, plan.title}, hasLength(3));
      expect(plan.canUpgrade, isTrue);
      expect(off.canUpgrade, isFalse);
    });

    test('an unknown code is still the generic retryable failure', () {
      // The new case must not have swallowed the fallback.
      expect(AiErrorCopy.forCode('SOMETHING_ELSE').canRetry, isTrue);
    });
  });
}

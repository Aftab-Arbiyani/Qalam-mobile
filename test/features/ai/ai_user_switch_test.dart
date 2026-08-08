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

  group('AI_DISABLED_BY_USER copy', () {
    test('points at settings, and not at a plan or a reset', () {
      final AiErrorCopy copy = AiErrorCopy.forCode(ErrorCodes.aiDisabledByUser);

      expect(copy.title, 'You turned AI off');
      expect(copy.message, contains('Settings'));
      // Its whole reason for existing: a remedy the writer owns.
      expect(copy.canRetry, isFalse);
      expect(copy.canUpgrade, isFalse);
      expect(copy.message, isNot(contains('plan')));
      expect(copy.message, isNot(contains('resets')));
    });

    test('is distinct from the platform switch and from the quota family', () {
      final AiErrorCopy self = AiErrorCopy.forCode(ErrorCodes.aiDisabledByUser);
      final AiErrorCopy platform = AiErrorCopy.forCode(ErrorCodes.aiDisabled);
      final AiErrorCopy quota = AiErrorCopy.forCode(
        ErrorCodes.aiUsageLimitExceeded,
      );
      final AiErrorCopy plan = AiErrorCopy.forCode(
        ErrorCodes.entitlementDenied,
      );

      // Four walls, four sentences. Collapsing any pair is the W4 defect (docs/48 §3.6).
      expect(<String>{
        self.title,
        platform.title,
        quota.title,
        plan.title,
      }, hasLength(4));
      expect(plan.canUpgrade, isTrue);
      expect(self.canUpgrade, isFalse);
    });

    test('an unknown code is still the generic retryable failure', () {
      // The new case must not have swallowed the fallback.
      expect(AiErrorCopy.forCode('SOMETHING_ELSE').canRetry, isTrue);
    });
  });
}

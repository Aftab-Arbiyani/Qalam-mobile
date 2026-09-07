/// Human, honest copy for the writing tools' error codes — the streaming path surfaces
/// a stable `ERROR_CODES` string (not a [Failure]), so this maps each to a friendly
/// title/message and whether a retry can help. Never shows a raw code or message.
///
/// **A spent allowance and a denied entitlement are not the same wall (AF5, docs/48
/// §5.2).** Every request meters through the `AI_USAGE_METER` hook, which can refuse it
/// two ways: the plan does not include the capability at all, or this window's allowance
/// is spent. The remedies diverge completely — an allowance resets on its own and
/// waiting is enough; a denied entitlement never resets and only a plan changes it.
/// Both were once unmapped here and fell through to the generic retryable failure, which
/// told a blocked writer to try again and then to wait for a reset that would never
/// help. The denial carries [canUpgrade]; the allowance never does.
///
/// **Every sentence here was swept at D5 (M4).** The word "AI" is gone from all of them,
/// and not by find-and-replace: several needed rewriting, because they named a *vendor*
/// ("The AI service had a problem") or a *remedy that no longer exists* ("Turn it back
/// on in Settings › AI"). A writer cannot act on either. The one place the machinery is
/// named is [ModelDisclosureNote], once, in the foot of each tool — stating it plainly
/// there is what earns the right to leave it out of everything else.
library;

import '../../../../shared/domain/error_codes.dart';
import '../../../monetization/domain/entities/monetization_enums.dart';
import '../../domain/value_objects/ai_feature_ids.dart';

class AiErrorCopy {
  const AiErrorCopy({
    required this.title,
    required this.message,
    required this.canRetry,
    this.canUpgrade = false,
  });

  final String title;
  final String message;
  final bool canRetry;

  /// The writer can resolve this themselves by changing plan — the only blocked state
  /// that carries an action. Retrying and waiting are not remedies for it, so this is
  /// never set together with [canRetry].
  final bool canUpgrade;

  /// The copy for a failed request, optionally narrowed by WHICH tool failed.
  ///
  /// **D3 (`platfrom/docs/45` §4 row D3, `docs/48` §6.13).** `ENTITLEMENT_DENIED` has two
  /// readings and they lead to different places, so the feature decides which: a denial on a
  /// surface sold behind `ai_writing` is about the writing tools, while a denial anywhere else
  /// is generic. It reads [premiumCodeFor] — the same map the server gated on — rather than
  /// the 402's `details`, so the copy cannot drift from the decision.
  ///
  /// **D5 (M3) does the same for a spent allowance**, and for a sharper reason. Limits are
  /// per-feature counts now, in *different windows*: Polish and feedback reset daily, story
  /// analyses monthly. "You've used your allowance" leaves a writer guessing which tool
  /// stopped and when it returns — and a wrong guess means waiting a month for something
  /// that comes back tomorrow.
  static AiErrorCopy forCode(String? code, {String? feature}) {
    if (code == ErrorCodes.entitlementDenied &&
        premiumCodeFor(feature) == PremiumFeature.aiWriting) {
      return aiWritingLocked;
    }
    if (code == ErrorCodes.quotaExceeded ||
        code == ErrorCodes.aiUsageLimitExceeded) {
      final _Allowance? allowance = _allowanceFor(feature);
      if (allowance != null) {
        return AiErrorCopy(
          title: 'You’ve used ${allowance.when}’s ${allowance.noun}',
          message:
              'Your allowance resets ${allowance.resets}. Your writing is unaffected.',
          canRetry: false,
        );
      }
    }
    return _forCode(code);
  }

  /// Which allowance a feature spends, in words. Mirrors the server's `AI_QUOTA_RULES`
  /// — the ONE place that decides which counter a feature draws on — so a feature with
  /// no rule (the playground) correctly falls through to the generic copy rather than
  /// inventing a window.
  static _Allowance? _allowanceFor(String? feature) => switch (feature) {
    AiFeatureIds.writingAssistant => const _Allowance(
      when: 'today',
      noun: 'Polish actions',
      resets: 'tomorrow',
    ),
    AiFeatureIds.craftCoach => const _Allowance(
      when: 'today',
      noun: 'feedback reports',
      resets: 'tomorrow',
    ),
    _ => null,
  };

  /// D3's remedy. There are THREE distinct ways the writing tools can be unavailable and
  /// each has a different fix: they are switched off (nothing the writer can do), the
  /// allowance is spent (wait), and this one — the tools are a paid capability (change
  /// plan). Conflating any two is the W4 defect recorded in `docs/48` §3.6.
  ///
  /// **D5 took the count from four to three**, by merging the two "off" states below.
  ///
  /// Deliberately names the tier, and deliberately does NOT mention the allowance: a free
  /// writer keeps search, recommendations and their drafts. Telling them their plan has no
  /// allowance would be false as well as the wrong remedy.
  static const AiErrorCopy aiWritingLocked = AiErrorCopy(
    title: 'Polish & feedback is on Plus and above',
    message:
        'Your plan doesn’t include Polish or manuscript feedback. Your drafts are unaffected — the editor and search work as usual.',
    canRetry: false,
    canUpgrade: true,
  );

  static AiErrorCopy _forCode(String? code) => switch (code) {
    // **D5 merged these two**, and the merge is a correction rather than a
    // simplification. They used to be kept apart on the W4 principle (docs/48 §3.6):
    // `AI_DISABLED` is an administrator's switch that the writer can only wait out, while
    // `AI_DISABLED_BY_USER` was their own and was "one screen away" — so its message named
    // that screen. **D5 deleted that screen.** Copy that points at a remedy which no longer
    // exists is worse than copy that offers none: it sends the writer looking for a control
    // they will not find. So both now say the same thing, which blames nobody and promises
    // nothing. The distinct CODE is still mapped, because an unmapped code falls through to
    // the generic retryable failure and invites an infinite retry.
    //
    // The writer who turned AI off before D5 is genuinely stuck. That is a recorded
    // residue, not something a sentence can fix.
    ErrorCodes.aiDisabled || ErrorCodes.aiDisabledByUser => const AiErrorCopy(
      title: 'Writing tools aren’t available',
      message: 'They aren’t enabled for your account right now.',
      canRetry: false,
    ),
    ErrorCodes.aiFeatureDisabled => const AiErrorCopy(
      title: 'Not available yet',
      message: 'This tool isn’t enabled for you yet.',
      canRetry: false,
    ),
    // The fallback, for a caller that names no feature — a surface whose allowance
    // this file cannot identify says less rather than guessing the wrong window.
    ErrorCodes.aiUsageLimitExceeded ||
    ErrorCodes.quotaExceeded => const AiErrorCopy(
      title: 'You’ve used your allowance',
      message:
          'Your allowance resets at the start of the next period. Your writing is unaffected.',
      canRetry: false,
    ),
    // Not a spent allowance — a plan that does not include this capability at all.
    // Neither resets on its own, so the remedy is a plan rather than waiting.
    //
    // `INSUFFICIENT_CREDITS` shares the arm and is now UNREACHABLE: B4 deleted the
    // balance that could be insufficient. It stays mapped anyway, because an unmapped
    // code falls through to the generic retryable failure — so a server still emitting
    // it would tell a blocked writer to try again forever. Cheap insurance; it leaves
    // with the code in Phase V.
    ErrorCodes.entitlementDenied ||
    ErrorCodes.insufficientCredits => const AiErrorCopy(
      title: 'This needs a paid plan',
      message:
          'Your plan doesn’t include this. Your writing is unaffected — everything else works as usual.',
      canRetry: false,
      canUpgrade: true,
    ),
    // These three name a PROVIDER failure, and the writer's remedy is the same in all
    // of them: wait. Saying which vendor broke, or that a vendor exists at all, tells
    // them nothing they can act on — and D5's whole point is that the machinery is not
    // the product. `ModelDisclosureNote` is where the fact is stated, once, on purpose.
    ErrorCodes.aiProviderNotConfigured => const AiErrorCopy(
      title: 'Not set up yet',
      message: 'Writing tools aren’t configured here. Please try again later.',
      canRetry: false,
    ),
    ErrorCodes.aiProviderError ||
    ErrorCodes.aiProviderUnavailable => const AiErrorCopy(
      title: 'Unavailable right now',
      message: 'The writing tools had a problem. Please try again.',
      canRetry: true,
    ),
    ErrorCodes.aiContextTooLarge => const AiErrorCopy(
      title: 'That’s a lot of text',
      message:
          'Your text is too long for one request. Select a smaller passage and try again.',
      canRetry: false,
    ),
    ErrorCodes.aiInputTooLong => const AiErrorCopy(
      title: 'That’s a lot of text',
      message: 'The passage is too long. Try a shorter selection.',
      canRetry: false,
    ),
    ErrorCodes.aiInputBlocked ||
    ErrorCodes.aiOutputBlocked => const AiErrorCopy(
      title: 'Couldn’t complete that',
      message:
          'The request was blocked by the safety filter. Try rephrasing your text.',
      canRetry: false,
    ),
    ErrorCodes.aiTimeout => const AiErrorCopy(
      title: 'That took too long',
      message: 'That took longer than expected. Please try again.',
      canRetry: true,
    ),
    ErrorCodes.aiRequestCancelled => const AiErrorCopy(
      title: 'Cancelled',
      message: 'The request was cancelled.',
      canRetry: true,
    ),
    ErrorCodes.apiOffline => const AiErrorCopy(
      title: 'You’re offline',
      message: 'Writing tools need a connection. Reconnect and try again.',
      canRetry: true,
    ),
    ErrorCodes.rateLimited => const AiErrorCopy(
      title: 'Slow down a moment',
      message: 'Too many requests. Wait a few seconds and try again.',
      canRetry: true,
    ),
    // ── Search + recommendations ─────────────────────────────────────────
    ErrorCodes.retrievalQueryInvalid => const AiErrorCopy(
      title: 'Search needs a little more',
      message: 'Type a few more characters and try again.',
      canRetry: false,
    ),
    ErrorCodes.retrievalFailed ||
    ErrorCodes.recommendationUnavailable => const AiErrorCopy(
      title: 'Search is catching its breath',
      message:
          'Discovery is briefly unavailable. Please try again in a moment.',
      canRetry: true,
    ),
    ErrorCodes.retrievalTimeout => const AiErrorCopy(
      title: 'That took too long',
      message: 'Try a narrower query.',
      canRetry: true,
    ),
    // **D5 rewrote this one for a reason beyond branding.** It said "Analyse this story
    // first" at a time when NO client could analyse anything (48 §3.22d) — an
    // instruction with no control behind it anywhere in the app. "Map this story" is
    // that control, so the sentence finally names something the writer can do.
    ErrorCodes.storyNotFound => const AiErrorCopy(
      title: 'Nothing mapped yet',
      message: 'Open this story in the editor and choose “Map this story”.',
      canRetry: false,
    ),
    ErrorCodes.savedSearchLimitExceeded => const AiErrorCopy(
      title: 'Saved searches are full',
      message: 'Remove a saved search to add a new one.',
      canRetry: false,
    ),
    ErrorCodes.savedSearchNotFound => const AiErrorCopy(
      title: 'Saved search not found',
      message: 'It may have already been removed.',
      canRetry: false,
    ),
    _ => const AiErrorCopy(
      title: 'Something went wrong',
      message: 'The request failed. Please try again.',
      canRetry: true,
    ),
  };
}

/// One allowance's words. Private: the mapping above is the only sanctioned reader.
class _Allowance {
  const _Allowance({
    required this.when,
    required this.noun,
    required this.resets,
  });

  final String when;
  final String noun;
  final String resets;
}

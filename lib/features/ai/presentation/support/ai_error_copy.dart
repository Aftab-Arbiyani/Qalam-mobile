/// Human, honest copy for AI error codes (AF2) — the streaming path surfaces a
/// stable `ERROR_CODES` string (not a [Failure]), so this maps each to a friendly
/// title/message and whether a retry can help (Provider Failure, Timeout, Quota,
/// Safety, Context Too Large, Network, …). Never shows a raw code or message.
///
/// **A spent allowance and a denied entitlement are not the same wall (AF5, docs/48
/// §5.2).** Every AI request meters through the `AI_USAGE_METER` hook, and
/// `AiUsageMeterService.checkQuota` can refuse it two ways: `assertAllowed(ai_budget)`
/// fails when the plan grants no AI budget at all, and `assertWithinQuota` fails when
/// the budget is spent. The remedies diverge completely — an allowance resets on its own
/// and waiting is enough; a denied entitlement never resets and only a plan changes it.
/// `ENTITLEMENT_DENIED` and `INSUFFICIENT_CREDITS` were unmapped here, so both fell
/// through to the generic retryable failure, which told a blocked writer to try again
/// and then to wait for a reset that would never help. They now carry [canUpgrade].
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

  /// The copy for a failed AI request, optionally narrowed by WHICH AI feature failed.
  ///
  /// **D3 (`platfrom/docs/45` §4 row D3, `docs/48` §6.13).** `ENTITLEMENT_DENIED` now has two
  /// readings and they lead to different places, so the feature decides which: a denial on a
  /// surface sold behind `ai_writing` is about writing, while a denial anywhere else is about
  /// the AI allowance. It reads [premiumCodeFor] — the same map the server gated on — rather
  /// than the 402's `details`, so the copy cannot drift from the decision.
  ///
  /// [feature] is optional and defaults to the pre-D3 behaviour, which is what the AF4
  /// surfaces want: their denial IS an allowance denial.
  static AiErrorCopy forCode(String? code, {String? feature}) {
    if (code == ErrorCodes.entitlementDenied &&
        premiumCodeFor(feature) == PremiumFeature.aiWriting) {
      return aiWritingLocked;
    }
    return _forCode(code);
  }

  /// D3's remedy, and the FOURTH distinct one. There are now four ways AI can be off and each
  /// has a different fix: an admin turned it off (wait), the writer turned it off (turn it back
  /// on), the allowance is spent (wait or top up), and this one — writing is a paid capability
  /// (change plan). Conflating any two is the W4 defect recorded in `docs/48` §3.6.
  ///
  /// Deliberately says AI WRITING and names the tier, and deliberately does NOT mention the
  /// allowance: the free tier KEEPS `ai_budget`, so a free writer can still use AI search and
  /// Ask My Book. Telling them their plan has no AI allowance would be false as well as the
  /// wrong remedy.
  static const AiErrorCopy aiWritingLocked = AiErrorCopy(
    title: 'AI writing is on Plus and above',
    message:
        'Your plan doesn’t include AI writing. Your drafts are unaffected — the editor, search and Ask my book all work as usual.',
    canRetry: false,
    canUpgrade: true,
  );

  static AiErrorCopy _forCode(String? code) => switch (code) {
    ErrorCodes.aiDisabled => const AiErrorCopy(
      title: 'AI is turned off',
      message: 'AI features aren’t available on your account right now.',
      canRetry: false,
    ),
    ErrorCodes.aiFeatureDisabled => const AiErrorCopy(
      title: 'Not available yet',
      message: 'This AI feature isn’t enabled for you yet.',
      canRetry: false,
    ),
    // B5 (`platfrom/docs/45` §4.10). Same wall as [aiDisabled], completely different
    // sentence: that one is an administrator's switch and the writer can only wait,
    // this one is their own and is one screen away. Folding it into [aiDisabled] would
    // tell a writer who turned AI off that it "isn't available on your account" — the
    // right-shaped wall with the wrong remedy, which is the W4 defect (docs/48 §3.6).
    ErrorCodes.aiDisabledByUser => const AiErrorCopy(
      title: 'You turned AI off',
      message:
          'AI is off for your account. Turn it back on in Settings › AI. Your writing is unaffected.',
      canRetry: false,
    ),
    // The AI module's own token cap and the monetization plan's cap are
    // indistinguishable to a writer, who only needs to know they are out of allowance
    // and that it comes back.
    ErrorCodes.aiUsageLimitExceeded ||
    ErrorCodes.quotaExceeded => const AiErrorCopy(
      title: 'You’ve used your AI allowance',
      message:
          'Your allowance resets at the start of the next period. Your writing is unaffected.',
      canRetry: false,
    ),
    // Not a spent allowance — a plan that grants no AI budget, or a credit balance that
    // cannot cover the request. Neither resets on its own, so the remedy is a plan.
    ErrorCodes.entitlementDenied ||
    ErrorCodes.insufficientCredits => const AiErrorCopy(
      title: 'This needs a paid plan',
      message:
          'Your plan doesn’t include an AI allowance. Your writing is unaffected — everything else works as usual.',
      canRetry: false,
      canUpgrade: true,
    ),
    ErrorCodes.aiProviderNotConfigured => const AiErrorCopy(
      title: 'AI isn’t set up',
      message: 'The AI provider isn’t configured. Please try again later.',
      canRetry: false,
    ),
    ErrorCodes.aiProviderError ||
    ErrorCodes.aiProviderUnavailable => const AiErrorCopy(
      title: 'The AI is unavailable',
      message: 'The AI service had a problem. Please try again.',
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
      message: 'The AI took too long to respond. Please try again.',
      canRetry: true,
    ),
    ErrorCodes.aiRequestCancelled => const AiErrorCopy(
      title: 'Cancelled',
      message: 'The generation was cancelled.',
      canRetry: true,
    ),
    ErrorCodes.apiOffline => const AiErrorCopy(
      title: 'You’re offline',
      message: 'AI needs a connection. Reconnect and try again.',
      canRetry: true,
    ),
    ErrorCodes.rateLimited => const AiErrorCopy(
      title: 'Slow down a moment',
      message: 'Too many requests. Wait a few seconds and try again.',
      canRetry: true,
    ),
    // ── AF4 — discovery / search / ask / recommendations ──────────────────
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
    ErrorCodes.storyNotFound => const AiErrorCopy(
      title: 'No story knowledge yet',
      message: 'Analyse this story first to explore or ask about it.',
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
      message: 'The AI request failed. Please try again.',
      canRetry: true,
    ),
  };
}

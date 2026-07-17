/// Human, honest copy for AI error codes (AF2) — the streaming path surfaces a
/// stable `ERROR_CODES` string (not a [Failure]), so this maps each to a friendly
/// title/message and whether a retry can help (Provider Failure, Timeout, Quota,
/// Safety, Context Too Large, Network, …). Never shows a raw code or message.
library;

import '../../../../shared/domain/error_codes.dart';

class AiErrorCopy {
  const AiErrorCopy({required this.title, required this.message, required this.canRetry});

  final String title;
  final String message;
  final bool canRetry;

  static AiErrorCopy forCode(String? code) => switch (code) {
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
        ErrorCodes.aiUsageLimitExceeded => const AiErrorCopy(
            title: 'You’ve hit your AI limit',
            message: 'You’ve used your AI quota for now. It refreshes soon — try again later.',
            canRetry: false,
          ),
        ErrorCodes.aiProviderNotConfigured => const AiErrorCopy(
            title: 'AI isn’t set up',
            message: 'The AI provider isn’t configured. Please try again later.',
            canRetry: false,
          ),
        ErrorCodes.aiProviderError ||
        ErrorCodes.aiProviderUnavailable =>
          const AiErrorCopy(
            title: 'The AI is unavailable',
            message: 'The AI service had a problem. Please try again.',
            canRetry: true,
          ),
        ErrorCodes.aiContextTooLarge => const AiErrorCopy(
            title: 'That’s a lot of text',
            message: 'Your text is too long for one request. Select a smaller passage and try again.',
            canRetry: false,
          ),
        ErrorCodes.aiInputTooLong => const AiErrorCopy(
            title: 'That’s a lot of text',
            message: 'The passage is too long. Try a shorter selection.',
            canRetry: false,
          ),
        ErrorCodes.aiInputBlocked || ErrorCodes.aiOutputBlocked => const AiErrorCopy(
            title: 'Couldn’t complete that',
            message: 'The request was blocked by the safety filter. Try rephrasing your text.',
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
        _ => const AiErrorCopy(
            title: 'Something went wrong',
            message: 'The AI request failed. Please try again.',
            canRetry: true,
          ),
      };
}

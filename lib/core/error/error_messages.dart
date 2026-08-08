/// User-facing error copy — the error catalog (docs/40 §21.3, §32).
///
/// Copy is keyed by [Failure] type / `error.code`, never taken from
/// `error.message` (developer-facing). English is the M1 catalog; localization
/// layers over this presenter without changing call sites (docs/40 §29,
/// "Localization"). Voice: calm, literary, non-blaming, no exclamation marks.
library;

import '../../shared/domain/error_codes.dart';
import 'failure.dart';

/// A presentable title + body for an error surface.
typedef ErrorCopy = ({String title, String body});

abstract final class ErrorMessages {
  static const ErrorCopy _generic = (
    title: 'Something went wrong.',
    body: "We couldn't complete that just now. Please try again.",
  );

  /// Per-code overrides for the handful of codes worth a tailored line.
  static const Map<String, ErrorCopy> _byCode = <String, ErrorCopy>{
    ErrorCodes.apiOffline: (
      title: "You're offline.",
      body: 'Check your connection and try again.',
    ),
    ErrorCodes.apiTimeout: (
      title: 'That took too long.',
      body: 'The connection timed out. Please try again.',
    ),
    ErrorCodes.searchUnavailable: (
      title: 'Search is catching its breath.',
      body: 'Give it a moment, then try again.',
    ),
    ErrorCodes.rateLimited: (
      title: 'A little too fast.',
      body: 'Please slow down for a moment.',
    ),
    ErrorCodes.authAccountSuspended: (
      title: 'Account unavailable.',
      body: 'This account has been suspended.',
    ),
    ErrorCodes.authInvalidCredentials: (
      title: "We couldn't sign you in.",
      body: 'Check your email and password, then try again.',
    ),
    ErrorCodes.authEmailUnverified: (
      title: 'Please verify your email first.',
      body: 'Check your inbox for the verification link.',
    ),
    // B4 (docs/45 §4.9). Says nothing about waiting: unlike a spent AI allowance, a
    // piece cap never resets, so the remedies are delete or upgrade (docs/48 §3.6).
    ErrorCodes.pieceLimitReached: (
      title: 'Your plan’s piece limit is full.',
      body: 'Delete a piece to free a slot, or move to a larger plan.',
    ),
  };

  /// Resolve copy for a [Failure]. Prefers a per-code override, then a per-kind
  /// default, then the generic fallback.
  static ErrorCopy of(Failure failure) {
    final ErrorCopy? byCode = _byCode[_codeOf(failure)];
    if (byCode != null) return byCode;

    return switch (failure) {
      NetworkFailure(isOffline: final bool offline) =>
        offline
            ? _byCode[ErrorCodes.apiOffline]!
            : (
                title: "Can't reach Qalam.",
                body: 'Please check your connection and try again.',
              ),
      AuthFailure() => (
        title: 'Your session ended.',
        body: 'Please sign in again to continue.',
      ),
      PermissionFailure() => (
        title: 'Not allowed.',
        body: "You don't have access to that.",
      ),
      NotFoundFailure() => (
        title: 'Not found.',
        body: 'That page has wandered off.',
      ),
      ValidationFailure() => (
        title: 'Check your details.',
        body: 'Some fields need another look.',
      ),
      ConflictFailure() => (
        title: 'That already exists.',
        body: 'This action conflicts with the current state.',
      ),
      DomainRuleFailure() => (
        title: "That can't be done.",
        body: 'This action is not allowed right now.',
      ),
      RateLimitFailure() => _byCode[ErrorCodes.rateLimited]!,
      UnexpectedFailure() => _generic,
    };
  }

  static String _codeOf(Failure failure) => switch (failure) {
    NetworkFailure(:final String code) => code,
    AuthFailure(:final String code) => code,
    PermissionFailure(:final String code) => code,
    NotFoundFailure(:final String code) => code,
    ValidationFailure(:final String code) => code,
    ConflictFailure(:final String code) => code,
    DomainRuleFailure(:final String code) => code,
    RateLimitFailure(:final String code) => code,
    UnexpectedFailure(:final String code) => code,
  };
}

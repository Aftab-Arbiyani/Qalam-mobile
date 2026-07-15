/// Domain-facing errors (docs/40 §21.1). A sealed union the presentation layer
/// pattern-matches exhaustively to render the right error/empty/offline state.
///
/// Repositories return `Failure`s; widgets never see an `ApiException` or a
/// `DioException`. Copy is resolved from [code] via the error catalog, never from
/// [message] (which is developer-facing).
library;

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../shared/api/api_envelope.dart';

part 'failure.freezed.dart';

@freezed
sealed class Failure with _$Failure {
  /// Transport problems — offline, timeout, server unreachable, cancellation.
  const factory Failure.network({
    required String code,
    @Default('') String message,
    @Default(false) bool isOffline,
  }) = NetworkFailure;

  /// 401 with an auth code that is not a recoverable expiry.
  const factory Failure.auth({
    required String code,
    @Default('') String message,
  }) = AuthFailure;

  /// 403 — identity known, action denied. Never retried.
  const factory Failure.permission({
    required String code,
    @Default('') String message,
  }) = PermissionFailure;

  /// 404 — absent or invisible to the viewer.
  const factory Failure.notFound({
    required String code,
    @Default('') String message,
  }) = NotFoundFailure;

  /// 400 `VALIDATION_FAILED` — carries field-level issues for form mapping.
  const factory Failure.validation({
    required String code,
    @Default('') String message,
    @Default(<FieldError>[]) List<FieldError> fieldErrors,
  }) = ValidationFailure;

  /// 409 — state conflict (duplicate, already-published, …).
  const factory Failure.conflict({
    required String code,
    @Default('') String message,
  }) = ConflictFailure;

  /// 422 — valid shape, domain rule violated (schedule in past, clap cap, …).
  const factory Failure.domainRule({
    required String code,
    @Default('') String message,
  }) = DomainRuleFailure;

  /// 429 — rate limited; [retryAfter] from the `Retry-After` header.
  const factory Failure.rateLimit({
    required String code,
    @Default('') String message,
    Duration? retryAfter,
  }) = RateLimitFailure;

  /// 500 / malformed / anything unmapped. [requestId] aids support.
  const factory Failure.unexpected({
    required String code,
    @Default('') String message,
    String? requestId,
  }) = UnexpectedFailure;
}

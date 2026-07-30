/// The transport/wire error thrown by the network layer (docs/40 §13.4, §21.1).
///
/// A single exception type carrying the frozen envelope's `error` fields plus the
/// HTTP status. `status == 0` denotes a transport failure (offline/network).
/// Consumers branch on [code], never on [message]. This type does NOT escape the
/// data layer — repositories translate it to a `Failure`.
library;

import '../../shared/api/api_envelope.dart';
import '../../shared/domain/error_codes.dart';

class ApiException implements Exception {
  const ApiException({
    required this.code,
    required this.status,
    this.message = '',
    this.details = const <Object?>[],
    this.requestId,
  });

  /// A stable [ErrorCodes] string (server code or a client-synthesized one).
  final String code;

  /// HTTP status, or 0 for transport-level failures (offline/network/cancel).
  final int status;

  /// Human-readable; developer-facing. Never shown to users directly.
  final String message;

  /// Structured context — for `VALIDATION_FAILED`, field-level issues.
  final List<Object?> details;

  /// Correlation id echoed from the failed response (`x-request-id`).
  final String? requestId;

  bool get isTransport => status == 0;
  bool get isOffline => code == ErrorCodes.apiOffline;
  bool get isCancelled => code == ErrorCodes.apiCancelled;

  /// Field-level validation issues, parsed from [details] when present.
  List<FieldError> get fieldErrors => details
      .whereType<Map<String, dynamic>>()
      .map(FieldError.fromJson)
      .toList(growable: false);

  @override
  String toString() =>
      'ApiException(code: $code, status: $status, requestId: $requestId, message: $message)';
}

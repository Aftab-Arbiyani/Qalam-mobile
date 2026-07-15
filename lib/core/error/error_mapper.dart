/// Maps a transport [ApiException] to a domain [Failure] (docs/40 §22).
///
/// This is the SINGLE place HTTP status + `error.code` are interpreted. Nowhere
/// else in the app branches on status codes. Repositories call this in their
/// catch blocks.
library;

import '../../shared/domain/error_codes.dart';
import 'api_exception.dart';
import 'failure.dart';

Failure mapApiExceptionToFailure(ApiException e) {
  // Transport-level (status 0) and explicit timeout.
  if (e.isCancelled) {
    return Failure.network(code: e.code, message: e.message);
  }
  if (e.isTransport || e.status == 408) {
    return Failure.network(
      code: e.code,
      message: e.message,
      isOffline: e.isOffline,
    );
  }

  switch (e.status) {
    case 400:
      return Failure.validation(
        code: e.code,
        message: e.message,
        fieldErrors: e.fieldErrors,
      );
    case 401:
      // AUTH_TOKEN_EXPIRED is handled by the refresh flow before reaching here;
      // any 401 that surfaces is a terminal auth failure.
      return Failure.auth(code: e.code, message: e.message);
    case 403:
      return Failure.permission(code: e.code, message: e.message);
    case 404:
    case 410:
      return Failure.notFound(code: e.code, message: e.message);
    case 409:
      return Failure.conflict(code: e.code, message: e.message);
    case 413:
    case 415:
    case 422:
      return Failure.domainRule(code: e.code, message: e.message);
    case 429:
      return Failure.rateLimit(code: e.code, message: e.message);
    case 503:
      return Failure.network(code: e.code, message: e.message);
    default:
      if (e.code == ErrorCodes.validationFailed) {
        return Failure.validation(
          code: e.code,
          message: e.message,
          fieldErrors: e.fieldErrors,
        );
      }
      return Failure.unexpected(
        code: e.code,
        message: e.message,
        requestId: e.requestId,
      );
  }
}

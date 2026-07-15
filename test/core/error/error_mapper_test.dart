import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/core/error/api_exception.dart';
import 'package:qalam_mobile/core/error/error_mapper.dart';
import 'package:qalam_mobile/core/error/failure.dart';
import 'package:qalam_mobile/shared/domain/error_codes.dart';

void main() {
  group('mapApiExceptionToFailure', () {
    ApiException ex(int status, String code) =>
        ApiException(code: code, status: status);

    test('maps by HTTP status to the right Failure', () {
      expect(
        mapApiExceptionToFailure(ex(400, ErrorCodes.validationFailed)),
        isA<ValidationFailure>(),
      );
      expect(
        mapApiExceptionToFailure(ex(401, ErrorCodes.authTokenInvalid)),
        isA<AuthFailure>(),
      );
      expect(
        mapApiExceptionToFailure(ex(403, ErrorCodes.forbidden)),
        isA<PermissionFailure>(),
      );
      expect(
        mapApiExceptionToFailure(ex(404, ErrorCodes.pieceNotFound)),
        isA<NotFoundFailure>(),
      );
      expect(
        mapApiExceptionToFailure(ex(409, ErrorCodes.conflict)),
        isA<ConflictFailure>(),
      );
      expect(
        mapApiExceptionToFailure(ex(422, ErrorCodes.clapLimitReached)),
        isA<DomainRuleFailure>(),
      );
      expect(
        mapApiExceptionToFailure(ex(429, ErrorCodes.rateLimited)),
        isA<RateLimitFailure>(),
      );
      expect(
        mapApiExceptionToFailure(ex(500, ErrorCodes.internalServerError)),
        isA<UnexpectedFailure>(),
      );
      expect(
        mapApiExceptionToFailure(ex(503, ErrorCodes.searchUnavailable)),
        isA<NetworkFailure>(),
      );
    });

    test('transport (status 0) maps to a NetworkFailure, offline flagged', () {
      final Failure offline = mapApiExceptionToFailure(
        const ApiException(code: ErrorCodes.apiOffline, status: 0),
      );
      expect(offline, isA<NetworkFailure>());
      expect((offline as NetworkFailure).isOffline, isTrue);
    });

    test('validation failure carries the code', () {
      final Failure f = mapApiExceptionToFailure(
        ex(400, ErrorCodes.validationFailed),
      );
      expect((f as ValidationFailure).code, ErrorCodes.validationFailed);
    });
  });
}

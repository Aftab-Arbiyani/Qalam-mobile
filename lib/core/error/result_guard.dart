/// The single ApiException→Failure guard for uncached repository calls
/// (docs/40 §16.2, §22). Repositories wrap remote calls in [guardResult] /
/// [guardUnit] instead of hand-rolling the same try/catch per method, so error
/// translation lives in one place.
library;

import '../../shared/domain/error_codes.dart';
import '../utils/result.dart';
import '../utils/typedefs.dart';
import 'api_exception.dart';
import 'error_mapper.dart';
import 'failure.dart';

/// Run [op], mapping an [ApiException] to a domain [Failure] and anything else
/// to [Failure.unexpected].
Future<Result<T>> guardResult<T>(Future<T> Function() op) async {
  try {
    return Ok<T>(await op());
  } on ApiException catch (e) {
    return Err<T>(mapApiExceptionToFailure(e));
  } on Object catch (e) {
    return Err<T>(
      Failure.unexpected(code: ErrorCodes.apiUnexpected, message: e.toString()),
    );
  }
}

/// [guardResult] for operations that succeed without a payload.
Future<Result<Unit>> guardUnit(Future<void> Function() op) =>
    guardResult<Unit>(() async {
      await op();
      return unit;
    });

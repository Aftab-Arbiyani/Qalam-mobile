/// Auth repository implementation (docs/40 §16, §21). Orchestrates the remote data
/// source and translates every transport failure into a domain [Failure] — an
/// [ApiException] via the single `core/error` mapping, any other error (e.g. a
/// malformed success body) into an `UnexpectedFailure`. No DTO, `DioException`, or
/// HTTP status ever escapes upward.
library;

import '../../../../core/error/api_exception.dart';
import '../../../../core/error/error_mapper.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/utils/result.dart';
import '../../../../core/utils/typedefs.dart';
import '../../../../shared/domain/error_codes.dart';
import '../../domain/entities/auth_result.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._remote);

  final AuthRemoteDataSource _remote;

  @override
  Future<Result<AuthResult>> login({
    required String email,
    required String password,
  }) => _guard(() => _remote.login(email: email, password: password));

  @override
  Future<Result<AuthResult>> register({
    required String email,
    required String username,
    required String password,
  }) => _guard(
    () =>
        _remote.register(email: email, username: username, password: password),
  );

  @override
  Future<Result<Unit>> requestPasswordReset({required String email}) =>
      _guardUnit(() => _remote.requestPasswordReset(email: email));

  @override
  Future<Result<Unit>> resetPassword({
    required String token,
    required String newPassword,
  }) => _guardUnit(
    () => _remote.resetPassword(token: token, newPassword: newPassword),
  );

  @override
  Future<Result<Unit>> verifyEmail({required String token}) =>
      _guardUnit(() => _remote.verifyEmail(token: token));

  @override
  Future<Result<Unit>> resendVerification() =>
      _guardUnit(_remote.resendVerification);

  @override
  Future<Result<Unit>> logout() => _guardUnit(_remote.logout);

  @override
  Future<Result<Unit>> logoutAll() => _guardUnit(_remote.logoutAll);

  @override
  Future<Result<AuthResult>> exchangeSocialCode({required String code}) =>
      _guard(() => _remote.exchangeSocialCode(code: code));

  Future<Result<T>> _guard<T>(Future<T> Function() run) async {
    try {
      return Ok<T>(await run());
    } on ApiException catch (e) {
      return Err<T>(mapApiExceptionToFailure(e));
    } catch (e) {
      return Err<T>(
        Failure.unexpected(
          code: ErrorCodes.apiUnexpected,
          message: e.toString(),
        ),
      );
    }
  }

  Future<Result<Unit>> _guardUnit(Future<void> Function() run) =>
      _guard<Unit>(() async {
        await run();
        return unit;
      });
}

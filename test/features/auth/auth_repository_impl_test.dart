import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:qalam_mobile/core/error/api_exception.dart';
import 'package:qalam_mobile/core/error/failure.dart';
import 'package:qalam_mobile/core/session/current_user.dart';
import 'package:qalam_mobile/core/utils/result.dart';
import 'package:qalam_mobile/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:qalam_mobile/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:qalam_mobile/features/auth/domain/entities/auth_result.dart';
import 'package:qalam_mobile/shared/domain/error_codes.dart';

class MockRemote extends Mock implements AuthRemoteDataSource {}

void main() {
  late MockRemote remote;
  late AuthRepositoryImpl repo;

  const AuthResult ok = AuthResult(
    accessToken: 'at',
    refreshToken: 'rt',
    user: CurrentUser(
      id: 'u1',
      email: 'w@q.test',
      username: 'writer',
      isEmailVerified: false,
    ),
  );

  setUp(() {
    remote = MockRemote();
    repo = AuthRepositoryImpl(remote);
  });

  test('login success → Ok(AuthResult)', () async {
    when(
      () => remote.login(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => ok);
    final Result<AuthResult> result = await repo.login(
      email: 'w@q.test',
      password: 'secret1234',
    );
    expect(result, isA<Ok<AuthResult>>());
    expect(result.valueOrNull?.accessToken, 'at');
  });

  test(
    'login ApiException(401 invalid credentials) → Err(AuthFailure)',
    () async {
      when(
        () => remote.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(
        const ApiException(
          code: ErrorCodes.authInvalidCredentials,
          status: 401,
        ),
      );
      final Result<AuthResult> result = await repo.login(
        email: 'w@q.test',
        password: 'x',
      );
      expect(result.failureOrNull, isA<AuthFailure>());
      expect(
        (result.failureOrNull! as AuthFailure).code,
        ErrorCodes.authInvalidCredentials,
      );
    },
  );

  test(
    'register ApiException(409 email taken) → Err(ConflictFailure)',
    () async {
      when(
        () => remote.register(
          email: any(named: 'email'),
          username: any(named: 'username'),
          password: any(named: 'password'),
        ),
      ).thenThrow(
        const ApiException(code: ErrorCodes.authEmailTaken, status: 409),
      );
      final Result<AuthResult> result = await repo.register(
        email: 'w@q.test',
        username: 'writer',
        password: 'secret1234',
      );
      expect(result.failureOrNull, isA<ConflictFailure>());
    },
  );

  test(
    'a non-ApiException (malformed body) → Err(UnexpectedFailure)',
    () async {
      when(
        () => remote.exchangeSocialCode(code: any(named: 'code')),
      ).thenThrow(const FormatException('boom'));
      final Result<AuthResult> result = await repo.exchangeSocialCode(
        code: 'c',
      );
      expect(result.failureOrNull, isA<UnexpectedFailure>());
    },
  );

  test('logout returns Ok(unit) on success', () async {
    when(remote.logout).thenAnswer((_) async {});
    final result = await repo.logout();
    expect(result.isOk, isTrue);
  });
}

/// A configurable [AuthRepository] test double. By default every call succeeds
/// (returning a canned [AuthResult]); set [failure] to make them fail, and inspect
/// the recorded call counters. Faking at this seam keeps notifier/flow tests off
/// the network (docs/40 §38.4 — mock the boundary you own).
library;

import 'package:qalam_mobile/core/error/failure.dart';
import 'package:qalam_mobile/core/session/current_user.dart';
import 'package:qalam_mobile/core/utils/result.dart';
import 'package:qalam_mobile/core/utils/typedefs.dart';
import 'package:qalam_mobile/features/auth/domain/entities/auth_result.dart';
import 'package:qalam_mobile/features/auth/domain/repositories/auth_repository.dart';

const CurrentUser kFakeUser = CurrentUser(
  id: 'user-1',
  email: 'writer@qalam.test',
  username: 'writer',
  isEmailVerified: false,
);

const AuthResult kFakeAuthResult = AuthResult(
  accessToken: 'fake-access-token',
  refreshToken: 'fake-refresh-token',
  user: kFakeUser,
);

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.authResult = kFakeAuthResult, this.failure});

  AuthResult authResult;
  Failure? failure;

  int loginCalls = 0;
  int registerCalls = 0;
  int forgotCalls = 0;
  int resetCalls = 0;
  int verifyCalls = 0;
  int resendCalls = 0;
  int logoutCalls = 0;
  int logoutAllCalls = 0;
  int exchangeCalls = 0;

  Result<AuthResult> get _auth =>
      failure != null ? Err<AuthResult>(failure!) : Ok<AuthResult>(authResult);
  Result<Unit> get _unit =>
      failure != null ? Err<Unit>(failure!) : const Ok<Unit>(unit);

  @override
  Future<Result<AuthResult>> login({
    required String email,
    required String password,
  }) async {
    loginCalls++;
    return _auth;
  }

  @override
  Future<Result<AuthResult>> register({
    required String email,
    required String username,
    required String password,
  }) async {
    registerCalls++;
    return _auth;
  }

  @override
  Future<Result<Unit>> requestPasswordReset({required String email}) async {
    forgotCalls++;
    return _unit;
  }

  @override
  Future<Result<Unit>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    resetCalls++;
    return _unit;
  }

  @override
  Future<Result<Unit>> verifyEmail({required String token}) async {
    verifyCalls++;
    return _unit;
  }

  @override
  Future<Result<Unit>> resendVerification() async {
    resendCalls++;
    return _unit;
  }

  @override
  Future<Result<Unit>> logout() async {
    logoutCalls++;
    return _unit;
  }

  @override
  Future<Result<Unit>> logoutAll() async {
    logoutAllCalls++;
    return _unit;
  }

  @override
  Future<Result<AuthResult>> exchangeSocialCode({required String code}) async {
    exchangeCalls++;
    return _auth;
  }
}

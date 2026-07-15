/// Session tri-state (docs/40 §8.5) — the single source route guards read.
///
/// Holds session UI facts only (status + role hint + email-verified), NOT the
/// full user profile (that is a separate server-state provider). `unknown` means
/// the boot restore is still in flight — guards show a skeleton, never a redirect
/// (docs/40 §11.2), which prevents the false-bounce-on-cold-start bug.
library;

import '../../shared/domain/enums.dart';

enum SessionStatus { unknown, authenticated, anonymous }

class SessionState {
  const SessionState._(this.status, {this.role, this.isEmailVerified});

  const SessionState.unknown() : this._(SessionStatus.unknown);

  const SessionState.anonymous() : this._(SessionStatus.anonymous);

  const SessionState.authenticated({required Role role, bool? isEmailVerified})
    : this._(
        SessionStatus.authenticated,
        role: role,
        isEmailVerified: isEmailVerified,
      );

  final SessionStatus status;
  final Role? role;
  final bool? isEmailVerified;

  bool get isAuthenticated => status == SessionStatus.authenticated;
  bool get isAnonymous => status == SessionStatus.anonymous;
  bool get isUnknown => status == SessionStatus.unknown;

  @override
  bool operator ==(Object other) =>
      other is SessionState &&
      other.status == status &&
      other.role == role &&
      other.isEmailVerified == isEmailVerified;

  @override
  int get hashCode => Object.hash(status, role, isEmailVerified);
}

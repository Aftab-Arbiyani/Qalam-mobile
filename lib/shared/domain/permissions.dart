/// PBAC vocabulary — a Dart mirror of `@qalam/shared` `permissions.ts`.
///
/// The client resolves a user's effective permissions from the JWT `role` claim
/// (via [defaultRolePermissions]) and uses [permissionSatisfies] purely to gate
/// UI affordances. The server re-checks every mutation and is authoritative
/// (docs/40 §11.4). The mobile reader/writer app needs almost none of this — it
/// exists so a future moderator affordance gates correctly with zero refactor.
library;

import 'enums.dart';

abstract final class Permissions {
  static const String wildcard = '*';

  static const String userView = 'user.view';
  static const String userUpdate = 'user.update';
  static const String profileUpdate = 'profile.update';
  static const String pieceCreate = 'piece.create';
  static const String pieceUpdate = 'piece.update';
  static const String piecePublish = 'piece.publish';
  static const String pieceArchive = 'piece.archive';
  static const String pieceDelete = 'piece.delete';
  static const String pieceFeature = 'piece.feature';
  static const String commentCreate = 'comment.create';
  static const String commentDelete = 'comment.delete';
  static const String commentLock = 'comment.lock';
  static const String clapCreate = 'clap.create';
  static const String bookmarkManage = 'bookmark.manage';
  static const String collectionManage = 'collection.manage';
  static const String reportReview = 'report.review';
  static const String reportResolve = 'report.resolve';
  static const String analyticsView = 'analytics.view';
  static const String adminDashboard = 'admin.dashboard';
}

/// Default grants per role — mirrors `DEFAULT_ROLE_PERMISSIONS`. Grants are
/// incremental (a role inherits every lower-ranked role's grants); wildcards
/// (`module.*`, `*`) are grant shortcuts, matched by [permissionSatisfies].
const Map<Role, List<String>> defaultRolePermissions = <Role, List<String>>{
  Role.superAdmin: <String>[Permissions.wildcard],
  Role.admin: <String>[
    'user.*',
    'profile.*',
    'piece.*',
    'comment.*',
    'report.*',
    'settings.*',
    'taxonomy.*',
    'notification.manage',
    Permissions.analyticsView,
    Permissions.adminDashboard,
  ],
  Role.moderator: <String>[
    Permissions.reportReview,
    Permissions.reportResolve,
    Permissions.pieceArchive,
    Permissions.pieceFeature,
    Permissions.commentDelete,
    Permissions.commentLock,
  ],
  Role.user: <String>[
    Permissions.profileUpdate,
    Permissions.pieceCreate,
    Permissions.pieceUpdate,
    Permissions.piecePublish,
    Permissions.pieceArchive,
    Permissions.pieceDelete,
    Permissions.commentCreate,
    Permissions.clapCreate,
    Permissions.bookmarkManage,
    Permissions.collectionManage,
  ],
};

/// Whether [granted] satisfies [required], honoring wildcards
/// (`*` matches anything; `a.*` matches `a.x`; exact matches exact). Pure —
/// mirrors the backend guard matcher so client gating and server agree.
bool permissionSatisfies(Set<String> granted, String required) {
  if (granted.contains(Permissions.wildcard) || granted.contains(required)) {
    return true;
  }
  final List<String> parts = required.split('.');
  for (int i = parts.length - 1; i >= 1; i--) {
    if (granted.contains('${parts.sublist(0, i).join('.')}.*')) {
      return true;
    }
  }
  return false;
}

/// Effective permissions for a role = union of its grants and every lower-ranked
/// role's grants (rank inheritance).
Set<String> effectivePermissions(Role role) {
  final Set<String> result = <String>{};
  for (final Role r in Role.values) {
    if (r.rank <= role.rank) {
      result.addAll(defaultRolePermissions[r] ?? const <String>[]);
    }
  }
  return result;
}

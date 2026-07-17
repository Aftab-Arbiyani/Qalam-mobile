/// Profile-update handler for the unified sync engine (docs/40 §23) — the
/// "Queued Profile Updates" surface. A profile edit made offline is queued as ONE
/// [SyncOperation] (deduped on the sentinel `me`, since there is a single current
/// user); a second offline edit merges its set fields onto the queued one, so
/// editing bio then privacy offline replays as a single combined `PATCH /me`.
/// Reconciles through the SAME [ProfileRepository] the online path uses.
library;

import '../../../../core/sync/sync_handler.dart';
import '../../../../core/sync/sync_operation.dart';
import '../../../../core/utils/typedefs.dart';
import '../../domain/repositories/profile_repository.dart';
import '../../domain/value_objects/profile_edit.dart';

/// The [SyncOperation.type] for a queued profile update.
const String kProfileOpType = 'profile.update';

/// Dedup sentinel — there is one current user, so one pending profile edit.
const String kProfileSelfKey = 'me';

SyncOperation buildProfileOperation(ProfileEdit edit, {String? label}) {
  final DateTime now = DateTime.now();
  return SyncOperation(
    id: 'profile-${now.microsecondsSinceEpoch}',
    type: kProfileOpType,
    dedupKey: kProfileSelfKey,
    payload: edit.toJson(),
    createdAt: now,
    label: label,
  );
}

class ProfileSyncHandler implements SyncHandler {
  ProfileSyncHandler(this._repository);

  final ProfileRepository _repository;

  @override
  String get type => kProfileOpType;

  @override
  Future<SyncOutcome> reconcile(SyncOperation op) async {
    final ProfileEdit edit = ProfileEdit.fromJson(op.payload);
    final result = await _repository.updateProfile(edit);
    return syncOutcomeFromResult(result);
  }

  /// Accumulate set fields: incoming keys override, existing keys survive for keys
  /// the incoming edit did not touch (each stores only its non-null fields).
  @override
  SyncOperation? merge(SyncOperation incoming, SyncOperation existing) {
    final Json merged = <String, dynamic>{
      ...existing.payload,
      ...incoming.payload,
    };
    return SyncOperation(
      id: incoming.id,
      type: incoming.type,
      dedupKey: incoming.dedupKey,
      payload: merged,
      createdAt: incoming.createdAt,
      label: incoming.label,
    );
  }
}

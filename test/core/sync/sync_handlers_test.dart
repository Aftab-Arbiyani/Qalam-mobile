import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:qalam_mobile/core/sync/sync_operation.dart';
import 'package:qalam_mobile/features/notifications/data/sync/notification_sync_handler.dart';
import 'package:qalam_mobile/features/notifications/domain/repositories/notification_repository.dart';
import 'package:qalam_mobile/features/profile/data/sync/profile_sync_handler.dart';
import 'package:qalam_mobile/features/profile/domain/repositories/profile_repository.dart';
import 'package:qalam_mobile/features/profile/domain/value_objects/profile_edit.dart';
import 'package:qalam_mobile/shared/social/data/sync/social_sync_handler.dart';

class _MockNotifRepo extends Mock implements NotificationRepository {}

class _MockProfileRepo extends Mock implements ProfileRepository {}

void main() {
  group('social op builder', () {
    test('encodes type, dedup key and desired-state payload', () {
      final SyncOperation op = buildSocialOperation(
        category: SocialCategory.pieceBookmark,
        targetId: 'p9',
        desired: false,
      );
      expect(op.type, 'social.piece_bookmark');
      expect(op.dedupKey, 'p9');
      expect(op.payload['desired'], false);
      expect(op.storageKey, 'social.piece_bookmark::p9');
    });
  });

  group('notification handler merge (supersedes)', () {
    final NotificationSyncHandler handler = NotificationSyncHandler(
      _MockNotifRepo(),
    );

    SyncOperation forKind(NotificationActionKind kind) =>
        buildNotificationOperation(kind: kind, targetId: 'n1');

    test('a stronger action wins regardless of arrival order', () {
      final SyncOperation read = forKind(NotificationActionKind.read);
      final SyncOperation del = forKind(NotificationActionKind.delete);
      // delete arrives after read → delete wins.
      expect(
        handler.merge(del, read)!.payload['kind'],
        NotificationActionKind.delete.wire,
      );
      // read arrives after delete → delete still wins (no downgrade).
      expect(
        handler.merge(read, del)!.payload['kind'],
        NotificationActionKind.delete.wire,
      );
    });
  });

  group('profile handler merge (accumulate)', () {
    final ProfileSyncHandler handler = ProfileSyncHandler(_MockProfileRepo());

    test('two partial edits combine set fields into one op', () {
      final SyncOperation bioEdit = buildProfileOperation(
        const ProfileEdit(bio: 'hello'),
      );
      final SyncOperation privacyEdit = buildProfileOperation(
        const ProfileEdit.privacy(true),
      );
      final SyncOperation? merged = handler.merge(privacyEdit, bioEdit);
      expect(merged, isNotNull);
      expect(merged!.payload['bio'], 'hello'); // retained from the earlier edit
      expect(merged.payload['isPrivate'], true); // added by the newer edit
      expect(merged.dedupKey, kProfileSelfKey);
    });
  });
}

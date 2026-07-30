import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/features/notifications/domain/entities/app_notification.dart';
import 'package:qalam_mobile/features/notifications/presentation/navigation/notification_deep_link.dart';
import 'package:qalam_mobile/shared/domain/enums.dart';

import '../../support/fake_notifications.dart';

void main() {
  group('routeForNotification', () {
    test('follow → actor profile', () {
      final route = routeForNotification(notif(type: NotificationType.follow));
      expect(route, '/u/ali');
    });

    test('follow with no actor → null', () {
      final route = routeForNotification(
        notif(type: NotificationType.follow, actorUsername: null),
      );
      expect(route, isNull);
    });

    test('followRequest → follow-requests screen', () {
      expect(
        routeForNotification(notif(type: NotificationType.followRequest)),
        '/me/follow-requests',
      );
    });

    test('like on a piece → piece by UUID (entityId)', () {
      final route = routeForNotification(
        notif(
          type: NotificationType.like,
          entityType: NotificationEntityType.piece,
          entityId: 'p-uuid',
          payload: const NotificationPayload(pieceSlug: 'slug'),
        ),
      );
      expect(route, '/p/p-uuid');
    });

    test(
      'comment → comments screen by piece slug (comment carries no piece id)',
      () {
        final route = routeForNotification(
          notif(
            type: NotificationType.comment,
            entityType: NotificationEntityType.comment,
            entityId: 'c1',
            payload: const NotificationPayload(pieceSlug: 'the-slug'),
          ),
        );
        expect(route, '/p/the-slug/comments');
      },
    );

    test('response with responsePieceId → the response piece', () {
      final route = routeForNotification(
        notif(
          type: NotificationType.response,
          entityType: NotificationEntityType.piece,
          entityId: 'parent',
          payload: const NotificationPayload(responsePieceId: 'resp-1'),
        ),
      );
      expect(route, '/p/resp-1');
    });

    test('mention on a comment → comments screen', () {
      final route = routeForNotification(
        notif(
          type: NotificationType.mention,
          entityType: NotificationEntityType.comment,
          entityId: 'c9',
          payload: const NotificationPayload(pieceSlug: 's', commentId: 'c9'),
        ),
      );
      expect(route, '/p/s/comments');
    });

    test('system with an internal link → that path', () {
      final route = routeForNotification(
        notif(
          type: NotificationType.system,
          entityType: NotificationEntityType.system,
          actorUsername: null,
          payload: const NotificationPayload(systemLink: '/settings'),
        ),
      );
      expect(route, '/settings');
    });

    test(
      'system with an external/protocol-relative link → null (open-redirect safe)',
      () {
        expect(
          routeForNotification(
            notif(
              type: NotificationType.system,
              actorUsername: null,
              payload: const NotificationPayload(systemLink: '//evil.com'),
            ),
          ),
          isNull,
        );
        expect(
          routeForNotification(
            notif(
              type: NotificationType.system,
              actorUsername: null,
              payload: const NotificationPayload(
                systemLink: 'https://evil.com',
              ),
            ),
          ),
          isNull,
        );
      },
    );

    test('unknown type → null (graceful fallback)', () {
      expect(routeForNotification(notif()), isNull);
    });
  });

  group('routeForPushData', () {
    test('resolves a like push payload to the piece', () {
      final route = routeForPushData(<String, String>{
        'type': 'like',
        'entityType': 'piece',
        'entityId': 'p-uuid',
      });
      expect(route, '/p/p-uuid');
    });

    test('blank values are ignored; unknown type → null', () {
      expect(
        routeForPushData(<String, String>{'type': '', 'entityId': ''}),
        isNull,
      );
    });
  });
}

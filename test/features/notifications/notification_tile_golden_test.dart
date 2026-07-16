import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/core/di/providers.dart';
import 'package:qalam_mobile/features/notifications/domain/entities/app_notification.dart';
import 'package:qalam_mobile/features/notifications/domain/value_objects/notification_filter.dart';
import 'package:qalam_mobile/features/notifications/presentation/widgets/notification_tile.dart';
import 'package:qalam_mobile/l10n/generated/app_localizations.dart';
import 'package:qalam_mobile/shared/domain/enums.dart';
import 'package:qalam_mobile/shared/theme/app_theme.dart';

import '../../support/fake_notifications.dart';
import '../../support/harness.dart';

Widget _scene(Brightness brightness) => ProviderScope(
  overrides: [appConfigProvider.overrideWithValue(testConfig)],
  child: MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: buildQalamTheme(brightness: brightness),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: SizedBox(
        width: 390,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            NotificationTile(
              notification: notif(
                id: 'a',
                type: NotificationType.follow,
                actorUsername: 'meera_k',
              ),
              filter: NotificationFilter.all,
              now: DateTime.utc(2026, 7, 16, 14),
            ),
            NotificationTile(
              notification: notif(
                id: 'b',
                type: NotificationType.comment,
                entityType: NotificationEntityType.comment,
                entityId: 'c1',
                actorUsername: 'sara',
                status: NotificationStatus.read,
                payload: const NotificationPayload(
                  pieceSlug: 'a-ghazal',
                  pieceTitle: 'A Ghazal',
                  commentId: 'c1',
                  commentExcerpt: 'The last couplet undid me.',
                ),
              ),
              filter: NotificationFilter.all,
              now: DateTime.utc(2026, 7, 16, 14),
            ),
          ],
        ),
      ),
    ),
  ),
);

void main() {
  testWidgets('notification tiles — light', (WidgetTester tester) async {
    await tester.pumpWidget(_scene(Brightness.light));
    await tester.pump();
    await expectLater(
      find.byType(Column).first,
      matchesGoldenFile('goldens/notification_tiles_light.png'),
    );
  });

  testWidgets('notification tiles — dark', (WidgetTester tester) async {
    await tester.pumpWidget(_scene(Brightness.dark));
    await tester.pump();
    await expectLater(
      find.byType(Column).first,
      matchesGoldenFile('goldens/notification_tiles_dark.png'),
    );
  });
}

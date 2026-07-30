import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/features/notifications/domain/entities/app_notification.dart';
import 'package:qalam_mobile/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:qalam_mobile/features/notifications/presentation/widgets/notification_tile.dart';
import 'package:qalam_mobile/l10n/generated/app_localizations.dart';
import 'package:qalam_mobile/shared/domain/enums.dart';
import 'package:qalam_mobile/shared/theme/app_theme.dart';
import 'package:qalam_mobile/shared/widgets/states/q_empty_state.dart';

import '../../support/fake_notifications.dart';
import '../../support/harness.dart';

Widget _host() => MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: buildQalamTheme(brightness: Brightness.light),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: const NotificationsScreen(),
);

Future<void> _pump(WidgetTester tester, FakeNotificationRepository repo) async {
  late final Widget app;
  await tester.runAsync(() async {
    app = await buildTestApp(notificationRepository: repo, child: _host());
  });
  await tester.pumpWidget(app);
  await settleFrames(tester);
}

void main() {
  testWidgets('renders a row per notification', (WidgetTester tester) async {
    await _pump(
      tester,
      FakeNotificationRepository(
        items: <AppNotification>[
          notif(id: 'a', type: NotificationType.follow),
          notif(id: 'b', type: NotificationType.like, actorUsername: 'sara'),
        ],
      ),
    );
    expect(find.byType(NotificationTile), findsNWidgets(2));
  });

  testWidgets('shows the calm empty state when there are none', (
    WidgetTester tester,
  ) async {
    await _pump(tester, FakeNotificationRepository(items: <AppNotification>[]));
    expect(find.byType(QEmptyState), findsOneWidget);
    expect(find.byType(NotificationTile), findsNothing);
  });
}

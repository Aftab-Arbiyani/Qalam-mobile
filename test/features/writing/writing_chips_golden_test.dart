import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/features/writing/domain/entities/draft_sync.dart';
import 'package:qalam_mobile/features/writing/presentation/widgets/draft_status_chips.dart';
import 'package:qalam_mobile/shared/domain/enums.dart';
import 'package:qalam_mobile/shared/theme/app_theme.dart';

Widget _harness(Brightness brightness) => MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: buildQalamTheme(brightness: brightness),
  home: const Scaffold(
    body: Center(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: <Widget>[
                PieceStatusChip(status: PieceStatus.draft),
                PieceStatusChip(status: PieceStatus.scheduled),
                PieceStatusChip(status: PieceStatus.published),
                PieceStatusChip(status: PieceStatus.archived),
              ],
            ),
            SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: <Widget>[
                SyncStateChip(state: DraftSyncState.synced),
                SyncStateChip(state: DraftSyncState.pending),
                SyncStateChip(state: DraftSyncState.syncing),
                SyncStateChip(state: DraftSyncState.failed),
                SyncStateChip(state: DraftSyncState.conflict),
              ],
            ),
            SizedBox(height: 16),
            AutosaveIndicator(autosaving: false, saved: true),
          ],
        ),
      ),
    ),
  ),
);

void main() {
  testWidgets('draft status + sync chips — light', (WidgetTester tester) async {
    await tester.pumpWidget(_harness(Brightness.light));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/writing_chips_light.png'),
    );
  });

  testWidgets('draft status + sync chips — dark', (WidgetTester tester) async {
    await tester.pumpWidget(_harness(Brightness.dark));
    await tester.pumpAndSettle();
    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/writing_chips_dark.png'),
    );
  });
}

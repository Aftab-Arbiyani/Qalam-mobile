import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/core/di/providers.dart';
import 'package:qalam_mobile/l10n/generated/app_localizations.dart';
import 'package:qalam_mobile/shared/social/domain/entities/comment.dart';
import 'package:qalam_mobile/shared/theme/app_theme.dart';
import 'package:qalam_mobile/shared/widgets/social/comment_tile.dart';

import '../../../support/harness.dart';

/// `CommentTile` formats its meta with [relativeTime], which falls back to
/// `DateTime.now()`. A fixed absolute `createdAt` therefore renders a string whose
/// *length* changes as wall-clock time passes ("now" -> "6d" -> "1w" -> "1mo"),
/// which silently drifts these goldens — it already did once. Anchoring the fixture
/// to now keeps the rendered label pinned at "3h" for good.
final DateTime _createdAt = DateTime.now().toUtc().subtract(
  const Duration(hours: 3),
);
final DateTime _editedAt = DateTime.now().toUtc().subtract(
  const Duration(hours: 2),
);

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
            CommentTile(
              comment: Comment(
                id: 'c1',
                author: const CommentAuthor(
                  username: 'meera_k',
                  penName: 'Meera',
                ),
                body: 'This ghazal undid me — the last couplet especially.',
                replyCount: 2,
                createdAt: _createdAt,
                editedAt: _editedAt,
              ),
              pieceId: 'p1',
            ),
            const CommentTile(
              comment: Comment(id: 'c2', isDeleted: true),
              pieceId: 'p1',
            ),
          ],
        ),
      ),
    ),
  ),
);

void main() {
  testWidgets('comment tiles — light', (WidgetTester tester) async {
    await tester.pumpWidget(_scene(Brightness.light));
    await tester.pump();
    await expectLater(
      find.byType(Column).first,
      matchesGoldenFile('goldens/comment_tiles_light.png'),
    );
  });

  testWidgets('comment tiles — dark', (WidgetTester tester) async {
    await tester.pumpWidget(_scene(Brightness.dark));
    await tester.pump();
    await expectLater(
      find.byType(Column).first,
      matchesGoldenFile('goldens/comment_tiles_dark.png'),
    );
  });
}

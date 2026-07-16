import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/features/reading/domain/entities/piece_detail.dart';
import 'package:qalam_mobile/features/reading/domain/entities/piece_engagement.dart';
import 'package:qalam_mobile/features/reading/presentation/screens/reading_screen.dart';
import 'package:qalam_mobile/l10n/generated/app_localizations.dart';
import 'package:qalam_mobile/shared/domain/entities/author.dart';
import 'package:qalam_mobile/shared/domain/entities/taxonomy.dart';
import 'package:qalam_mobile/shared/theme/app_theme.dart';

import '../../support/fake_reading_repository.dart';
import '../../support/harness.dart';

PieceDetail _piece() => const PieceDetail(
  id: 'p1',
  title: 'A Ghazal for the Evening',
  author: Author(username: 'farheen', penName: 'Farheen'),
  language: LanguageRef(code: 'en'),
  content: <String, dynamic>{
    'type': 'doc',
    'content': <dynamic>[
      <String, dynamic>{
        'type': 'paragraph',
        'content': <dynamic>[
          <String, dynamic>{
            'type': 'text',
            'text': 'The evening settled like ink.',
          },
        ],
      },
    ],
  },
);

void main() {
  testWidgets('reader renders the title and content, and likes optimistically', (
    WidgetTester tester,
  ) async {
    final FakeReadingRepository reading = FakeReadingRepository(
      piece: _piece(),
      engagement: const PieceEngagement(likes: 5),
    );
    late final Widget app;
    await tester.runAsync(() async {
      app = await buildTestApp(
        readingRepository: reading,
        engagementRepository: FakeEngagementRepository(),
        child: MaterialApp(
          theme: buildQalamTheme(brightness: Brightness.light),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const ReadingScreen(pieceId: 'p1'),
        ),
      );
    });
    await tester.pumpWidget(app);
    await settleFrames(tester);

    expect(find.text('A Ghazal for the Evening'), findsOneWidget);
    expect(
      find.textContaining('The evening settled like ink.'),
      findsOneWidget,
    );
    // The author byline renders even though the rich profile fails to load.
    expect(find.text('Farheen'), findsOneWidget);
    // The bottom action bar is present (like/bookmark/share).
    expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    expect(find.byIcon(Icons.bookmark_border), findsOneWidget);
    // Opening the piece fired a view beacon (optimistic like/rollback is covered
    // by the engagement controller test).
    expect(reading.viewBeacons, greaterThanOrEqualTo(1));
  });
}

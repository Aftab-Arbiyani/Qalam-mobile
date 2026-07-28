/// "More like this" (docs/48 §3.1) — the port of the web reader's related-pieces
/// section. What matters is that it is NON-CRITICAL: no tags, a failed load, or an
/// empty result must all render nothing, and the piece itself never appears in its
/// own suggestions.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/features/reading/domain/entities/piece_detail.dart';
import 'package:qalam_mobile/features/reading/domain/entities/piece_engagement.dart';
import 'package:qalam_mobile/features/reading/presentation/controllers/related_pieces_controller.dart';
import 'package:qalam_mobile/features/reading/presentation/screens/reading_screen.dart';
import 'package:qalam_mobile/l10n/generated/app_localizations.dart';
import 'package:qalam_mobile/shared/domain/entities/author.dart';
import 'package:qalam_mobile/shared/domain/entities/piece_summary.dart';
import 'package:qalam_mobile/shared/domain/entities/taxonomy.dart';
import 'package:qalam_mobile/shared/theme/app_theme.dart';

import '../../support/fake_reading_repository.dart';
import '../../support/harness.dart';

PieceDetail _piece({List<TagRef> tags = const <TagRef>[]}) => PieceDetail(
  id: 'p1',
  title: 'A Ghazal for the Evening',
  author: const Author(username: 'farheen', penName: 'Farheen'),
  language: const LanguageRef(code: 'en'),
  tags: tags,
  content: const <String, dynamic>{
    'type': 'doc',
    'content': <dynamic>[
      <String, dynamic>{
        'type': 'paragraph',
        'content': <dynamic>[
          <String, dynamic>{'type': 'text', 'text': 'The evening settled.'},
        ],
      },
    ],
  },
);

PieceSummary _summary(String id, String title) => PieceSummary(
  id: id,
  title: title,
  author: const Author(username: 'noor', penName: 'Noor'),
  language: const LanguageRef(code: 'en'),
  readingTimeSeconds: 240,
);

Future<void> _pumpReader(
  WidgetTester tester,
  FakeReadingRepository reading,
) async {
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
}

void main() {
  testWidgets('renders up to four suggestions for the first tag', (
    WidgetTester tester,
  ) async {
    final FakeReadingRepository reading = FakeReadingRepository(
      piece: _piece(
        tags: const <TagRef>[
          TagRef(slug: 'ghazal', name: 'ghazal'),
          TagRef(slug: 'urdu', name: 'urdu'),
        ],
      ),
      engagement: const PieceEngagement(likes: 5),
      related: <PieceSummary>[
        _summary('p2', 'Second Evening'),
        _summary('p3', 'Third Evening'),
        _summary('p4', 'Fourth Evening'),
        _summary('p5', 'Fifth Evening'),
        _summary('p6', 'Sixth Evening'),
      ],
    );

    await _pumpReader(tester, reading);

    expect(find.text('More like this'), findsOneWidget);
    // Four at most, in order — the fifth is dropped.
    expect(find.text('Second Evening'), findsOneWidget);
    expect(find.text('Fifth Evening'), findsOneWidget);
    expect(find.text('Sixth Evening'), findsNothing);
    // Read time renders alongside the author.
    expect(find.textContaining('4 min read'), findsNWidgets(4));
    // The FIRST tag is the one queried, and one extra is requested so that
    // filtering the current piece out still leaves a full section.
    expect(reading.lastRelatedTag?.slug, 'ghazal');
    expect(reading.lastRelatedLimit, kRelatedPiecesMax + 1);
  });

  testWidgets('filters the current piece out of its own suggestions', (
    WidgetTester tester,
  ) async {
    final FakeReadingRepository reading = FakeReadingRepository(
      piece: _piece(
        tags: const <TagRef>[TagRef(slug: 'ghazal', name: 'ghazal')],
      ),
      related: <PieceSummary>[
        _summary('p1', 'A Ghazal for the Evening'),
        _summary('p2', 'Second Evening'),
      ],
    );

    await _pumpReader(tester, reading);

    // The reader's own title appears once — as the piece, not as a suggestion.
    expect(find.text('A Ghazal for the Evening'), findsOneWidget);
    expect(find.text('Second Evening'), findsOneWidget);
  });

  testWidgets('an untagged piece shows no section and makes no request', (
    WidgetTester tester,
  ) async {
    final FakeReadingRepository reading = FakeReadingRepository(
      piece: _piece(),
      related: <PieceSummary>[_summary('p2', 'Second Evening')],
    );

    await _pumpReader(tester, reading);

    expect(find.text('More like this'), findsNothing);
    expect(find.text('Second Evening'), findsNothing);
    expect(reading.lastRelatedTag, isNull);
  });

  testWidgets('a failed load renders nothing, never an error', (
    WidgetTester tester,
  ) async {
    final FakeReadingRepository reading = FakeReadingRepository(
      piece: _piece(
        tags: const <TagRef>[TagRef(slug: 'ghazal', name: 'ghazal')],
      ),
      relatedFails: true,
    );

    await _pumpReader(tester, reading);

    // The piece is still fully readable; the section simply is not there.
    expect(find.text('A Ghazal for the Evening'), findsOneWidget);
    expect(find.textContaining('The evening settled.'), findsOneWidget);
    expect(find.text('More like this'), findsNothing);
    expect(find.textContaining('went wrong'), findsNothing);
  });

  testWidgets('an empty result renders no heading', (
    WidgetTester tester,
  ) async {
    final FakeReadingRepository reading = FakeReadingRepository(
      piece: _piece(
        tags: const <TagRef>[TagRef(slug: 'ghazal', name: 'ghazal')],
      ),
    );

    await _pumpReader(tester, reading);

    expect(reading.lastRelatedTag?.slug, 'ghazal');
    expect(find.text('More like this'), findsNothing);
  });
}

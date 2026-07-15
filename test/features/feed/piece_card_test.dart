import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/core/di/providers.dart';
import 'package:qalam_mobile/features/feed/domain/entities/piece_summary.dart';
import 'package:qalam_mobile/features/feed/presentation/widgets/piece_card.dart';
import 'package:qalam_mobile/shared/domain/entities/author.dart';
import 'package:qalam_mobile/shared/domain/entities/taxonomy.dart';
import 'package:qalam_mobile/shared/domain/enums.dart';
import 'package:qalam_mobile/shared/theme/app_theme.dart';

import '../../support/harness.dart';

void main() {
  testWidgets('PieceCard renders title, byline, genre + read time', (
    WidgetTester tester,
  ) async {
    const PieceSummary piece = PieceSummary(
      id: 'p1',
      title: 'A Ghazal for the Evening',
      author: Author(username: 'farheen', penName: 'Farheen'),
      language: LanguageRef(
        code: 'ur',
        nativeName: 'اردو',
        direction: TextDirectionKind.rtl,
      ),
      genre: GenreRef(slug: 'ghazal', name: 'Ghazal'),
      readingTimeSeconds: 180,
      stats: PieceSummaryStats(likes: 12),
    );

    await tester.pumpWidget(
      ProviderScope(
        // Untyped literal so the Override element type is inferred (it is not
        // exported for direct annotation).
        overrides: [appConfigProvider.overrideWithValue(testConfig)],
        child: MaterialApp(
          theme: buildQalamTheme(brightness: Brightness.light),
          home: const Scaffold(body: PieceCard(piece: piece)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('A Ghazal for the Evening'), findsOneWidget);
    expect(find.text('Farheen'), findsOneWidget);
    expect(find.text('Ghazal'), findsOneWidget);
    expect(find.text('3m'), findsOneWidget); // 180s → 3 min
    expect(find.text('12'), findsOneWidget); // like count
  });
}

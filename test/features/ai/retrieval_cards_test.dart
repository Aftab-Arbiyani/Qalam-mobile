import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/features/ai/domain/entities/retrieval.dart';
import 'package:qalam_mobile/features/ai/presentation/widgets/retrieval_cards.dart';
import 'package:qalam_mobile/shared/theme/app_theme.dart';

Widget _host(Widget child) => MaterialApp(
  theme: buildQalamTheme(brightness: Brightness.light),
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

const SearchResultItem _item = SearchResultItem(
  id: 'n1',
  type: 'character',
  sourceType: 'knowledge_graph',
  title: 'Aria',
  summary: 'The brave protagonist.',
  object: <String, dynamic>{},
  confidence: 0.9,
  relevanceScore: 0.85,
  evidence: <RetrievalEvidence>[
    RetrievalEvidence(
      source: 'knowledge_graph',
      ref: 'n1',
      label: 'Aria',
      quote: 'Aria drew her blade.',
      score: 0.9,
    ),
  ],
  relatedEntities: <RelatedEntity>[
    RelatedEntity(id: 'n2', type: 'character', name: 'Kael', relation: 'ally'),
  ],
  navigation: NavigationTarget(kind: 'graph_node', ref: 'n1'),
  reason: 'strong match to your query',
  ranking: RankingExplanation(
    score: 0.85,
    summary: 'strong match',
    signals: <RankingSignalContribution>[],
  ),
);

void main() {
  testWidgets(
    'SearchResultCard renders title, reason, related + evidence and fires onOpen',
    (WidgetTester tester) async {
      int opened = 0;
      await tester.pumpWidget(
        _host(
          SearchResultCard(
            item: _item,
            onOpen: () => opened++,
            onRelatedTap: (_) {},
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Aria'), findsOneWidget);
      expect(find.textContaining('strong match'), findsWidgets);
      expect(find.text('Kael · ally'), findsOneWidget); // related entity chip
      expect(
        find.textContaining('Sources (1)'),
        findsOneWidget,
      ); // expandable evidence

      await tester.tap(find.text('Aria'));
      await tester.pump();
      expect(opened, 1);
    },
  );

  testWidgets('RecommendationCard always shows its reason', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _host(
        RecommendationCard(
          item: const RecommendationItem(
            id: 'p1',
            kind: 'trending',
            targetType: 'piece',
            title: 'A Story',
            summary: 'A summary.',
            object: <String, dynamic>{},
            score: 0.9,
            confidence: 0.9,
            reason: 'Trending across the community',
            influencedBy: <RelatedEntity>[],
            evidence: <RetrievalEvidence>[],
            navigation: NavigationTarget(kind: 'piece', ref: 's1'),
          ),
          onOpen: () {},
        ),
      ),
    );
    await tester.pump();
    expect(find.text('A Story'), findsOneWidget);
    expect(
      find.textContaining('Trending across the community'),
      findsOneWidget,
    );
  });
}

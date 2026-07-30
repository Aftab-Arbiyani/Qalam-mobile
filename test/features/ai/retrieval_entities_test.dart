import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/features/ai/ai.dart';

void main() {
  group('SemanticSearchResponse.fromJson', () {
    test('parses results with evidence, related, navigation, ranking', () {
      final SemanticSearchResponse r = SemanticSearchResponse.fromJson(
        <String, dynamic>{
          'query': 'aria',
          'intent': 'search',
          'queryType': 'character',
          'answer': 'She is the hero.',
          'results': <dynamic>[
            <String, dynamic>{
              'id': 'n1',
              'type': 'character',
              'sourceType': 'knowledge_graph',
              'title': 'Aria',
              'summary': 'the hero',
              'object': <String, dynamic>{'role': 'protagonist'},
              'confidence': 0.9,
              'relevanceScore': 0.8,
              'evidence': <dynamic>[
                <String, dynamic>{
                  'source': 'knowledge_graph',
                  'ref': 'n1',
                  'label': 'Aria',
                  'quote': 'brave',
                  'score': 0.9,
                },
              ],
              'relatedEntities': <dynamic>[
                <String, dynamic>{
                  'id': 'n2',
                  'type': 'character',
                  'name': 'Kael',
                  'relation': 'ally',
                },
              ],
              'navigation': <String, dynamic>{
                'kind': 'graph_node',
                'ref': 'n1',
                'view': 'character',
              },
              'reason': 'strong name match',
              'ranking': <String, dynamic>{
                'score': 0.8,
                'summary': 'strong name match',
                'signals': <dynamic>[
                  <String, dynamic>{
                    'signal': 'semantic_similarity',
                    'weight': 1,
                    'value': 0.9,
                    'contribution': 0.9,
                  },
                ],
              },
            },
          ],
          'evidence': <dynamic>[],
          'meta': <String, dynamic>{
            'sources': <dynamic>['knowledge_graph'],
            'totalCandidates': 1,
            'returned': 1,
            'confidence': 0.8,
            'degraded': false,
          },
        },
      );

      expect(r.results, hasLength(1));
      final SearchResultItem item = r.results.first;
      expect(item.title, 'Aria');
      expect(item.evidence.first.quote, 'brave');
      expect(item.relatedEntities.first.name, 'Kael');
      expect(item.navigation.kind, 'graph_node');
      expect(item.ranking.summary, 'strong name match');
      expect(r.meta.sources, contains('knowledge_graph'));
    });

    test('tolerates missing/garbage fields', () {
      final SemanticSearchResponse r = SemanticSearchResponse.fromJson(
        <String, dynamic>{},
      );
      expect(r.results, isEmpty);
      expect(r.answer, isNull);
      expect(r.meta.confidence, 0);
    });
  });

  group('ExplorerViewResult.fromJson + round-trip', () {
    test('parses nodes/edges/stats and round-trips through toJson', () {
      final ExplorerViewResult v = ExplorerViewResult.fromJson(
        <String, dynamic>{
          'storyId': 'piece-1',
          'view': 'characters',
          'nodes': <dynamic>[
            <String, dynamic>{
              'id': 'c1',
              'type': 'character',
              'name': 'Aria',
              'aliases': <dynamic>['the wanderer'],
              'summary': 'hero',
              'data': <String, dynamic>{'role': 'protagonist'},
              'confidence': 80,
              'mentionCount': 12,
              'firstChapter': 'ch1',
              'evidence': <dynamic>[
                <String, dynamic>{
                  'chapterRef': 'ch1',
                  'quote': 'Aria drew her blade.',
                },
              ],
            },
          ],
          'edges': <dynamic>[
            <String, dynamic>{
              'id': 'e1',
              'type': 'relationship',
              'sourceId': 'c1',
              'targetId': 'c2',
              'label': 'ally',
              'data': <String, dynamic>{},
              'confidence': 70,
            },
          ],
          'stats': <String, dynamic>{'nodeCount': 1, 'edgeCount': 1},
        },
      );

      expect(v.nodes.single.name, 'Aria');
      expect(v.nodes.single.aliases, contains('the wanderer'));
      expect(v.edges.single.label, 'ally');
      expect(v.nodeById('c1')?.name, 'Aria');

      final ExplorerViewResult back = ExplorerViewResult.fromJson(v.toJson());
      expect(back.nodes.single.name, 'Aria');
      expect(back.edges.single.sourceId, 'c1');
    });
  });

  group('AskStreamEvent.fromJson', () {
    test('maps the type field (sources/start/delta/done) and citations', () {
      expect(
        AskStreamEvent.fromJson(<String, dynamic>{
          'type': 'sources',
          'confidence': 0.7,
          'citations': <dynamic>[
            <String, dynamic>{'ref': 'n1', 'label': 'Aria', 'quote': 'brave'},
          ],
        }).type,
        AskStreamEventType.sources,
      );
      expect(
        AskStreamEvent.fromJson(<String, dynamic>{
          'type': 'delta',
          'text': 'hi',
        }).text,
        'hi',
      );
      expect(
        AskStreamEvent.fromJson(<String, dynamic>{'type': 'mystery'}).type,
        AskStreamEventType.unknown,
      );
    });
  });

  group('RecommendationResponse + SavedSearch', () {
    test('recommendation items keep their reason + influencing entities', () {
      final RecommendationResponse r = RecommendationResponse.fromJson(
        <String, dynamic>{
          'kind': 'related_characters',
          'items': <dynamic>[
            <String, dynamic>{
              'id': 'c1',
              'kind': 'related_characters',
              'targetType': 'character',
              'title': 'Aria',
              'summary': 'hero',
              'object': <String, dynamic>{},
              'score': 0.8,
              'confidence': 0.8,
              'reason': 'Central character',
              'influencedBy': <dynamic>[
                <String, dynamic>{
                  'id': 'c2',
                  'type': 'character',
                  'name': 'Kael',
                  'relation': 'ally',
                },
              ],
              'evidence': <dynamic>[],
              'navigation': <String, dynamic>{
                'kind': 'graph_node',
                'ref': 'c1',
              },
            },
          ],
          'meta': <String, dynamic>{
            'sources': <dynamic>[],
            'totalCandidates': 1,
            'returned': 1,
            'confidence': 0.8,
            'degraded': false,
          },
        },
      );
      expect(r.items.single.reason, 'Central character');
      expect(r.items.single.influencedBy.single.name, 'Kael');
    });

    test('SavedSearch round-trips', () {
      final SavedSearch s = SavedSearch.fromJson(<String, dynamic>{
        'id': 'ss1',
        'name': 'My search',
        'query': 'aria',
        'queryType': 'character',
        'storyId': 'piece-1',
        'createdAt': '2026-01-01T00:00:00.000Z',
      });
      expect(s.key, 'my search');
      expect(SavedSearch.fromJson(s.toJson()).query, 'aria');
    });
  });
}

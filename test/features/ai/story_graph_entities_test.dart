/// The Story Map graph read model (AF3).
///
/// Split out of `retrieval_entities_test.dart` at **M2**, when D5 moved the retrieval
/// entities to `lib/shared/retrieval/`. The graph shapes stayed with the AI feature —
/// they are Story Map's, not search's — and a test file that spanned both would have
/// straddled the boundary the move exists to draw.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:qalam_mobile/features/ai/domain/entities/story_graph.dart';

void main() {
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
              'evidence': <dynamic>[
                <String, dynamic>{
                  'chapterRef': 'ch2',
                  'quote': 'They rode out together.',
                },
              ],
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

    /// Defect **W9-3** (`platfrom/docs/48` §6.2). `StoryGraphEdge.fromJson` read seven
    /// fields and skipped `evidence` — the quote grounding the RELATIONSHIP, as opposed to
    /// either endpoint — while `StoryGraphNode.fromJson` parsed the identical field three
    /// classes above it. The backend populates it on every edge (`toEdgeDto`), so it
    /// arrived on the wire and was dropped before any widget could ask.
    ///
    /// Asserted through the **round trip** as well as the parse, because the offline cache
    /// re-reads `toJson`: a field that parses but is not serialised comes back empty on the
    /// second open, which is the harder version of the same bug to notice.
    test('an edge keeps the evidence that grounds the relationship (W9-3)', () {
      final ExplorerViewResult v = ExplorerViewResult.fromJson(
        <String, dynamic>{
          'storyId': 'piece-1',
          'view': 'relationships',
          'nodes': <dynamic>[],
          'edges': <dynamic>[
            <String, dynamic>{
              'id': 'e1',
              'type': 'relationship',
              'sourceId': 'c1',
              'targetId': 'c2',
              'label': 'mentored by',
              'data': <String, dynamic>{},
              'confidence': 0.8,
              'evidence': <dynamic>[
                <String, dynamic>{
                  'chapterRef': 'ch3',
                  'quote': 'He had taught her everything she knew.',
                },
              ],
            },
          ],
          'stats': <String, dynamic>{'nodeCount': 0, 'edgeCount': 1},
        },
      );

      expect(v.edges.single.evidence, hasLength(1));
      expect(
        v.edges.single.evidence.single.quote,
        'He had taught her everything she knew.',
      );
      expect(v.edges.single.evidence.single.chapterRef, 'ch3');

      final ExplorerViewResult back = ExplorerViewResult.fromJson(v.toJson());
      expect(
        back.edges.single.evidence.single.quote,
        'He had taught her everything she knew.',
      );
    });

    /// An edge with no evidence is ordinary, not an error: the field is always present on
    /// the wire but may be empty, and an older cache entry predates it entirely.
    test('an edge with absent or empty evidence parses to an empty list', () {
      final ExplorerViewResult v = ExplorerViewResult.fromJson(
        <String, dynamic>{
          'storyId': 'piece-1',
          'view': 'map',
          'nodes': <dynamic>[],
          'edges': <dynamic>[
            <String, dynamic>{
              'id': 'e1',
              'type': 'mentions',
              'sourceId': 'c1',
              'targetId': 'c2',
              'label': '',
              'data': <String, dynamic>{},
              'confidence': 0.5,
            },
          ],
          'stats': <String, dynamic>{'nodeCount': 0, 'edgeCount': 1},
        },
      );

      expect(v.edges.single.evidence, isEmpty);
    });
  });

  // `AskStreamEvent.fromJson` was pinned here. **D5** deleted Ask My Book (B2 removed
  // the route), so the type it decoded is gone and there is nothing left to assert.
}

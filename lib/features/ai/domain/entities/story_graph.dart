/// AF4 Story Explorer entities — the structured story-knowledge-graph objects the
/// backend returns (docs 36). Every explorer view renders directly from these; the
/// client never re-derives graph structure. `toJson` round-trips for the last-viewed
/// explorer cache.
library;

import '../../../../core/utils/typedefs.dart';
import 'retrieval_json.dart';

/// A node in the story knowledge graph (character/location/event/…).
class StoryGraphNode {
  const StoryGraphNode({
    required this.id,
    required this.type,
    required this.name,
    required this.aliases,
    required this.summary,
    required this.data,
    required this.confidence,
    required this.mentionCount,
    required this.firstChapter,
    required this.evidence,
  });

  final String id;
  final String type;
  final String name;
  final List<String> aliases;
  final String summary;
  final Json data;
  final double confidence;
  final int mentionCount;
  final String? firstChapter;
  final List<StoryGraphEvidence> evidence;

  factory StoryGraphNode.fromJson(Json json) => StoryGraphNode(
    id: rjString(json['id']),
    type: rjString(json['type']),
    name: rjString(json['name']),
    aliases:
        (json['aliases'] as List?)?.whereType<String>().toList() ??
        const <String>[],
    summary: rjString(json['summary']),
    data: rjMap(json['data']),
    confidence: rjDouble(json['confidence']),
    mentionCount: rjInt(json['mentionCount']),
    firstChapter: json['firstChapter'] as String?,
    evidence: rjList(json['evidence'], StoryGraphEvidence.fromJson),
  );

  Json toJson() => <String, dynamic>{
    'id': id,
    'type': type,
    'name': name,
    'aliases': aliases,
    'summary': summary,
    'data': data,
    'confidence': confidence,
    'mentionCount': mentionCount,
    'firstChapter': firstChapter,
    'evidence': evidence.map((StoryGraphEvidence e) => e.toJson()).toList(),
  };
}

/// A grounding reference carried on a graph node/edge (chapter cue + quote).
class StoryGraphEvidence {
  const StoryGraphEvidence({required this.chapterRef, required this.quote});

  final String? chapterRef;
  final String quote;

  factory StoryGraphEvidence.fromJson(Json json) => StoryGraphEvidence(
    chapterRef: json['chapterRef'] as String?,
    quote: rjString(json['quote']),
  );

  Json toJson() => <String, dynamic>{'chapterRef': chapterRef, 'quote': quote};
}

/// A typed edge between two graph nodes.
class StoryGraphEdge {
  const StoryGraphEdge({
    required this.id,
    required this.type,
    required this.sourceId,
    required this.targetId,
    required this.label,
    required this.data,
    required this.confidence,
    required this.evidence,
  });

  final String id;
  final String type;
  final String sourceId;
  final String targetId;
  final String label;
  final Json data;
  final double confidence;

  /// What grounds the RELATIONSHIP — distinct from the evidence on either endpoint.
  ///
  /// Defect **W9-3** (`platfrom/docs/48` §6.2): this was the one field of `StoryEdgeDto`
  /// the parser dropped, while [StoryGraphNode] parsed the identical field beside it. The
  /// backend populates it on every edge (`story.mappers.ts` `toEdgeDto`), so the quote
  /// explaining *why the graph believes these two are connected* arrived on the wire and
  /// was discarded before any widget could ask for it. Required, not defaulted, so the
  /// asymmetry cannot silently return.
  final List<StoryGraphEvidence> evidence;

  factory StoryGraphEdge.fromJson(Json json) => StoryGraphEdge(
    id: rjString(json['id']),
    type: rjString(json['type']),
    sourceId: rjString(json['sourceId']),
    targetId: rjString(json['targetId']),
    label: rjString(json['label']),
    data: rjMap(json['data']),
    confidence: rjDouble(json['confidence']),
    evidence: rjList(json['evidence'], StoryGraphEvidence.fromJson),
  );

  Json toJson() => <String, dynamic>{
    'id': id,
    'type': type,
    'sourceId': sourceId,
    'targetId': targetId,
    'label': label,
    'data': data,
    'confidence': confidence,
    'evidence': evidence.map((StoryGraphEvidence e) => e.toJson()).toList(),
  };
}

/// One Story Explorer view: the projected nodes + edges for a story + view.
class ExplorerViewResult {
  const ExplorerViewResult({
    required this.storyId,
    required this.view,
    required this.nodes,
    required this.edges,
    required this.nodeCount,
    required this.edgeCount,
  });

  final String storyId;
  final String view;
  final List<StoryGraphNode> nodes;
  final List<StoryGraphEdge> edges;
  final int nodeCount;
  final int edgeCount;

  factory ExplorerViewResult.fromJson(Json json) {
    final Json stats = rjMap(json['stats']);
    return ExplorerViewResult(
      storyId: rjString(json['storyId']),
      view: rjString(json['view']),
      nodes: rjList(json['nodes'], StoryGraphNode.fromJson),
      edges: rjList(json['edges'], StoryGraphEdge.fromJson),
      nodeCount: rjInt(stats['nodeCount']),
      edgeCount: rjInt(stats['edgeCount']),
    );
  }

  Json toJson() => <String, dynamic>{
    'storyId': storyId,
    'view': view,
    'nodes': nodes.map((StoryGraphNode n) => n.toJson()).toList(),
    'edges': edges.map((StoryGraphEdge e) => e.toJson()).toList(),
    'stats': <String, dynamic>{'nodeCount': nodeCount, 'edgeCount': edgeCount},
  };

  /// Nodes whose name matches [nodeId] as a source/target — used for neighbour lookups.
  StoryGraphNode? nodeById(String nodeId) {
    for (final StoryGraphNode n in nodes) {
      if (n.id == nodeId) return n;
    }
    return null;
  }
}

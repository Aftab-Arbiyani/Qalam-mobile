/// AI feature barrel (AF1 + AF2 + AF3). The reusable AI layer for the mobile app: the
/// provider abstraction (repository + streaming), the domain vocabulary (completions,
/// suggestions, Polish actions, feedback lenses/reports, story graph), the state
/// controllers (Polish session, feedback, story map run), the editor seam, and the
/// presentation surfaces (sheets + screens). Every AI feature reuses the AF1 platform —
/// no duplicated prompt/stream logic.
///
/// **D5 (owner, 2026-09-02)** removed the AI *surface*: the conversation layer, Ask My
/// Book, the Prompt Library, the token-usage screen and the generation actions are
/// gone, and what remains is named for what it does — Polish, Manuscript feedback,
/// Story Map.
///
/// **M2 lifted retrieval out entirely**, to `lib/shared/retrieval/`. Search and
/// recommendations are consumed by `features/search`, `features/feed` and
/// `features/reading`, and features never import features — so nothing below mentions
/// them any more, and this feature is exactly the three writing tools.
library;

// Domain — entities
export 'domain/entities/ai_completion.dart';
export 'domain/entities/ai_feature_flag.dart';
export 'domain/entities/ai_stream_event.dart';
export 'domain/entities/ai_suggestion.dart';
export 'domain/entities/story_graph.dart';
export 'domain/entities/story_map_event.dart';
// Domain — repository
export 'domain/repositories/ai_repository.dart';
// Domain — value objects
export 'domain/value_objects/ai_feature_ids.dart';
export 'domain/value_objects/ai_writing_context.dart';
export 'domain/value_objects/coach_report.dart';
export 'domain/value_objects/coach_tool.dart';
export 'domain/value_objects/story_map_seed.dart';
export 'domain/value_objects/writing_action.dart';
// Presentation — controllers
export 'presentation/controllers/ai_stream_controller.dart';
export 'presentation/controllers/assistant_session_controller.dart';
export 'presentation/controllers/craft_coach_controller.dart';
export 'presentation/controllers/story_explorer_controller.dart';
export 'presentation/controllers/story_map_controller.dart';
// Presentation — editor seam
export 'presentation/editor/ai_editor_target.dart';
// Presentation — panels + screens
export 'presentation/panels/craft_coach_panel.dart';
export 'presentation/panels/polish_sheet.dart';
// Presentation — providers
export 'presentation/providers/ai_providers.dart';
export 'presentation/screens/story_explorer_screen.dart';
// Presentation — widgets
export 'presentation/widgets/model_disclosure_note.dart';

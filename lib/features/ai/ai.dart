/// AI feature barrel (AF1 + AF2). The reusable AI layer for the mobile app: the
/// provider abstraction (repository + streaming), the domain vocabulary (completions,
/// conversations, usage, suggestions, writing actions, coach tools/reports, prompt
/// presets), the state controllers (assistant session, craft coach, prompt library,
/// conversations), the editor seam, and the presentation surfaces (panels + screens).
/// Every AI feature reuses the AF1 platform — no duplicated prompt/stream/token logic.
library;

// Domain — entities
export 'domain/entities/ai_completion.dart';
export 'domain/entities/ai_conversation.dart';
export 'domain/entities/ai_feature_flag.dart';
export 'domain/entities/ai_stream_event.dart';
export 'domain/entities/ai_suggestion.dart';
export 'domain/entities/ai_usage.dart';
// Domain — repository
export 'domain/repositories/ai_repository.dart';
// Domain — value objects
export 'domain/value_objects/ai_feature_ids.dart';
export 'domain/value_objects/ai_writing_context.dart';
export 'domain/value_objects/coach_report.dart';
export 'domain/value_objects/coach_tool.dart';
export 'domain/value_objects/prompt_preset.dart';
export 'domain/value_objects/writing_action.dart';
// Presentation — controllers
export 'presentation/controllers/ai_stream_controller.dart';
export 'presentation/controllers/assistant_session_controller.dart';
export 'presentation/controllers/conversation_detail_controller.dart';
export 'presentation/controllers/conversations_controller.dart';
export 'presentation/controllers/craft_coach_controller.dart';
export 'presentation/controllers/prompt_library_controller.dart';
// Presentation — editor seam
export 'presentation/editor/ai_editor_target.dart';
// Presentation — panels + screens
export 'presentation/panels/craft_coach_panel.dart';
export 'presentation/panels/writing_assistant_panel.dart';
// Presentation — providers
export 'presentation/providers/ai_providers.dart';
export 'presentation/screens/ai_conversation_screen.dart';
export 'presentation/screens/ai_conversations_screen.dart';
export 'presentation/screens/ai_usage_screen.dart';
export 'presentation/screens/prompt_library_screen.dart';

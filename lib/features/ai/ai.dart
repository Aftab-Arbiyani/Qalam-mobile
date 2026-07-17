/// AI feature barrel (AF1). The reusable AI layer for the mobile app — repository,
/// providers, streaming controller, and domain entities that future AI affordances
/// (composed into editor/feed via the design system) build on. AF1 ships no
/// end-user screens; this is the foundation (docs/34 §9).
library;

export 'domain/entities/ai_completion.dart';
export 'domain/entities/ai_feature_flag.dart';
export 'domain/entities/ai_stream_event.dart';
export 'domain/repositories/ai_repository.dart';
export 'presentation/controllers/ai_stream_controller.dart';
export 'presentation/providers/ai_providers.dart';

/// Public surface of the writing feature (M4) — the route-level screens the app
/// router mounts. Nothing else in the feature is imported from outside it (docs/40
/// §6, §7): cross-feature coupling goes through the router by path.
library;

export 'presentation/screens/drafts_screen.dart';
export 'presentation/screens/editor_screen.dart';
export 'presentation/screens/preview_screen.dart';

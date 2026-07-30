/// Public surface of the search & discovery feature (M6) — the route-level screen
/// the app router mounts on the Search tab. Everything else in the feature stays
/// private to it; cross-feature coupling goes through the router by path and
/// through the shared discovery module (docs/40 §7.3).
library;

export 'presentation/screens/search_screen.dart';

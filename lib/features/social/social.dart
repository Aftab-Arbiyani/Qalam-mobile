/// Public surface of the social feature (M7) — the route-level screens the app
/// router mounts. The social DATA + embeddable widgets live in `shared/social`
/// and `shared/widgets/social` so reading and profile reuse them without importing
/// this feature (docs/40 §7.3).
library;

export 'presentation/screens/collection_detail_screen.dart';
export 'presentation/screens/collections_screen.dart';
export 'presentation/screens/comments_screen.dart';
export 'presentation/screens/follow_requests_screen.dart';
export 'presentation/screens/followers_screen.dart';
export 'presentation/screens/responses_screen.dart';

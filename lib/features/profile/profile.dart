/// The profile feature's public surface (docs/40 §7). Screens are reached by route
/// name, not by importing internals; this barrel exports only what the app shell
/// and other composition points legitimately need — the screens the router mounts.
library;

export 'presentation/screens/my_profile_screen.dart';
export 'presentation/screens/privacy_settings_screen.dart';
export 'presentation/screens/profile_edit_screen.dart';
export 'presentation/screens/public_profile_screen.dart';

/// Build flavor — resolved once at boot from a compile-time `--dart-define`
/// (`QALAM_ENV`). Mirrors the web `VITE_APP_ENV` (docs/40 §28.1). There is no
/// runtime flavor switching in release builds.
library;

enum AppFlavor {
  development('development'),
  staging('staging'),
  production('production');

  const AppFlavor(this.wire);
  final String wire;

  static AppFlavor fromWire(String? value) => values.firstWhere(
    (AppFlavor e) => e.wire == value,
    orElse: () => AppFlavor.development,
  );

  bool get isProduction => this == AppFlavor.production;
  bool get isDevelopment => this == AppFlavor.development;
}

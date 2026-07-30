/// Build flavor — resolved once at boot from a compile-time `--dart-define`
/// (`QALAM_ENV`). Mirrors the web `VITE_APP_ENV` (docs/40 §28.1). There is no
/// runtime flavor switching in release builds.
///
/// Four environments (docs/51): `development` (local), `qa` and `staging`
/// (shared pre-prod), `production`. The `wire` string is the exact value carried
/// by `QALAM_ENV` in each `dart_defines/<flavor>.json` and by the matching native
/// build flavor (Android product flavor / iOS scheme).
library;

enum AppFlavor {
  development('development'),
  qa('qa'),
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
  bool get isQa => this == AppFlavor.qa;
  bool get isStaging => this == AppFlavor.staging;
}

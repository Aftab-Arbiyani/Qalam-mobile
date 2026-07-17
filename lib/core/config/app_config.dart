/// Typed, immutable environment configuration (docs/40 §28).
///
/// Resolved once in `bootstrap` from compile-time `--dart-define` values and
/// injected via `appConfigProvider`. Never read `String.fromEnvironment`
/// anywhere else — depend on this object. [validate] fails fast at boot so a
/// misconfigured build dies at launch, not on the first API call.
library;

import 'package:flutter/foundation.dart';

import 'app_flavor.dart';

@immutable
class AppConfig {
  const AppConfig({
    required this.flavor,
    required this.apiUrl,
    required this.cdnUrl,
    required this.sentryDsn,
    required this.enablePush,
    required this.webUrl,
    required this.enableAi,
  });

  /// Build config from `--dart-define` keys. Defaults target local development.
  factory AppConfig.fromEnvironment() {
    const String env = String.fromEnvironment(
      'QALAM_ENV',
      defaultValue: 'development',
    );
    return AppConfig(
      flavor: AppFlavor.fromWire(env),
      apiUrl: const String.fromEnvironment(
        'QALAM_API_URL',
        defaultValue: 'http://localhost:4000',
      ),
      cdnUrl: const String.fromEnvironment('QALAM_CDN_URL'),
      webUrl: const String.fromEnvironment('QALAM_WEB_URL'),
      sentryDsn: const String.fromEnvironment('QALAM_SENTRY_DSN'),
      enablePush: const bool.fromEnvironment('QALAM_ENABLE_PUSH'),
      enableAi: const bool.fromEnvironment('QALAM_ENABLE_AI'),
    );
  }

  final AppFlavor flavor;

  /// API origin. The versioned base is [apiBaseUrl].
  final String apiUrl;

  /// Media/CDN base for resolving storage keys → URLs. Empty ⇒ derive from
  /// [apiUrl] origin (docs/40 §35.1).
  final String cdnUrl;

  /// Public web origin for shareable universal links (docs/40 §12.2). Empty ⇒
  /// derive from the [apiUrl] origin so "copy link" still yields a valid path.
  final String webUrl;

  /// Crash/error reporting DSN. Empty ⇒ reporting disabled.
  final String sentryDsn;

  /// Feature flag: FCM push. Off by default in M1 (in-app polling only,
  /// docs/40 §32). The push seam is inert until this is enabled.
  final bool enablePush;

  /// Feature flag: AI platform (AF1, Phase 2). Off by default; gates the
  /// `features/ai` routes/affordances. The server-side per-feature flags
  /// (`feature.ai.*`, via GET /ai/features) are the runtime source of truth —
  /// this is the compile-time kill switch (mirrors [enablePush]).
  final bool enableAi;

  /// The versioned API base every request is relative to.
  String get apiBaseUrl => '${_stripTrailingSlash(apiUrl)}/api/v1';

  /// The channel header the backend uses to return refresh tokens in the body.
  String get clientHeader => 'mobile';

  bool get isCrashReportingEnabled => sentryDsn.isNotEmpty;

  /// Effective media base: [cdnUrl] if set, else the [apiUrl] origin.
  String get mediaBaseUrl {
    if (cdnUrl.isNotEmpty) return _stripTrailingSlash(cdnUrl);
    final Uri uri = Uri.parse(apiUrl);
    return _stripTrailingSlash(uri.origin);
  }

  /// Base for shareable links: [webUrl] if set, else the [apiUrl] origin.
  String get shareBaseUrl {
    if (webUrl.isNotEmpty) return _stripTrailingSlash(webUrl);
    final Uri uri = Uri.parse(apiUrl);
    return _stripTrailingSlash(uri.origin);
  }

  /// Throws [ArgumentError] if the config is unusable. Called in `bootstrap`.
  void validate() {
    final Uri? parsed = Uri.tryParse(apiUrl);
    if (parsed == null ||
        !parsed.hasScheme ||
        !(parsed.isScheme('http') || parsed.isScheme('https'))) {
      throw ArgumentError.value(
        apiUrl,
        'QALAM_API_URL',
        'must be an absolute http(s) URL',
      );
    }
    if (cdnUrl.isNotEmpty && Uri.tryParse(cdnUrl)?.hasScheme != true) {
      throw ArgumentError.value(
        cdnUrl,
        'QALAM_CDN_URL',
        'must be an absolute URL when set',
      );
    }
  }

  static String _stripTrailingSlash(String value) =>
      value.endsWith('/') ? value.substring(0, value.length - 1) : value;
}

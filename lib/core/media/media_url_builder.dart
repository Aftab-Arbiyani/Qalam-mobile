/// Resolves a storage KEY into a CDN URL (docs/40 §35.1).
///
/// The API returns object keys (`avatarKey`, `coverImageKey`), never URLs. The
/// client builds the URL from the configured media base (CDN, or the API origin
/// as a fallback). An already-absolute key is returned as-is; a null/empty key
/// yields null so the caller shows a placeholder.
library;

import '../config/app_config.dart';

class MediaUrlBuilder {
  const MediaUrlBuilder(this._config);

  final AppConfig _config;

  String? urlForKey(String? key) {
    if (key == null || key.isEmpty) return null;
    if (key.startsWith('http://') || key.startsWith('https://')) return key;
    final String base = _config.mediaBaseUrl;
    final String normalizedKey = key.startsWith('/') ? key.substring(1) : key;
    return '$base/$normalizedKey';
  }
}

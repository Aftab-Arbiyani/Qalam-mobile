/// PII/secret redaction (docs/40 §29.2) — mirrors the backend Pino redact list.
///
/// Never log tokens, passwords, OAuth codes, cookies, or emails. Redaction is
/// applied centrally here and used by the logging interceptor and the logger, so
/// no call site has to remember.
library;

const String _redacted = '***';

/// Header/field keys whose values must never appear in a log.
const Set<String> sensitiveKeys = <String>{
  'authorization',
  'cookie',
  'set-cookie',
  'password',
  'currentpassword',
  'newpassword',
  'token',
  'accesstoken',
  'refreshtoken',
  'code',
  'email',
};

bool _isSensitive(String key) => sensitiveKeys.contains(key.toLowerCase());

/// Partial-mask an email (`af***@s***`) so it is recognizable but not exposed.
String maskEmail(String email) {
  final int at = email.indexOf('@');
  if (at <= 0) return _redacted;
  final String local = email.substring(0, at);
  final String domain = email.substring(at + 1);
  String head(String s) => s.isEmpty ? '' : '${s[0]}***';
  return '${head(local)}@${head(domain)}';
}

/// Return a copy of [headers] with sensitive values masked.
Map<String, Object?> redactHeaders(Map<String, Object?> headers) {
  return <String, Object?>{
    for (final MapEntry<String, Object?> e in headers.entries)
      e.key: _isSensitive(e.key) ? _redacted : e.value,
  };
}

/// Deep-copy [value], masking any sensitive keys anywhere in the structure.
Object? redactValue(Object? value) {
  if (value is Map) {
    return <String, Object?>{
      for (final MapEntry<Object?, Object?> e in value.entries)
        '${e.key}': _isSensitive('${e.key}')
            ? _redacted
            : ('${e.key}'.toLowerCase() == 'email' && e.value is String)
            ? maskEmail(e.value! as String)
            : redactValue(e.value),
    };
  }
  if (value is List) {
    return value.map(redactValue).toList(growable: false);
  }
  return value;
}

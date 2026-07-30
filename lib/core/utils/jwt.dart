/// Client-side access-token decode — a UX HINT ONLY (docs/40 §11.4).
///
/// The server is always authoritative on authorization; the signature is NOT
/// verified here (the client cannot hold the signing secret). We read `role`/`exp`
/// purely to render the right chrome. Never gate a security decision on this.
library;

import 'dart:convert';

import '../../shared/domain/enums.dart';

class DecodedAccessToken {
  const DecodedAccessToken({required this.sub, required this.role, this.exp});

  final String sub;
  final Role role;
  final int? exp;
}

/// Decode an access token's claims, or null if malformed / not a JWT.
DecodedAccessToken? decodeAccessToken(String? token) {
  if (token == null || token.isEmpty) return null;
  final List<String> parts = token.split('.');
  if (parts.length != 3) return null;
  try {
    final Object? payload = jsonDecode(
      utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
    );
    if (payload is! Map) return null;
    final Object? sub = payload['sub'];
    if (sub is! String) return null;
    return DecodedAccessToken(
      sub: sub,
      role: Role.fromWire(payload['role'] as String?),
      exp: payload['exp'] as int?,
    );
  } on FormatException {
    return null;
  }
}

/// True when the token is absent or its `exp` is in the past (with skew).
bool isAccessTokenExpired(String? token, {int skewSeconds = 10}) {
  final DecodedAccessToken? decoded = decodeAccessToken(token);
  final int? exp = decoded?.exp;
  if (exp == null) return true;
  return exp * 1000 <=
      DateTime.now().millisecondsSinceEpoch - skewSeconds * 1000;
}

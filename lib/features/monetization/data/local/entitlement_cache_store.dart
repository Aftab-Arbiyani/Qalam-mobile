/// On-device entitlement cache (AF5) — the last server-authoritative entitlement
/// snapshot, stored as JSON in the shared Hive `prefs` box so premium gating reads
/// instantly and degrades gracefully offline (docs/40 §23). It is a HINT cache only:
/// a fresh server snapshot always wins, and the server re-checks every premium action.
library;

import 'dart:convert';

import 'package:hive_ce_flutter/hive_flutter.dart';

import '../../domain/entities/entitlement.dart';

class EntitlementCacheStore {
  EntitlementCacheStore(this._box);

  final Box<dynamic> _box;

  static const String _key = 'monetization_entitlements';

  EntitlementSnapshot? read() {
    final Object? raw = _box.get(_key);
    if (raw is! String) return null;
    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      return EntitlementSnapshot.fromJson(Map<String, dynamic>.from(decoded));
    } catch (_) {
      return null;
    }
  }

  Future<void> write(EntitlementSnapshot snapshot) =>
      _box.put(_key, jsonEncode(snapshot.toJson()));

  Future<void> clear() => _box.delete(_key);
}

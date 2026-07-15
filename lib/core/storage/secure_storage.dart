/// Thin wrapper over `flutter_secure_storage` (docs/40 §27).
///
/// The ONLY store for secrets (tokens). Non-secret cache lives in Hive
/// (cache_store.dart). Platform hardening (device-only Keychain accessibility,
/// Android encrypted keystore) is configured in the security-hardening epic; the
/// M1 wrapper uses safe defaults and exposes a mockable surface.
library;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  SecureStorage([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  Future<String?> read(String key) => _storage.read(key: key);

  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  Future<void> delete(String key) => _storage.delete(key: key);

  Future<void> deleteAll() => _storage.deleteAll();
}

/// In-flight request de-duplication (docs/40 §13, "Request Deduplication").
///
/// Coalesces identical concurrent GETs: while a request with a given key is in
/// flight, later callers await the same future instead of firing a duplicate.
/// The entry is removed on completion so the next call fetches fresh.
library;

import 'package:dio/dio.dart';

class RequestDeduplicator {
  final Map<String, Future<Response<dynamic>>> _inflight =
      <String, Future<Response<dynamic>>>{};

  Future<Response<dynamic>> run(
    String key,
    Future<Response<dynamic>> Function() action,
  ) {
    final Future<Response<dynamic>>? existing = _inflight[key];
    if (existing != null) return existing;

    final Future<Response<dynamic>> future = action();
    _inflight[key] = future;
    future.whenComplete(() => _inflight.remove(key)).ignore();
    return future;
  }

  int get inflightCount => _inflight.length;
}

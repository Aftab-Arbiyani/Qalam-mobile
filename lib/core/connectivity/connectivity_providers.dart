/// Connectivity providers (docs/40 §24). Exposes the online/offline status as a
/// stream provider the UI watches for the offline banner and reconnect refetch.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../di/providers.dart';

part 'connectivity_providers.g.dart';

/// Emits the current online status, then every subsequent change.
@riverpod
Stream<bool> connectivityStatus(Ref ref) async* {
  final service = ref.watch(connectivityServiceProvider);
  yield service.isOnline;
  yield* service.onStatusChange;
}

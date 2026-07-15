/// Connectivity monitoring (docs/40 §24).
///
/// Exposes a synchronous [isOnline] snapshot (used by `ApiClient` for offline
/// request detection) and a broadcast [onStatusChange] stream (used by the UI
/// offline banner and reconnect-driven refetch). Connectivity ≠ reachability;
/// transport failures in the network layer confirm true reachability.
library;

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  ConnectivityService([Connectivity? connectivity])
    : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;
  final StreamController<bool> _controller = StreamController<bool>.broadcast();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _isOnline = true;

  bool get isOnline => _isOnline;
  Stream<bool> get onStatusChange => _controller.stream;

  /// Seed the current status and start listening. Called in `bootstrap`.
  Future<void> initialize() async {
    _isOnline = _hasConnection(await _connectivity.checkConnectivity());
    _subscription = _connectivity.onConnectivityChanged.listen(_onChanged);
  }

  void _onChanged(List<ConnectivityResult> results) {
    final bool online = _hasConnection(results);
    if (online != _isOnline) {
      _isOnline = online;
      _controller.add(online);
    }
  }

  bool _hasConnection(List<ConnectivityResult> results) =>
      results.any((ConnectivityResult r) => r != ConnectivityResult.none);

  Future<void> dispose() async {
    await _subscription?.cancel();
    await _controller.close();
  }
}

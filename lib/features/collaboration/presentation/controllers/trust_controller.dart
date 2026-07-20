/// Trust write-side controller (AF6). Drives block / unblock / mute / unmute,
/// reflects a busy/error state via [AsyncValue], and invalidates the trust standing +
/// block list on success. The server owns enforcement.
library;

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/utils/result.dart';
import '../../domain/repositories/trust_repository.dart';
import '../providers/collaboration_providers.dart';

part 'trust_controller.g.dart';

@riverpod
class TrustController extends _$TrustController {
  @override
  Future<void> build() async {}

  TrustRepository get _repo => ref.read(trustRepositoryProvider);

  Future<bool> block(String userId) => _mutate(() => _repo.block(userId));

  Future<bool> unblock(String userId) => _mutate(() => _repo.unblock(userId));

  Future<bool> mute(String userId) => _mutate(() => _repo.mute(userId));

  Future<bool> unmute(String userId) => _mutate(() => _repo.unmute(userId));

  /// Run a void mutation; returns true on success and refreshes the trust reads.
  Future<bool> _mutate(Future<Result<Object?>> Function() op) async {
    state = const AsyncValue<void>.loading();
    final Result<Object?> result = await op();
    switch (result) {
      case Ok<Object?>():
        state = const AsyncValue<void>.data(null);
        _refreshTrust();
        return true;
      case Err<Object?>(:final Failure failure):
        state = AsyncValue<void>.error(failure, StackTrace.current);
        return false;
    }
  }

  void _refreshTrust() {
    ref.invalidate(trustSummaryProvider);
    ref.invalidate(myBlocksProvider);
  }
}

/// The Trust repository contract (AF6) — the boundary the presentation layer depends
/// on for the current user's trust standing and the block/mute relationships. Returns
/// domain entities / [Failure]s only; the concrete impl talks to the wire.
library;

import '../../../../core/utils/result.dart';
import '../../../../core/utils/typedefs.dart';
import '../entities/block_entry.dart';
import '../entities/trust_summary.dart';

abstract interface class TrustRepository {
  /// The current user's trust standing (score, status, restrictions).
  Future<Result<TrustSummary>> myTrust();

  /// The users the current user has blocked or muted.
  Future<Result<List<BlockEntry>>> myBlocks();

  Future<Result<Unit>> block(String userId);
  Future<Result<Unit>> unblock(String userId);
  Future<Result<Unit>> mute(String userId);
  Future<Result<Unit>> unmute(String userId);
}

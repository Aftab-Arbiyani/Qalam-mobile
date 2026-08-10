/// The profile repository boundary (docs/40 §16). The domain speaks this
/// interface; the data layer implements it against the frozen `/api/v1`
/// profile + `/me` contract. Every method returns a domain [Result] — never a DTO,
/// a `DioException`, or an HTTP status.
///
/// Reads (own + public profile, published grid) are cache-then-network so the
/// profile is viewable offline. Writes (edit, avatar/cover upload) require
/// connectivity and fail fast — there is deliberately NO offline outbox for
/// profile edits (unlike drafts): they are short, low-frequency, and a queued
/// stale PATCH could silently clobber a change made elsewhere (docs/40 §23, §30).
library;

import '../../../../core/utils/result.dart';
import '../../../../shared/pagination/cached_page.dart';
import '../entities/profile.dart';
import '../entities/profile_piece.dart';
import '../value_objects/profile_edit.dart';

/// A profile read plus its freshness — [isStale] is true when served from cache
/// (offline / fetch failure), so the UI can show the offline banner.
typedef CachedProfile = ({Profile profile, bool isStale});

/// A first-page count that is exact when [hasMore] is false, else a lower bound
/// (rendered "N+"). Used for draft / bookmark stat tiles, since cursor pagination
/// carries no total (docs/40 §45).
typedef BoundedCount = ({int count, bool hasMore});

/// Upload progress in the range 0.0–1.0.
typedef UploadProgress = void Function(double progress);

abstract interface class ProfileRepository {
  /// `GET /me` — the signed-in user's own profile. Cache-then-network.
  Future<Result<CachedProfile>> myProfile();

  /// `GET /users/:username` — a public profile (a private account returns a
  /// restricted teaser to strangers). Cache-then-network.
  Future<Result<CachedProfile>> publicProfile(String username);

  /// `GET /users/by-id/:id` — the SAME public profile as [publicProfile], keyed
  /// by user id (B3, `platfrom/docs/45` §4). Collaboration, retrieval and
  /// publishing DTOs carry ids only, so this is the only lookup that can turn a
  /// comment author / reviewer / blocked person into a name. Identical
  /// visibility rules: a private account still returns a restricted teaser.
  Future<Result<CachedProfile>> publicProfileById(String userId);

  /// `PATCH /me` — apply an edit and return the fresh profile. Connectivity
  /// required; refreshes the own-profile cache on success.
  Future<Result<Profile>> updateProfile(ProfileEdit edit);

  /// `POST /profile/avatar` — upload/replace the avatar; returns the storage key.
  Future<Result<String>> uploadAvatar({
    required String filePath,
    UploadProgress? onProgress,
    String? uploadKey,
  });

  /// `POST /profile/cover` — upload/replace the cover/banner; returns the key.
  Future<Result<String>> uploadCover({
    required String filePath,
    UploadProgress? onProgress,
    String? uploadKey,
  });

  /// Abort an in-flight upload registered under [uploadKey] (screen left).
  void cancelUpload(String uploadKey);

  /// `GET /me/pieces?status=published` — the user's own published pieces, one
  /// cursor page. Cache-then-network (first page cached for offline viewing).
  Future<Result<CachedPage<ProfilePiece>>> myPublishedPieces({String? cursor});

  /// `GET /me/drafts?limit=50` — a bounded draft count for the stats tile.
  Future<Result<BoundedCount>> myDraftCount();

  /// `GET /me/bookmarks?limit=50` — a bounded bookmark count for the stats tile.
  Future<Result<BoundedCount>> myBookmarkCount();
}

/// A configurable [ProfileRepository] test double. By default every read returns a
/// canned [Profile] and every write succeeds; set [failure] to make calls fail, or
/// swap the canned data. Records calls + the last edit for assertions. Faking at
/// this seam keeps controller/widget tests off the network (docs/40 §38.4).
library;

import 'package:qalam_mobile/core/error/failure.dart';
import 'package:qalam_mobile/core/utils/result.dart';
import 'package:qalam_mobile/features/profile/domain/entities/profile.dart';
import 'package:qalam_mobile/features/profile/domain/entities/profile_counts.dart';
import 'package:qalam_mobile/features/profile/domain/entities/profile_piece.dart';
import 'package:qalam_mobile/features/profile/domain/entities/viewer_relation.dart';
import 'package:qalam_mobile/features/profile/domain/repositories/profile_repository.dart';
import 'package:qalam_mobile/features/profile/domain/value_objects/profile_edit.dart';
import 'package:qalam_mobile/shared/api/api_envelope.dart';
import 'package:qalam_mobile/shared/domain/entities/taxonomy.dart';
import 'package:qalam_mobile/shared/pagination/cached_page.dart';

const Profile kFakeProfile = Profile(
  id: 'user-1',
  username: 'meera_k',
  penName: 'Meera K.',
  bio: 'Poems at midnight.',
  location: 'Lahore',
  websiteUrl: 'https://meera.example',
  genres: <GenreRef>[GenreRef(slug: 'ghazal', name: 'Ghazal')],
  counts: ProfileCounts(followers: 12, following: 3, piecesPublished: 7),
  viewerRelation: ViewerRelation(isSelf: true),
);

class FakeProfileRepository implements ProfileRepository {
  FakeProfileRepository({
    Profile? profile,
    this.failure,
    this.publishedPieces = const <ProfilePiece>[],
    this.draftCount = (count: 2, hasMore: false),
    this.bookmarkCount = (count: 5, hasMore: false),
  }) : profile = profile ?? kFakeProfile;

  Profile profile;
  Failure? failure;
  List<ProfilePiece> publishedPieces;
  BoundedCount draftCount;
  BoundedCount bookmarkCount;

  int myProfileCalls = 0;
  int updateCalls = 0;
  int avatarUploads = 0;
  int coverUploads = 0;
  ProfileEdit? lastEdit;

  Result<T> _fail<T>() => Err<T>(failure!);

  @override
  Future<Result<CachedProfile>> myProfile() async {
    myProfileCalls++;
    if (failure != null) return _fail<CachedProfile>();
    return Ok<CachedProfile>((profile: profile, isStale: false));
  }

  @override
  Future<Result<CachedProfile>> publicProfile(String username) async {
    if (failure != null) return _fail<CachedProfile>();
    return Ok<CachedProfile>((profile: profile, isStale: false));
  }

  @override
  Future<Result<Profile>> updateProfile(ProfileEdit edit) async {
    updateCalls++;
    lastEdit = edit;
    if (failure != null) return _fail<Profile>();
    profile = profile.copyWith(
      penName: edit.penName ?? profile.penName,
      bio: edit.bio ?? profile.bio,
      location: edit.location ?? profile.location,
      websiteUrl: edit.websiteUrl ?? profile.websiteUrl,
      isPrivate: edit.isPrivate ?? profile.isPrivate,
    );
    return Ok<Profile>(profile);
  }

  @override
  Future<Result<String>> uploadAvatar({
    required String filePath,
    UploadProgress? onProgress,
    String? uploadKey,
  }) async {
    avatarUploads++;
    onProgress?.call(1);
    if (failure != null) return _fail<String>();
    return const Ok<String>('profiles/avatar.webp');
  }

  @override
  Future<Result<String>> uploadCover({
    required String filePath,
    UploadProgress? onProgress,
    String? uploadKey,
  }) async {
    coverUploads++;
    onProgress?.call(1);
    if (failure != null) return _fail<String>();
    return const Ok<String>('profiles/cover.webp');
  }

  @override
  void cancelUpload(String uploadKey) {}

  @override
  Future<Result<CachedPage<ProfilePiece>>> myPublishedPieces({
    String? cursor,
  }) async {
    if (failure != null) return _fail<CachedPage<ProfilePiece>>();
    return Ok<CachedPage<ProfilePiece>>(
      CachedPage<ProfilePiece>(
        page: CursorPage<ProfilePiece>(
          items: publishedPieces,
          meta: const CursorMeta(),
        ),
      ),
    );
  }

  @override
  Future<Result<BoundedCount>> myDraftCount() async =>
      failure != null ? _fail<BoundedCount>() : Ok<BoundedCount>(draftCount);

  @override
  Future<Result<BoundedCount>> myBookmarkCount() async =>
      failure != null ? _fail<BoundedCount>() : Ok<BoundedCount>(bookmarkCount);
}

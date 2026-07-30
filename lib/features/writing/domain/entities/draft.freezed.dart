// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'draft.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Draft {

/// Stable client identity — the Hive key and the `/write/:id` route param.
/// Never sent to the server (kept distinct from [remoteId] for offline create).
 String get localId;/// The server piece UUID once created; null while the draft is local-only.
 String? get remoteId; String get title; String get subtitle; String get featuredQuote;/// TipTap `doc` map — the same shape the wire uses (docs/40 §42.1).
 Map<String, dynamic> get content;/// BCP-47 code (required by the API on create; UI enforces before first sync).
 String get languageCode; String get languageName; TextDirectionKind get direction; String? get genreSlug; String? get genreName; List<String> get tags; Visibility get visibility; PieceStatus get status; String? get slug;/// Server storage key for the cover, once uploaded.
 String? get coverImageKey;/// A locally-picked cover image awaiting upload (offline / not-yet-created).
 String? get pendingCoverPath; DateTime? get scheduledAt; DateTime? get publishedAt;/// The server `updatedAt` this local copy was last synced from — the base for
/// client-side conflict detection (docs/40 §42.1; see [DraftSyncState]).
 DateTime? get remoteUpdatedAt; DateTime get createdAt; DateTime get localUpdatedAt; int get wordCount; int get readingTimeSeconds; DraftSyncState get syncState; DraftIntent get intent;/// Monotonic local revision — bumped on every local edit ("draft version
/// tracking"); surfaced in the UI and used to ignore stale autosave writes.
 int get version;/// Developer-facing detail of the last failed sync (never shown raw to users).
 String? get lastError;
/// Create a copy of Draft
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DraftCopyWith<Draft> get copyWith => _$DraftCopyWithImpl<Draft>(this as Draft, _$identity);

  /// Serializes this Draft to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Draft&&(identical(other.localId, localId) || other.localId == localId)&&(identical(other.remoteId, remoteId) || other.remoteId == remoteId)&&(identical(other.title, title) || other.title == title)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle)&&(identical(other.featuredQuote, featuredQuote) || other.featuredQuote == featuredQuote)&&const DeepCollectionEquality().equals(other.content, content)&&(identical(other.languageCode, languageCode) || other.languageCode == languageCode)&&(identical(other.languageName, languageName) || other.languageName == languageName)&&(identical(other.direction, direction) || other.direction == direction)&&(identical(other.genreSlug, genreSlug) || other.genreSlug == genreSlug)&&(identical(other.genreName, genreName) || other.genreName == genreName)&&const DeepCollectionEquality().equals(other.tags, tags)&&(identical(other.visibility, visibility) || other.visibility == visibility)&&(identical(other.status, status) || other.status == status)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.coverImageKey, coverImageKey) || other.coverImageKey == coverImageKey)&&(identical(other.pendingCoverPath, pendingCoverPath) || other.pendingCoverPath == pendingCoverPath)&&(identical(other.scheduledAt, scheduledAt) || other.scheduledAt == scheduledAt)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&(identical(other.remoteUpdatedAt, remoteUpdatedAt) || other.remoteUpdatedAt == remoteUpdatedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.localUpdatedAt, localUpdatedAt) || other.localUpdatedAt == localUpdatedAt)&&(identical(other.wordCount, wordCount) || other.wordCount == wordCount)&&(identical(other.readingTimeSeconds, readingTimeSeconds) || other.readingTimeSeconds == readingTimeSeconds)&&(identical(other.syncState, syncState) || other.syncState == syncState)&&(identical(other.intent, intent) || other.intent == intent)&&(identical(other.version, version) || other.version == version)&&(identical(other.lastError, lastError) || other.lastError == lastError));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,localId,remoteId,title,subtitle,featuredQuote,const DeepCollectionEquality().hash(content),languageCode,languageName,direction,genreSlug,genreName,const DeepCollectionEquality().hash(tags),visibility,status,slug,coverImageKey,pendingCoverPath,scheduledAt,publishedAt,remoteUpdatedAt,createdAt,localUpdatedAt,wordCount,readingTimeSeconds,syncState,intent,version,lastError]);

@override
String toString() {
  return 'Draft(localId: $localId, remoteId: $remoteId, title: $title, subtitle: $subtitle, featuredQuote: $featuredQuote, content: $content, languageCode: $languageCode, languageName: $languageName, direction: $direction, genreSlug: $genreSlug, genreName: $genreName, tags: $tags, visibility: $visibility, status: $status, slug: $slug, coverImageKey: $coverImageKey, pendingCoverPath: $pendingCoverPath, scheduledAt: $scheduledAt, publishedAt: $publishedAt, remoteUpdatedAt: $remoteUpdatedAt, createdAt: $createdAt, localUpdatedAt: $localUpdatedAt, wordCount: $wordCount, readingTimeSeconds: $readingTimeSeconds, syncState: $syncState, intent: $intent, version: $version, lastError: $lastError)';
}


}

/// @nodoc
abstract mixin class $DraftCopyWith<$Res>  {
  factory $DraftCopyWith(Draft value, $Res Function(Draft) _then) = _$DraftCopyWithImpl;
@useResult
$Res call({
 String localId, String? remoteId, String title, String subtitle, String featuredQuote, Map<String, dynamic> content, String languageCode, String languageName, TextDirectionKind direction, String? genreSlug, String? genreName, List<String> tags, Visibility visibility, PieceStatus status, String? slug, String? coverImageKey, String? pendingCoverPath, DateTime? scheduledAt, DateTime? publishedAt, DateTime? remoteUpdatedAt, DateTime createdAt, DateTime localUpdatedAt, int wordCount, int readingTimeSeconds, DraftSyncState syncState, DraftIntent intent, int version, String? lastError
});




}
/// @nodoc
class _$DraftCopyWithImpl<$Res>
    implements $DraftCopyWith<$Res> {
  _$DraftCopyWithImpl(this._self, this._then);

  final Draft _self;
  final $Res Function(Draft) _then;

/// Create a copy of Draft
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? localId = null,Object? remoteId = freezed,Object? title = null,Object? subtitle = null,Object? featuredQuote = null,Object? content = null,Object? languageCode = null,Object? languageName = null,Object? direction = null,Object? genreSlug = freezed,Object? genreName = freezed,Object? tags = null,Object? visibility = null,Object? status = null,Object? slug = freezed,Object? coverImageKey = freezed,Object? pendingCoverPath = freezed,Object? scheduledAt = freezed,Object? publishedAt = freezed,Object? remoteUpdatedAt = freezed,Object? createdAt = null,Object? localUpdatedAt = null,Object? wordCount = null,Object? readingTimeSeconds = null,Object? syncState = null,Object? intent = null,Object? version = null,Object? lastError = freezed,}) {
  return _then(_self.copyWith(
localId: null == localId ? _self.localId : localId // ignore: cast_nullable_to_non_nullable
as String,remoteId: freezed == remoteId ? _self.remoteId : remoteId // ignore: cast_nullable_to_non_nullable
as String?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,subtitle: null == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String,featuredQuote: null == featuredQuote ? _self.featuredQuote : featuredQuote // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,languageCode: null == languageCode ? _self.languageCode : languageCode // ignore: cast_nullable_to_non_nullable
as String,languageName: null == languageName ? _self.languageName : languageName // ignore: cast_nullable_to_non_nullable
as String,direction: null == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as TextDirectionKind,genreSlug: freezed == genreSlug ? _self.genreSlug : genreSlug // ignore: cast_nullable_to_non_nullable
as String?,genreName: freezed == genreName ? _self.genreName : genreName // ignore: cast_nullable_to_non_nullable
as String?,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,visibility: null == visibility ? _self.visibility : visibility // ignore: cast_nullable_to_non_nullable
as Visibility,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PieceStatus,slug: freezed == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String?,coverImageKey: freezed == coverImageKey ? _self.coverImageKey : coverImageKey // ignore: cast_nullable_to_non_nullable
as String?,pendingCoverPath: freezed == pendingCoverPath ? _self.pendingCoverPath : pendingCoverPath // ignore: cast_nullable_to_non_nullable
as String?,scheduledAt: freezed == scheduledAt ? _self.scheduledAt : scheduledAt // ignore: cast_nullable_to_non_nullable
as DateTime?,publishedAt: freezed == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,remoteUpdatedAt: freezed == remoteUpdatedAt ? _self.remoteUpdatedAt : remoteUpdatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,localUpdatedAt: null == localUpdatedAt ? _self.localUpdatedAt : localUpdatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,wordCount: null == wordCount ? _self.wordCount : wordCount // ignore: cast_nullable_to_non_nullable
as int,readingTimeSeconds: null == readingTimeSeconds ? _self.readingTimeSeconds : readingTimeSeconds // ignore: cast_nullable_to_non_nullable
as int,syncState: null == syncState ? _self.syncState : syncState // ignore: cast_nullable_to_non_nullable
as DraftSyncState,intent: null == intent ? _self.intent : intent // ignore: cast_nullable_to_non_nullable
as DraftIntent,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,lastError: freezed == lastError ? _self.lastError : lastError // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Draft].
extension DraftPatterns on Draft {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Draft value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Draft() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Draft value)  $default,){
final _that = this;
switch (_that) {
case _Draft():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Draft value)?  $default,){
final _that = this;
switch (_that) {
case _Draft() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String localId,  String? remoteId,  String title,  String subtitle,  String featuredQuote,  Map<String, dynamic> content,  String languageCode,  String languageName,  TextDirectionKind direction,  String? genreSlug,  String? genreName,  List<String> tags,  Visibility visibility,  PieceStatus status,  String? slug,  String? coverImageKey,  String? pendingCoverPath,  DateTime? scheduledAt,  DateTime? publishedAt,  DateTime? remoteUpdatedAt,  DateTime createdAt,  DateTime localUpdatedAt,  int wordCount,  int readingTimeSeconds,  DraftSyncState syncState,  DraftIntent intent,  int version,  String? lastError)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Draft() when $default != null:
return $default(_that.localId,_that.remoteId,_that.title,_that.subtitle,_that.featuredQuote,_that.content,_that.languageCode,_that.languageName,_that.direction,_that.genreSlug,_that.genreName,_that.tags,_that.visibility,_that.status,_that.slug,_that.coverImageKey,_that.pendingCoverPath,_that.scheduledAt,_that.publishedAt,_that.remoteUpdatedAt,_that.createdAt,_that.localUpdatedAt,_that.wordCount,_that.readingTimeSeconds,_that.syncState,_that.intent,_that.version,_that.lastError);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String localId,  String? remoteId,  String title,  String subtitle,  String featuredQuote,  Map<String, dynamic> content,  String languageCode,  String languageName,  TextDirectionKind direction,  String? genreSlug,  String? genreName,  List<String> tags,  Visibility visibility,  PieceStatus status,  String? slug,  String? coverImageKey,  String? pendingCoverPath,  DateTime? scheduledAt,  DateTime? publishedAt,  DateTime? remoteUpdatedAt,  DateTime createdAt,  DateTime localUpdatedAt,  int wordCount,  int readingTimeSeconds,  DraftSyncState syncState,  DraftIntent intent,  int version,  String? lastError)  $default,) {final _that = this;
switch (_that) {
case _Draft():
return $default(_that.localId,_that.remoteId,_that.title,_that.subtitle,_that.featuredQuote,_that.content,_that.languageCode,_that.languageName,_that.direction,_that.genreSlug,_that.genreName,_that.tags,_that.visibility,_that.status,_that.slug,_that.coverImageKey,_that.pendingCoverPath,_that.scheduledAt,_that.publishedAt,_that.remoteUpdatedAt,_that.createdAt,_that.localUpdatedAt,_that.wordCount,_that.readingTimeSeconds,_that.syncState,_that.intent,_that.version,_that.lastError);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String localId,  String? remoteId,  String title,  String subtitle,  String featuredQuote,  Map<String, dynamic> content,  String languageCode,  String languageName,  TextDirectionKind direction,  String? genreSlug,  String? genreName,  List<String> tags,  Visibility visibility,  PieceStatus status,  String? slug,  String? coverImageKey,  String? pendingCoverPath,  DateTime? scheduledAt,  DateTime? publishedAt,  DateTime? remoteUpdatedAt,  DateTime createdAt,  DateTime localUpdatedAt,  int wordCount,  int readingTimeSeconds,  DraftSyncState syncState,  DraftIntent intent,  int version,  String? lastError)?  $default,) {final _that = this;
switch (_that) {
case _Draft() when $default != null:
return $default(_that.localId,_that.remoteId,_that.title,_that.subtitle,_that.featuredQuote,_that.content,_that.languageCode,_that.languageName,_that.direction,_that.genreSlug,_that.genreName,_that.tags,_that.visibility,_that.status,_that.slug,_that.coverImageKey,_that.pendingCoverPath,_that.scheduledAt,_that.publishedAt,_that.remoteUpdatedAt,_that.createdAt,_that.localUpdatedAt,_that.wordCount,_that.readingTimeSeconds,_that.syncState,_that.intent,_that.version,_that.lastError);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Draft extends Draft {
  const _Draft({required this.localId, this.remoteId, this.title = '', this.subtitle = '', this.featuredQuote = '', final  Map<String, dynamic> content = const <String, dynamic>{'type' : 'doc', 'content' : <dynamic>[]}, this.languageCode = '', this.languageName = '', this.direction = TextDirectionKind.ltr, this.genreSlug, this.genreName, final  List<String> tags = const <String>[], this.visibility = Visibility.public, this.status = PieceStatus.draft, this.slug, this.coverImageKey, this.pendingCoverPath, this.scheduledAt, this.publishedAt, this.remoteUpdatedAt, required this.createdAt, required this.localUpdatedAt, this.wordCount = 0, this.readingTimeSeconds = 0, this.syncState = DraftSyncState.synced, this.intent = DraftIntent.save, this.version = 1, this.lastError}): _content = content,_tags = tags,super._();
  factory _Draft.fromJson(Map<String, dynamic> json) => _$DraftFromJson(json);

/// Stable client identity — the Hive key and the `/write/:id` route param.
/// Never sent to the server (kept distinct from [remoteId] for offline create).
@override final  String localId;
/// The server piece UUID once created; null while the draft is local-only.
@override final  String? remoteId;
@override@JsonKey() final  String title;
@override@JsonKey() final  String subtitle;
@override@JsonKey() final  String featuredQuote;
/// TipTap `doc` map — the same shape the wire uses (docs/40 §42.1).
 final  Map<String, dynamic> _content;
/// TipTap `doc` map — the same shape the wire uses (docs/40 §42.1).
@override@JsonKey() Map<String, dynamic> get content {
  if (_content is EqualUnmodifiableMapView) return _content;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_content);
}

/// BCP-47 code (required by the API on create; UI enforces before first sync).
@override@JsonKey() final  String languageCode;
@override@JsonKey() final  String languageName;
@override@JsonKey() final  TextDirectionKind direction;
@override final  String? genreSlug;
@override final  String? genreName;
 final  List<String> _tags;
@override@JsonKey() List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

@override@JsonKey() final  Visibility visibility;
@override@JsonKey() final  PieceStatus status;
@override final  String? slug;
/// Server storage key for the cover, once uploaded.
@override final  String? coverImageKey;
/// A locally-picked cover image awaiting upload (offline / not-yet-created).
@override final  String? pendingCoverPath;
@override final  DateTime? scheduledAt;
@override final  DateTime? publishedAt;
/// The server `updatedAt` this local copy was last synced from — the base for
/// client-side conflict detection (docs/40 §42.1; see [DraftSyncState]).
@override final  DateTime? remoteUpdatedAt;
@override final  DateTime createdAt;
@override final  DateTime localUpdatedAt;
@override@JsonKey() final  int wordCount;
@override@JsonKey() final  int readingTimeSeconds;
@override@JsonKey() final  DraftSyncState syncState;
@override@JsonKey() final  DraftIntent intent;
/// Monotonic local revision — bumped on every local edit ("draft version
/// tracking"); surfaced in the UI and used to ignore stale autosave writes.
@override@JsonKey() final  int version;
/// Developer-facing detail of the last failed sync (never shown raw to users).
@override final  String? lastError;

/// Create a copy of Draft
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DraftCopyWith<_Draft> get copyWith => __$DraftCopyWithImpl<_Draft>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DraftToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Draft&&(identical(other.localId, localId) || other.localId == localId)&&(identical(other.remoteId, remoteId) || other.remoteId == remoteId)&&(identical(other.title, title) || other.title == title)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle)&&(identical(other.featuredQuote, featuredQuote) || other.featuredQuote == featuredQuote)&&const DeepCollectionEquality().equals(other._content, _content)&&(identical(other.languageCode, languageCode) || other.languageCode == languageCode)&&(identical(other.languageName, languageName) || other.languageName == languageName)&&(identical(other.direction, direction) || other.direction == direction)&&(identical(other.genreSlug, genreSlug) || other.genreSlug == genreSlug)&&(identical(other.genreName, genreName) || other.genreName == genreName)&&const DeepCollectionEquality().equals(other._tags, _tags)&&(identical(other.visibility, visibility) || other.visibility == visibility)&&(identical(other.status, status) || other.status == status)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.coverImageKey, coverImageKey) || other.coverImageKey == coverImageKey)&&(identical(other.pendingCoverPath, pendingCoverPath) || other.pendingCoverPath == pendingCoverPath)&&(identical(other.scheduledAt, scheduledAt) || other.scheduledAt == scheduledAt)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&(identical(other.remoteUpdatedAt, remoteUpdatedAt) || other.remoteUpdatedAt == remoteUpdatedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.localUpdatedAt, localUpdatedAt) || other.localUpdatedAt == localUpdatedAt)&&(identical(other.wordCount, wordCount) || other.wordCount == wordCount)&&(identical(other.readingTimeSeconds, readingTimeSeconds) || other.readingTimeSeconds == readingTimeSeconds)&&(identical(other.syncState, syncState) || other.syncState == syncState)&&(identical(other.intent, intent) || other.intent == intent)&&(identical(other.version, version) || other.version == version)&&(identical(other.lastError, lastError) || other.lastError == lastError));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,localId,remoteId,title,subtitle,featuredQuote,const DeepCollectionEquality().hash(_content),languageCode,languageName,direction,genreSlug,genreName,const DeepCollectionEquality().hash(_tags),visibility,status,slug,coverImageKey,pendingCoverPath,scheduledAt,publishedAt,remoteUpdatedAt,createdAt,localUpdatedAt,wordCount,readingTimeSeconds,syncState,intent,version,lastError]);

@override
String toString() {
  return 'Draft(localId: $localId, remoteId: $remoteId, title: $title, subtitle: $subtitle, featuredQuote: $featuredQuote, content: $content, languageCode: $languageCode, languageName: $languageName, direction: $direction, genreSlug: $genreSlug, genreName: $genreName, tags: $tags, visibility: $visibility, status: $status, slug: $slug, coverImageKey: $coverImageKey, pendingCoverPath: $pendingCoverPath, scheduledAt: $scheduledAt, publishedAt: $publishedAt, remoteUpdatedAt: $remoteUpdatedAt, createdAt: $createdAt, localUpdatedAt: $localUpdatedAt, wordCount: $wordCount, readingTimeSeconds: $readingTimeSeconds, syncState: $syncState, intent: $intent, version: $version, lastError: $lastError)';
}


}

/// @nodoc
abstract mixin class _$DraftCopyWith<$Res> implements $DraftCopyWith<$Res> {
  factory _$DraftCopyWith(_Draft value, $Res Function(_Draft) _then) = __$DraftCopyWithImpl;
@override @useResult
$Res call({
 String localId, String? remoteId, String title, String subtitle, String featuredQuote, Map<String, dynamic> content, String languageCode, String languageName, TextDirectionKind direction, String? genreSlug, String? genreName, List<String> tags, Visibility visibility, PieceStatus status, String? slug, String? coverImageKey, String? pendingCoverPath, DateTime? scheduledAt, DateTime? publishedAt, DateTime? remoteUpdatedAt, DateTime createdAt, DateTime localUpdatedAt, int wordCount, int readingTimeSeconds, DraftSyncState syncState, DraftIntent intent, int version, String? lastError
});




}
/// @nodoc
class __$DraftCopyWithImpl<$Res>
    implements _$DraftCopyWith<$Res> {
  __$DraftCopyWithImpl(this._self, this._then);

  final _Draft _self;
  final $Res Function(_Draft) _then;

/// Create a copy of Draft
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? localId = null,Object? remoteId = freezed,Object? title = null,Object? subtitle = null,Object? featuredQuote = null,Object? content = null,Object? languageCode = null,Object? languageName = null,Object? direction = null,Object? genreSlug = freezed,Object? genreName = freezed,Object? tags = null,Object? visibility = null,Object? status = null,Object? slug = freezed,Object? coverImageKey = freezed,Object? pendingCoverPath = freezed,Object? scheduledAt = freezed,Object? publishedAt = freezed,Object? remoteUpdatedAt = freezed,Object? createdAt = null,Object? localUpdatedAt = null,Object? wordCount = null,Object? readingTimeSeconds = null,Object? syncState = null,Object? intent = null,Object? version = null,Object? lastError = freezed,}) {
  return _then(_Draft(
localId: null == localId ? _self.localId : localId // ignore: cast_nullable_to_non_nullable
as String,remoteId: freezed == remoteId ? _self.remoteId : remoteId // ignore: cast_nullable_to_non_nullable
as String?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,subtitle: null == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String,featuredQuote: null == featuredQuote ? _self.featuredQuote : featuredQuote // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self._content : content // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,languageCode: null == languageCode ? _self.languageCode : languageCode // ignore: cast_nullable_to_non_nullable
as String,languageName: null == languageName ? _self.languageName : languageName // ignore: cast_nullable_to_non_nullable
as String,direction: null == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as TextDirectionKind,genreSlug: freezed == genreSlug ? _self.genreSlug : genreSlug // ignore: cast_nullable_to_non_nullable
as String?,genreName: freezed == genreName ? _self.genreName : genreName // ignore: cast_nullable_to_non_nullable
as String?,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,visibility: null == visibility ? _self.visibility : visibility // ignore: cast_nullable_to_non_nullable
as Visibility,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PieceStatus,slug: freezed == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String?,coverImageKey: freezed == coverImageKey ? _self.coverImageKey : coverImageKey // ignore: cast_nullable_to_non_nullable
as String?,pendingCoverPath: freezed == pendingCoverPath ? _self.pendingCoverPath : pendingCoverPath // ignore: cast_nullable_to_non_nullable
as String?,scheduledAt: freezed == scheduledAt ? _self.scheduledAt : scheduledAt // ignore: cast_nullable_to_non_nullable
as DateTime?,publishedAt: freezed == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,remoteUpdatedAt: freezed == remoteUpdatedAt ? _self.remoteUpdatedAt : remoteUpdatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,localUpdatedAt: null == localUpdatedAt ? _self.localUpdatedAt : localUpdatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,wordCount: null == wordCount ? _self.wordCount : wordCount // ignore: cast_nullable_to_non_nullable
as int,readingTimeSeconds: null == readingTimeSeconds ? _self.readingTimeSeconds : readingTimeSeconds // ignore: cast_nullable_to_non_nullable
as int,syncState: null == syncState ? _self.syncState : syncState // ignore: cast_nullable_to_non_nullable
as DraftSyncState,intent: null == intent ? _self.intent : intent // ignore: cast_nullable_to_non_nullable
as DraftIntent,version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as int,lastError: freezed == lastError ? _self.lastError : lastError // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on

// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'draft_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DraftSummary {

/// Local record id when a local draft exists for this piece; null for a
/// server-only piece not yet opened/edited on this device.
 String? get localId; String? get remoteId; String get title; PieceStatus get status; Visibility get visibility; DraftSyncState get syncState;/// The `ERROR_CODES` string from the last failed sync, so the row can say WHY it
/// failed instead of only that it did. Null for a server row or a clean draft.
 String? get lastError; TextDirectionKind get direction; String? get coverImageKey; int get wordCount; int get readingTimeSeconds; DateTime? get publishedAt; DateTime? get scheduledAt; DateTime? get updatedAt;
/// Create a copy of DraftSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DraftSummaryCopyWith<DraftSummary> get copyWith => _$DraftSummaryCopyWithImpl<DraftSummary>(this as DraftSummary, _$identity);

  /// Serializes this DraftSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DraftSummary&&(identical(other.localId, localId) || other.localId == localId)&&(identical(other.remoteId, remoteId) || other.remoteId == remoteId)&&(identical(other.title, title) || other.title == title)&&(identical(other.status, status) || other.status == status)&&(identical(other.visibility, visibility) || other.visibility == visibility)&&(identical(other.syncState, syncState) || other.syncState == syncState)&&(identical(other.lastError, lastError) || other.lastError == lastError)&&(identical(other.direction, direction) || other.direction == direction)&&(identical(other.coverImageKey, coverImageKey) || other.coverImageKey == coverImageKey)&&(identical(other.wordCount, wordCount) || other.wordCount == wordCount)&&(identical(other.readingTimeSeconds, readingTimeSeconds) || other.readingTimeSeconds == readingTimeSeconds)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&(identical(other.scheduledAt, scheduledAt) || other.scheduledAt == scheduledAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,localId,remoteId,title,status,visibility,syncState,lastError,direction,coverImageKey,wordCount,readingTimeSeconds,publishedAt,scheduledAt,updatedAt);

@override
String toString() {
  return 'DraftSummary(localId: $localId, remoteId: $remoteId, title: $title, status: $status, visibility: $visibility, syncState: $syncState, lastError: $lastError, direction: $direction, coverImageKey: $coverImageKey, wordCount: $wordCount, readingTimeSeconds: $readingTimeSeconds, publishedAt: $publishedAt, scheduledAt: $scheduledAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $DraftSummaryCopyWith<$Res>  {
  factory $DraftSummaryCopyWith(DraftSummary value, $Res Function(DraftSummary) _then) = _$DraftSummaryCopyWithImpl;
@useResult
$Res call({
 String? localId, String? remoteId, String title, PieceStatus status, Visibility visibility, DraftSyncState syncState, String? lastError, TextDirectionKind direction, String? coverImageKey, int wordCount, int readingTimeSeconds, DateTime? publishedAt, DateTime? scheduledAt, DateTime? updatedAt
});




}
/// @nodoc
class _$DraftSummaryCopyWithImpl<$Res>
    implements $DraftSummaryCopyWith<$Res> {
  _$DraftSummaryCopyWithImpl(this._self, this._then);

  final DraftSummary _self;
  final $Res Function(DraftSummary) _then;

/// Create a copy of DraftSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? localId = freezed,Object? remoteId = freezed,Object? title = null,Object? status = null,Object? visibility = null,Object? syncState = null,Object? lastError = freezed,Object? direction = null,Object? coverImageKey = freezed,Object? wordCount = null,Object? readingTimeSeconds = null,Object? publishedAt = freezed,Object? scheduledAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
localId: freezed == localId ? _self.localId : localId // ignore: cast_nullable_to_non_nullable
as String?,remoteId: freezed == remoteId ? _self.remoteId : remoteId // ignore: cast_nullable_to_non_nullable
as String?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PieceStatus,visibility: null == visibility ? _self.visibility : visibility // ignore: cast_nullable_to_non_nullable
as Visibility,syncState: null == syncState ? _self.syncState : syncState // ignore: cast_nullable_to_non_nullable
as DraftSyncState,lastError: freezed == lastError ? _self.lastError : lastError // ignore: cast_nullable_to_non_nullable
as String?,direction: null == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as TextDirectionKind,coverImageKey: freezed == coverImageKey ? _self.coverImageKey : coverImageKey // ignore: cast_nullable_to_non_nullable
as String?,wordCount: null == wordCount ? _self.wordCount : wordCount // ignore: cast_nullable_to_non_nullable
as int,readingTimeSeconds: null == readingTimeSeconds ? _self.readingTimeSeconds : readingTimeSeconds // ignore: cast_nullable_to_non_nullable
as int,publishedAt: freezed == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,scheduledAt: freezed == scheduledAt ? _self.scheduledAt : scheduledAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [DraftSummary].
extension DraftSummaryPatterns on DraftSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DraftSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DraftSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DraftSummary value)  $default,){
final _that = this;
switch (_that) {
case _DraftSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DraftSummary value)?  $default,){
final _that = this;
switch (_that) {
case _DraftSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? localId,  String? remoteId,  String title,  PieceStatus status,  Visibility visibility,  DraftSyncState syncState,  String? lastError,  TextDirectionKind direction,  String? coverImageKey,  int wordCount,  int readingTimeSeconds,  DateTime? publishedAt,  DateTime? scheduledAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DraftSummary() when $default != null:
return $default(_that.localId,_that.remoteId,_that.title,_that.status,_that.visibility,_that.syncState,_that.lastError,_that.direction,_that.coverImageKey,_that.wordCount,_that.readingTimeSeconds,_that.publishedAt,_that.scheduledAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? localId,  String? remoteId,  String title,  PieceStatus status,  Visibility visibility,  DraftSyncState syncState,  String? lastError,  TextDirectionKind direction,  String? coverImageKey,  int wordCount,  int readingTimeSeconds,  DateTime? publishedAt,  DateTime? scheduledAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _DraftSummary():
return $default(_that.localId,_that.remoteId,_that.title,_that.status,_that.visibility,_that.syncState,_that.lastError,_that.direction,_that.coverImageKey,_that.wordCount,_that.readingTimeSeconds,_that.publishedAt,_that.scheduledAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? localId,  String? remoteId,  String title,  PieceStatus status,  Visibility visibility,  DraftSyncState syncState,  String? lastError,  TextDirectionKind direction,  String? coverImageKey,  int wordCount,  int readingTimeSeconds,  DateTime? publishedAt,  DateTime? scheduledAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _DraftSummary() when $default != null:
return $default(_that.localId,_that.remoteId,_that.title,_that.status,_that.visibility,_that.syncState,_that.lastError,_that.direction,_that.coverImageKey,_that.wordCount,_that.readingTimeSeconds,_that.publishedAt,_that.scheduledAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DraftSummary extends DraftSummary {
  const _DraftSummary({this.localId, this.remoteId, this.title = '', this.status = PieceStatus.draft, this.visibility = Visibility.public, this.syncState = DraftSyncState.synced, this.lastError, this.direction = TextDirectionKind.ltr, this.coverImageKey, this.wordCount = 0, this.readingTimeSeconds = 0, this.publishedAt, this.scheduledAt, this.updatedAt}): super._();
  factory _DraftSummary.fromJson(Map<String, dynamic> json) => _$DraftSummaryFromJson(json);

/// Local record id when a local draft exists for this piece; null for a
/// server-only piece not yet opened/edited on this device.
@override final  String? localId;
@override final  String? remoteId;
@override@JsonKey() final  String title;
@override@JsonKey() final  PieceStatus status;
@override@JsonKey() final  Visibility visibility;
@override@JsonKey() final  DraftSyncState syncState;
/// The `ERROR_CODES` string from the last failed sync, so the row can say WHY it
/// failed instead of only that it did. Null for a server row or a clean draft.
@override final  String? lastError;
@override@JsonKey() final  TextDirectionKind direction;
@override final  String? coverImageKey;
@override@JsonKey() final  int wordCount;
@override@JsonKey() final  int readingTimeSeconds;
@override final  DateTime? publishedAt;
@override final  DateTime? scheduledAt;
@override final  DateTime? updatedAt;

/// Create a copy of DraftSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DraftSummaryCopyWith<_DraftSummary> get copyWith => __$DraftSummaryCopyWithImpl<_DraftSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DraftSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DraftSummary&&(identical(other.localId, localId) || other.localId == localId)&&(identical(other.remoteId, remoteId) || other.remoteId == remoteId)&&(identical(other.title, title) || other.title == title)&&(identical(other.status, status) || other.status == status)&&(identical(other.visibility, visibility) || other.visibility == visibility)&&(identical(other.syncState, syncState) || other.syncState == syncState)&&(identical(other.lastError, lastError) || other.lastError == lastError)&&(identical(other.direction, direction) || other.direction == direction)&&(identical(other.coverImageKey, coverImageKey) || other.coverImageKey == coverImageKey)&&(identical(other.wordCount, wordCount) || other.wordCount == wordCount)&&(identical(other.readingTimeSeconds, readingTimeSeconds) || other.readingTimeSeconds == readingTimeSeconds)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&(identical(other.scheduledAt, scheduledAt) || other.scheduledAt == scheduledAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,localId,remoteId,title,status,visibility,syncState,lastError,direction,coverImageKey,wordCount,readingTimeSeconds,publishedAt,scheduledAt,updatedAt);

@override
String toString() {
  return 'DraftSummary(localId: $localId, remoteId: $remoteId, title: $title, status: $status, visibility: $visibility, syncState: $syncState, lastError: $lastError, direction: $direction, coverImageKey: $coverImageKey, wordCount: $wordCount, readingTimeSeconds: $readingTimeSeconds, publishedAt: $publishedAt, scheduledAt: $scheduledAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$DraftSummaryCopyWith<$Res> implements $DraftSummaryCopyWith<$Res> {
  factory _$DraftSummaryCopyWith(_DraftSummary value, $Res Function(_DraftSummary) _then) = __$DraftSummaryCopyWithImpl;
@override @useResult
$Res call({
 String? localId, String? remoteId, String title, PieceStatus status, Visibility visibility, DraftSyncState syncState, String? lastError, TextDirectionKind direction, String? coverImageKey, int wordCount, int readingTimeSeconds, DateTime? publishedAt, DateTime? scheduledAt, DateTime? updatedAt
});




}
/// @nodoc
class __$DraftSummaryCopyWithImpl<$Res>
    implements _$DraftSummaryCopyWith<$Res> {
  __$DraftSummaryCopyWithImpl(this._self, this._then);

  final _DraftSummary _self;
  final $Res Function(_DraftSummary) _then;

/// Create a copy of DraftSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? localId = freezed,Object? remoteId = freezed,Object? title = null,Object? status = null,Object? visibility = null,Object? syncState = null,Object? lastError = freezed,Object? direction = null,Object? coverImageKey = freezed,Object? wordCount = null,Object? readingTimeSeconds = null,Object? publishedAt = freezed,Object? scheduledAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_DraftSummary(
localId: freezed == localId ? _self.localId : localId // ignore: cast_nullable_to_non_nullable
as String?,remoteId: freezed == remoteId ? _self.remoteId : remoteId // ignore: cast_nullable_to_non_nullable
as String?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PieceStatus,visibility: null == visibility ? _self.visibility : visibility // ignore: cast_nullable_to_non_nullable
as Visibility,syncState: null == syncState ? _self.syncState : syncState // ignore: cast_nullable_to_non_nullable
as DraftSyncState,lastError: freezed == lastError ? _self.lastError : lastError // ignore: cast_nullable_to_non_nullable
as String?,direction: null == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as TextDirectionKind,coverImageKey: freezed == coverImageKey ? _self.coverImageKey : coverImageKey // ignore: cast_nullable_to_non_nullable
as String?,wordCount: null == wordCount ? _self.wordCount : wordCount // ignore: cast_nullable_to_non_nullable
as int,readingTimeSeconds: null == readingTimeSeconds ? _self.readingTimeSeconds : readingTimeSeconds // ignore: cast_nullable_to_non_nullable
as int,publishedAt: freezed == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,scheduledAt: freezed == scheduledAt ? _self.scheduledAt : scheduledAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on

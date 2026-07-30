// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reading_history_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ReadingHistoryEntry {

 String get pieceId; String get title; DateTime get lastReadAt; String get authorName; String? get authorUsername; String? get slug; String? get coverImageKey; String? get languageCode; TextDirectionKind get direction;/// Last scroll position as a fraction 0.0–1.0 of the content extent.
 double get progress;/// Accumulated dwell time across sessions, in seconds.
 int get totalReadSeconds;/// Whether the reader reached the end (progress ≥ completion threshold).
 bool get isCompleted;
/// Create a copy of ReadingHistoryEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReadingHistoryEntryCopyWith<ReadingHistoryEntry> get copyWith => _$ReadingHistoryEntryCopyWithImpl<ReadingHistoryEntry>(this as ReadingHistoryEntry, _$identity);

  /// Serializes this ReadingHistoryEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReadingHistoryEntry&&(identical(other.pieceId, pieceId) || other.pieceId == pieceId)&&(identical(other.title, title) || other.title == title)&&(identical(other.lastReadAt, lastReadAt) || other.lastReadAt == lastReadAt)&&(identical(other.authorName, authorName) || other.authorName == authorName)&&(identical(other.authorUsername, authorUsername) || other.authorUsername == authorUsername)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.coverImageKey, coverImageKey) || other.coverImageKey == coverImageKey)&&(identical(other.languageCode, languageCode) || other.languageCode == languageCode)&&(identical(other.direction, direction) || other.direction == direction)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.totalReadSeconds, totalReadSeconds) || other.totalReadSeconds == totalReadSeconds)&&(identical(other.isCompleted, isCompleted) || other.isCompleted == isCompleted));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,pieceId,title,lastReadAt,authorName,authorUsername,slug,coverImageKey,languageCode,direction,progress,totalReadSeconds,isCompleted);

@override
String toString() {
  return 'ReadingHistoryEntry(pieceId: $pieceId, title: $title, lastReadAt: $lastReadAt, authorName: $authorName, authorUsername: $authorUsername, slug: $slug, coverImageKey: $coverImageKey, languageCode: $languageCode, direction: $direction, progress: $progress, totalReadSeconds: $totalReadSeconds, isCompleted: $isCompleted)';
}


}

/// @nodoc
abstract mixin class $ReadingHistoryEntryCopyWith<$Res>  {
  factory $ReadingHistoryEntryCopyWith(ReadingHistoryEntry value, $Res Function(ReadingHistoryEntry) _then) = _$ReadingHistoryEntryCopyWithImpl;
@useResult
$Res call({
 String pieceId, String title, DateTime lastReadAt, String authorName, String? authorUsername, String? slug, String? coverImageKey, String? languageCode, TextDirectionKind direction, double progress, int totalReadSeconds, bool isCompleted
});




}
/// @nodoc
class _$ReadingHistoryEntryCopyWithImpl<$Res>
    implements $ReadingHistoryEntryCopyWith<$Res> {
  _$ReadingHistoryEntryCopyWithImpl(this._self, this._then);

  final ReadingHistoryEntry _self;
  final $Res Function(ReadingHistoryEntry) _then;

/// Create a copy of ReadingHistoryEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? pieceId = null,Object? title = null,Object? lastReadAt = null,Object? authorName = null,Object? authorUsername = freezed,Object? slug = freezed,Object? coverImageKey = freezed,Object? languageCode = freezed,Object? direction = null,Object? progress = null,Object? totalReadSeconds = null,Object? isCompleted = null,}) {
  return _then(_self.copyWith(
pieceId: null == pieceId ? _self.pieceId : pieceId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,lastReadAt: null == lastReadAt ? _self.lastReadAt : lastReadAt // ignore: cast_nullable_to_non_nullable
as DateTime,authorName: null == authorName ? _self.authorName : authorName // ignore: cast_nullable_to_non_nullable
as String,authorUsername: freezed == authorUsername ? _self.authorUsername : authorUsername // ignore: cast_nullable_to_non_nullable
as String?,slug: freezed == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String?,coverImageKey: freezed == coverImageKey ? _self.coverImageKey : coverImageKey // ignore: cast_nullable_to_non_nullable
as String?,languageCode: freezed == languageCode ? _self.languageCode : languageCode // ignore: cast_nullable_to_non_nullable
as String?,direction: null == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as TextDirectionKind,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double,totalReadSeconds: null == totalReadSeconds ? _self.totalReadSeconds : totalReadSeconds // ignore: cast_nullable_to_non_nullable
as int,isCompleted: null == isCompleted ? _self.isCompleted : isCompleted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ReadingHistoryEntry].
extension ReadingHistoryEntryPatterns on ReadingHistoryEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReadingHistoryEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReadingHistoryEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReadingHistoryEntry value)  $default,){
final _that = this;
switch (_that) {
case _ReadingHistoryEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReadingHistoryEntry value)?  $default,){
final _that = this;
switch (_that) {
case _ReadingHistoryEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String pieceId,  String title,  DateTime lastReadAt,  String authorName,  String? authorUsername,  String? slug,  String? coverImageKey,  String? languageCode,  TextDirectionKind direction,  double progress,  int totalReadSeconds,  bool isCompleted)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReadingHistoryEntry() when $default != null:
return $default(_that.pieceId,_that.title,_that.lastReadAt,_that.authorName,_that.authorUsername,_that.slug,_that.coverImageKey,_that.languageCode,_that.direction,_that.progress,_that.totalReadSeconds,_that.isCompleted);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String pieceId,  String title,  DateTime lastReadAt,  String authorName,  String? authorUsername,  String? slug,  String? coverImageKey,  String? languageCode,  TextDirectionKind direction,  double progress,  int totalReadSeconds,  bool isCompleted)  $default,) {final _that = this;
switch (_that) {
case _ReadingHistoryEntry():
return $default(_that.pieceId,_that.title,_that.lastReadAt,_that.authorName,_that.authorUsername,_that.slug,_that.coverImageKey,_that.languageCode,_that.direction,_that.progress,_that.totalReadSeconds,_that.isCompleted);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String pieceId,  String title,  DateTime lastReadAt,  String authorName,  String? authorUsername,  String? slug,  String? coverImageKey,  String? languageCode,  TextDirectionKind direction,  double progress,  int totalReadSeconds,  bool isCompleted)?  $default,) {final _that = this;
switch (_that) {
case _ReadingHistoryEntry() when $default != null:
return $default(_that.pieceId,_that.title,_that.lastReadAt,_that.authorName,_that.authorUsername,_that.slug,_that.coverImageKey,_that.languageCode,_that.direction,_that.progress,_that.totalReadSeconds,_that.isCompleted);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReadingHistoryEntry extends ReadingHistoryEntry {
  const _ReadingHistoryEntry({required this.pieceId, required this.title, required this.lastReadAt, this.authorName = '', this.authorUsername, this.slug, this.coverImageKey, this.languageCode, this.direction = TextDirectionKind.ltr, this.progress = 0, this.totalReadSeconds = 0, this.isCompleted = false}): super._();
  factory _ReadingHistoryEntry.fromJson(Map<String, dynamic> json) => _$ReadingHistoryEntryFromJson(json);

@override final  String pieceId;
@override final  String title;
@override final  DateTime lastReadAt;
@override@JsonKey() final  String authorName;
@override final  String? authorUsername;
@override final  String? slug;
@override final  String? coverImageKey;
@override final  String? languageCode;
@override@JsonKey() final  TextDirectionKind direction;
/// Last scroll position as a fraction 0.0–1.0 of the content extent.
@override@JsonKey() final  double progress;
/// Accumulated dwell time across sessions, in seconds.
@override@JsonKey() final  int totalReadSeconds;
/// Whether the reader reached the end (progress ≥ completion threshold).
@override@JsonKey() final  bool isCompleted;

/// Create a copy of ReadingHistoryEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReadingHistoryEntryCopyWith<_ReadingHistoryEntry> get copyWith => __$ReadingHistoryEntryCopyWithImpl<_ReadingHistoryEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReadingHistoryEntryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReadingHistoryEntry&&(identical(other.pieceId, pieceId) || other.pieceId == pieceId)&&(identical(other.title, title) || other.title == title)&&(identical(other.lastReadAt, lastReadAt) || other.lastReadAt == lastReadAt)&&(identical(other.authorName, authorName) || other.authorName == authorName)&&(identical(other.authorUsername, authorUsername) || other.authorUsername == authorUsername)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.coverImageKey, coverImageKey) || other.coverImageKey == coverImageKey)&&(identical(other.languageCode, languageCode) || other.languageCode == languageCode)&&(identical(other.direction, direction) || other.direction == direction)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.totalReadSeconds, totalReadSeconds) || other.totalReadSeconds == totalReadSeconds)&&(identical(other.isCompleted, isCompleted) || other.isCompleted == isCompleted));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,pieceId,title,lastReadAt,authorName,authorUsername,slug,coverImageKey,languageCode,direction,progress,totalReadSeconds,isCompleted);

@override
String toString() {
  return 'ReadingHistoryEntry(pieceId: $pieceId, title: $title, lastReadAt: $lastReadAt, authorName: $authorName, authorUsername: $authorUsername, slug: $slug, coverImageKey: $coverImageKey, languageCode: $languageCode, direction: $direction, progress: $progress, totalReadSeconds: $totalReadSeconds, isCompleted: $isCompleted)';
}


}

/// @nodoc
abstract mixin class _$ReadingHistoryEntryCopyWith<$Res> implements $ReadingHistoryEntryCopyWith<$Res> {
  factory _$ReadingHistoryEntryCopyWith(_ReadingHistoryEntry value, $Res Function(_ReadingHistoryEntry) _then) = __$ReadingHistoryEntryCopyWithImpl;
@override @useResult
$Res call({
 String pieceId, String title, DateTime lastReadAt, String authorName, String? authorUsername, String? slug, String? coverImageKey, String? languageCode, TextDirectionKind direction, double progress, int totalReadSeconds, bool isCompleted
});




}
/// @nodoc
class __$ReadingHistoryEntryCopyWithImpl<$Res>
    implements _$ReadingHistoryEntryCopyWith<$Res> {
  __$ReadingHistoryEntryCopyWithImpl(this._self, this._then);

  final _ReadingHistoryEntry _self;
  final $Res Function(_ReadingHistoryEntry) _then;

/// Create a copy of ReadingHistoryEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? pieceId = null,Object? title = null,Object? lastReadAt = null,Object? authorName = null,Object? authorUsername = freezed,Object? slug = freezed,Object? coverImageKey = freezed,Object? languageCode = freezed,Object? direction = null,Object? progress = null,Object? totalReadSeconds = null,Object? isCompleted = null,}) {
  return _then(_ReadingHistoryEntry(
pieceId: null == pieceId ? _self.pieceId : pieceId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,lastReadAt: null == lastReadAt ? _self.lastReadAt : lastReadAt // ignore: cast_nullable_to_non_nullable
as DateTime,authorName: null == authorName ? _self.authorName : authorName // ignore: cast_nullable_to_non_nullable
as String,authorUsername: freezed == authorUsername ? _self.authorUsername : authorUsername // ignore: cast_nullable_to_non_nullable
as String?,slug: freezed == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String?,coverImageKey: freezed == coverImageKey ? _self.coverImageKey : coverImageKey // ignore: cast_nullable_to_non_nullable
as String?,languageCode: freezed == languageCode ? _self.languageCode : languageCode // ignore: cast_nullable_to_non_nullable
as String?,direction: null == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as TextDirectionKind,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double,totalReadSeconds: null == totalReadSeconds ? _self.totalReadSeconds : totalReadSeconds // ignore: cast_nullable_to_non_nullable
as int,isCompleted: null == isCompleted ? _self.isCompleted : isCompleted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on

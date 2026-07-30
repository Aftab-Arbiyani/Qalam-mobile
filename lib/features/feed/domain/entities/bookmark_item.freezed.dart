// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'bookmark_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BookmarkItem {

 String get pieceId; String get title; String? get slug; DateTime get bookmarkedAt;
/// Create a copy of BookmarkItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BookmarkItemCopyWith<BookmarkItem> get copyWith => _$BookmarkItemCopyWithImpl<BookmarkItem>(this as BookmarkItem, _$identity);

  /// Serializes this BookmarkItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BookmarkItem&&(identical(other.pieceId, pieceId) || other.pieceId == pieceId)&&(identical(other.title, title) || other.title == title)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.bookmarkedAt, bookmarkedAt) || other.bookmarkedAt == bookmarkedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,pieceId,title,slug,bookmarkedAt);

@override
String toString() {
  return 'BookmarkItem(pieceId: $pieceId, title: $title, slug: $slug, bookmarkedAt: $bookmarkedAt)';
}


}

/// @nodoc
abstract mixin class $BookmarkItemCopyWith<$Res>  {
  factory $BookmarkItemCopyWith(BookmarkItem value, $Res Function(BookmarkItem) _then) = _$BookmarkItemCopyWithImpl;
@useResult
$Res call({
 String pieceId, String title, String? slug, DateTime bookmarkedAt
});




}
/// @nodoc
class _$BookmarkItemCopyWithImpl<$Res>
    implements $BookmarkItemCopyWith<$Res> {
  _$BookmarkItemCopyWithImpl(this._self, this._then);

  final BookmarkItem _self;
  final $Res Function(BookmarkItem) _then;

/// Create a copy of BookmarkItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? pieceId = null,Object? title = null,Object? slug = freezed,Object? bookmarkedAt = null,}) {
  return _then(_self.copyWith(
pieceId: null == pieceId ? _self.pieceId : pieceId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,slug: freezed == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String?,bookmarkedAt: null == bookmarkedAt ? _self.bookmarkedAt : bookmarkedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [BookmarkItem].
extension BookmarkItemPatterns on BookmarkItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BookmarkItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BookmarkItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BookmarkItem value)  $default,){
final _that = this;
switch (_that) {
case _BookmarkItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BookmarkItem value)?  $default,){
final _that = this;
switch (_that) {
case _BookmarkItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String pieceId,  String title,  String? slug,  DateTime bookmarkedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BookmarkItem() when $default != null:
return $default(_that.pieceId,_that.title,_that.slug,_that.bookmarkedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String pieceId,  String title,  String? slug,  DateTime bookmarkedAt)  $default,) {final _that = this;
switch (_that) {
case _BookmarkItem():
return $default(_that.pieceId,_that.title,_that.slug,_that.bookmarkedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String pieceId,  String title,  String? slug,  DateTime bookmarkedAt)?  $default,) {final _that = this;
switch (_that) {
case _BookmarkItem() when $default != null:
return $default(_that.pieceId,_that.title,_that.slug,_that.bookmarkedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BookmarkItem implements BookmarkItem {
  const _BookmarkItem({required this.pieceId, required this.title, this.slug, required this.bookmarkedAt});
  factory _BookmarkItem.fromJson(Map<String, dynamic> json) => _$BookmarkItemFromJson(json);

@override final  String pieceId;
@override final  String title;
@override final  String? slug;
@override final  DateTime bookmarkedAt;

/// Create a copy of BookmarkItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BookmarkItemCopyWith<_BookmarkItem> get copyWith => __$BookmarkItemCopyWithImpl<_BookmarkItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BookmarkItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BookmarkItem&&(identical(other.pieceId, pieceId) || other.pieceId == pieceId)&&(identical(other.title, title) || other.title == title)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.bookmarkedAt, bookmarkedAt) || other.bookmarkedAt == bookmarkedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,pieceId,title,slug,bookmarkedAt);

@override
String toString() {
  return 'BookmarkItem(pieceId: $pieceId, title: $title, slug: $slug, bookmarkedAt: $bookmarkedAt)';
}


}

/// @nodoc
abstract mixin class _$BookmarkItemCopyWith<$Res> implements $BookmarkItemCopyWith<$Res> {
  factory _$BookmarkItemCopyWith(_BookmarkItem value, $Res Function(_BookmarkItem) _then) = __$BookmarkItemCopyWithImpl;
@override @useResult
$Res call({
 String pieceId, String title, String? slug, DateTime bookmarkedAt
});




}
/// @nodoc
class __$BookmarkItemCopyWithImpl<$Res>
    implements _$BookmarkItemCopyWith<$Res> {
  __$BookmarkItemCopyWithImpl(this._self, this._then);

  final _BookmarkItem _self;
  final $Res Function(_BookmarkItem) _then;

/// Create a copy of BookmarkItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? pieceId = null,Object? title = null,Object? slug = freezed,Object? bookmarkedAt = null,}) {
  return _then(_BookmarkItem(
pieceId: null == pieceId ? _self.pieceId : pieceId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,slug: freezed == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String?,bookmarkedAt: null == bookmarkedAt ? _self.bookmarkedAt : bookmarkedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on

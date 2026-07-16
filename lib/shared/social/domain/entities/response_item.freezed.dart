// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'response_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ResponseAuthor {

 String get username; String? get penName;
/// Create a copy of ResponseAuthor
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ResponseAuthorCopyWith<ResponseAuthor> get copyWith => _$ResponseAuthorCopyWithImpl<ResponseAuthor>(this as ResponseAuthor, _$identity);

  /// Serializes this ResponseAuthor to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ResponseAuthor&&(identical(other.username, username) || other.username == username)&&(identical(other.penName, penName) || other.penName == penName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,username,penName);

@override
String toString() {
  return 'ResponseAuthor(username: $username, penName: $penName)';
}


}

/// @nodoc
abstract mixin class $ResponseAuthorCopyWith<$Res>  {
  factory $ResponseAuthorCopyWith(ResponseAuthor value, $Res Function(ResponseAuthor) _then) = _$ResponseAuthorCopyWithImpl;
@useResult
$Res call({
 String username, String? penName
});




}
/// @nodoc
class _$ResponseAuthorCopyWithImpl<$Res>
    implements $ResponseAuthorCopyWith<$Res> {
  _$ResponseAuthorCopyWithImpl(this._self, this._then);

  final ResponseAuthor _self;
  final $Res Function(ResponseAuthor) _then;

/// Create a copy of ResponseAuthor
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? username = null,Object? penName = freezed,}) {
  return _then(_self.copyWith(
username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,penName: freezed == penName ? _self.penName : penName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ResponseAuthor].
extension ResponseAuthorPatterns on ResponseAuthor {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ResponseAuthor value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ResponseAuthor() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ResponseAuthor value)  $default,){
final _that = this;
switch (_that) {
case _ResponseAuthor():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ResponseAuthor value)?  $default,){
final _that = this;
switch (_that) {
case _ResponseAuthor() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String username,  String? penName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ResponseAuthor() when $default != null:
return $default(_that.username,_that.penName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String username,  String? penName)  $default,) {final _that = this;
switch (_that) {
case _ResponseAuthor():
return $default(_that.username,_that.penName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String username,  String? penName)?  $default,) {final _that = this;
switch (_that) {
case _ResponseAuthor() when $default != null:
return $default(_that.username,_that.penName);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ResponseAuthor extends ResponseAuthor {
  const _ResponseAuthor({required this.username, this.penName}): super._();
  factory _ResponseAuthor.fromJson(Map<String, dynamic> json) => _$ResponseAuthorFromJson(json);

@override final  String username;
@override final  String? penName;

/// Create a copy of ResponseAuthor
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ResponseAuthorCopyWith<_ResponseAuthor> get copyWith => __$ResponseAuthorCopyWithImpl<_ResponseAuthor>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ResponseAuthorToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ResponseAuthor&&(identical(other.username, username) || other.username == username)&&(identical(other.penName, penName) || other.penName == penName));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,username,penName);

@override
String toString() {
  return 'ResponseAuthor(username: $username, penName: $penName)';
}


}

/// @nodoc
abstract mixin class _$ResponseAuthorCopyWith<$Res> implements $ResponseAuthorCopyWith<$Res> {
  factory _$ResponseAuthorCopyWith(_ResponseAuthor value, $Res Function(_ResponseAuthor) _then) = __$ResponseAuthorCopyWithImpl;
@override @useResult
$Res call({
 String username, String? penName
});




}
/// @nodoc
class __$ResponseAuthorCopyWithImpl<$Res>
    implements _$ResponseAuthorCopyWith<$Res> {
  __$ResponseAuthorCopyWithImpl(this._self, this._then);

  final _ResponseAuthor _self;
  final $Res Function(_ResponseAuthor) _then;

/// Create a copy of ResponseAuthor
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? username = null,Object? penName = freezed,}) {
  return _then(_ResponseAuthor(
username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,penName: freezed == penName ? _self.penName : penName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ResponseItem {

 String get pieceId; String? get slug; String get title; String? get subtitle; ResponseAuthor get author; DateTime? get publishedAt; DateTime? get respondedAt;
/// Create a copy of ResponseItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ResponseItemCopyWith<ResponseItem> get copyWith => _$ResponseItemCopyWithImpl<ResponseItem>(this as ResponseItem, _$identity);

  /// Serializes this ResponseItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ResponseItem&&(identical(other.pieceId, pieceId) || other.pieceId == pieceId)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.title, title) || other.title == title)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle)&&(identical(other.author, author) || other.author == author)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&(identical(other.respondedAt, respondedAt) || other.respondedAt == respondedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,pieceId,slug,title,subtitle,author,publishedAt,respondedAt);

@override
String toString() {
  return 'ResponseItem(pieceId: $pieceId, slug: $slug, title: $title, subtitle: $subtitle, author: $author, publishedAt: $publishedAt, respondedAt: $respondedAt)';
}


}

/// @nodoc
abstract mixin class $ResponseItemCopyWith<$Res>  {
  factory $ResponseItemCopyWith(ResponseItem value, $Res Function(ResponseItem) _then) = _$ResponseItemCopyWithImpl;
@useResult
$Res call({
 String pieceId, String? slug, String title, String? subtitle, ResponseAuthor author, DateTime? publishedAt, DateTime? respondedAt
});


$ResponseAuthorCopyWith<$Res> get author;

}
/// @nodoc
class _$ResponseItemCopyWithImpl<$Res>
    implements $ResponseItemCopyWith<$Res> {
  _$ResponseItemCopyWithImpl(this._self, this._then);

  final ResponseItem _self;
  final $Res Function(ResponseItem) _then;

/// Create a copy of ResponseItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? pieceId = null,Object? slug = freezed,Object? title = null,Object? subtitle = freezed,Object? author = null,Object? publishedAt = freezed,Object? respondedAt = freezed,}) {
  return _then(_self.copyWith(
pieceId: null == pieceId ? _self.pieceId : pieceId // ignore: cast_nullable_to_non_nullable
as String,slug: freezed == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,subtitle: freezed == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String?,author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as ResponseAuthor,publishedAt: freezed == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,respondedAt: freezed == respondedAt ? _self.respondedAt : respondedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of ResponseItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResponseAuthorCopyWith<$Res> get author {
  
  return $ResponseAuthorCopyWith<$Res>(_self.author, (value) {
    return _then(_self.copyWith(author: value));
  });
}
}


/// Adds pattern-matching-related methods to [ResponseItem].
extension ResponseItemPatterns on ResponseItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ResponseItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ResponseItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ResponseItem value)  $default,){
final _that = this;
switch (_that) {
case _ResponseItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ResponseItem value)?  $default,){
final _that = this;
switch (_that) {
case _ResponseItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String pieceId,  String? slug,  String title,  String? subtitle,  ResponseAuthor author,  DateTime? publishedAt,  DateTime? respondedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ResponseItem() when $default != null:
return $default(_that.pieceId,_that.slug,_that.title,_that.subtitle,_that.author,_that.publishedAt,_that.respondedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String pieceId,  String? slug,  String title,  String? subtitle,  ResponseAuthor author,  DateTime? publishedAt,  DateTime? respondedAt)  $default,) {final _that = this;
switch (_that) {
case _ResponseItem():
return $default(_that.pieceId,_that.slug,_that.title,_that.subtitle,_that.author,_that.publishedAt,_that.respondedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String pieceId,  String? slug,  String title,  String? subtitle,  ResponseAuthor author,  DateTime? publishedAt,  DateTime? respondedAt)?  $default,) {final _that = this;
switch (_that) {
case _ResponseItem() when $default != null:
return $default(_that.pieceId,_that.slug,_that.title,_that.subtitle,_that.author,_that.publishedAt,_that.respondedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ResponseItem implements ResponseItem {
  const _ResponseItem({required this.pieceId, this.slug, this.title = '', this.subtitle, required this.author, this.publishedAt, this.respondedAt});
  factory _ResponseItem.fromJson(Map<String, dynamic> json) => _$ResponseItemFromJson(json);

@override final  String pieceId;
@override final  String? slug;
@override@JsonKey() final  String title;
@override final  String? subtitle;
@override final  ResponseAuthor author;
@override final  DateTime? publishedAt;
@override final  DateTime? respondedAt;

/// Create a copy of ResponseItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ResponseItemCopyWith<_ResponseItem> get copyWith => __$ResponseItemCopyWithImpl<_ResponseItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ResponseItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ResponseItem&&(identical(other.pieceId, pieceId) || other.pieceId == pieceId)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.title, title) || other.title == title)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle)&&(identical(other.author, author) || other.author == author)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt)&&(identical(other.respondedAt, respondedAt) || other.respondedAt == respondedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,pieceId,slug,title,subtitle,author,publishedAt,respondedAt);

@override
String toString() {
  return 'ResponseItem(pieceId: $pieceId, slug: $slug, title: $title, subtitle: $subtitle, author: $author, publishedAt: $publishedAt, respondedAt: $respondedAt)';
}


}

/// @nodoc
abstract mixin class _$ResponseItemCopyWith<$Res> implements $ResponseItemCopyWith<$Res> {
  factory _$ResponseItemCopyWith(_ResponseItem value, $Res Function(_ResponseItem) _then) = __$ResponseItemCopyWithImpl;
@override @useResult
$Res call({
 String pieceId, String? slug, String title, String? subtitle, ResponseAuthor author, DateTime? publishedAt, DateTime? respondedAt
});


@override $ResponseAuthorCopyWith<$Res> get author;

}
/// @nodoc
class __$ResponseItemCopyWithImpl<$Res>
    implements _$ResponseItemCopyWith<$Res> {
  __$ResponseItemCopyWithImpl(this._self, this._then);

  final _ResponseItem _self;
  final $Res Function(_ResponseItem) _then;

/// Create a copy of ResponseItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? pieceId = null,Object? slug = freezed,Object? title = null,Object? subtitle = freezed,Object? author = null,Object? publishedAt = freezed,Object? respondedAt = freezed,}) {
  return _then(_ResponseItem(
pieceId: null == pieceId ? _self.pieceId : pieceId // ignore: cast_nullable_to_non_nullable
as String,slug: freezed == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,subtitle: freezed == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String?,author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as ResponseAuthor,publishedAt: freezed == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,respondedAt: freezed == respondedAt ? _self.respondedAt : respondedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of ResponseItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ResponseAuthorCopyWith<$Res> get author {
  
  return $ResponseAuthorCopyWith<$Res>(_self.author, (value) {
    return _then(_self.copyWith(author: value));
  });
}
}

// dart format on

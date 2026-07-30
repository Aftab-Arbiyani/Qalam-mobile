// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'comment.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CommentAuthor {

 String get username; String? get penName; String? get avatarKey;
/// Create a copy of CommentAuthor
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommentAuthorCopyWith<CommentAuthor> get copyWith => _$CommentAuthorCopyWithImpl<CommentAuthor>(this as CommentAuthor, _$identity);

  /// Serializes this CommentAuthor to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CommentAuthor&&(identical(other.username, username) || other.username == username)&&(identical(other.penName, penName) || other.penName == penName)&&(identical(other.avatarKey, avatarKey) || other.avatarKey == avatarKey));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,username,penName,avatarKey);

@override
String toString() {
  return 'CommentAuthor(username: $username, penName: $penName, avatarKey: $avatarKey)';
}


}

/// @nodoc
abstract mixin class $CommentAuthorCopyWith<$Res>  {
  factory $CommentAuthorCopyWith(CommentAuthor value, $Res Function(CommentAuthor) _then) = _$CommentAuthorCopyWithImpl;
@useResult
$Res call({
 String username, String? penName, String? avatarKey
});




}
/// @nodoc
class _$CommentAuthorCopyWithImpl<$Res>
    implements $CommentAuthorCopyWith<$Res> {
  _$CommentAuthorCopyWithImpl(this._self, this._then);

  final CommentAuthor _self;
  final $Res Function(CommentAuthor) _then;

/// Create a copy of CommentAuthor
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? username = null,Object? penName = freezed,Object? avatarKey = freezed,}) {
  return _then(_self.copyWith(
username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,penName: freezed == penName ? _self.penName : penName // ignore: cast_nullable_to_non_nullable
as String?,avatarKey: freezed == avatarKey ? _self.avatarKey : avatarKey // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CommentAuthor].
extension CommentAuthorPatterns on CommentAuthor {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CommentAuthor value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CommentAuthor() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CommentAuthor value)  $default,){
final _that = this;
switch (_that) {
case _CommentAuthor():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CommentAuthor value)?  $default,){
final _that = this;
switch (_that) {
case _CommentAuthor() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String username,  String? penName,  String? avatarKey)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CommentAuthor() when $default != null:
return $default(_that.username,_that.penName,_that.avatarKey);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String username,  String? penName,  String? avatarKey)  $default,) {final _that = this;
switch (_that) {
case _CommentAuthor():
return $default(_that.username,_that.penName,_that.avatarKey);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String username,  String? penName,  String? avatarKey)?  $default,) {final _that = this;
switch (_that) {
case _CommentAuthor() when $default != null:
return $default(_that.username,_that.penName,_that.avatarKey);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CommentAuthor extends CommentAuthor {
  const _CommentAuthor({required this.username, this.penName, this.avatarKey}): super._();
  factory _CommentAuthor.fromJson(Map<String, dynamic> json) => _$CommentAuthorFromJson(json);

@override final  String username;
@override final  String? penName;
@override final  String? avatarKey;

/// Create a copy of CommentAuthor
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CommentAuthorCopyWith<_CommentAuthor> get copyWith => __$CommentAuthorCopyWithImpl<_CommentAuthor>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CommentAuthorToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CommentAuthor&&(identical(other.username, username) || other.username == username)&&(identical(other.penName, penName) || other.penName == penName)&&(identical(other.avatarKey, avatarKey) || other.avatarKey == avatarKey));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,username,penName,avatarKey);

@override
String toString() {
  return 'CommentAuthor(username: $username, penName: $penName, avatarKey: $avatarKey)';
}


}

/// @nodoc
abstract mixin class _$CommentAuthorCopyWith<$Res> implements $CommentAuthorCopyWith<$Res> {
  factory _$CommentAuthorCopyWith(_CommentAuthor value, $Res Function(_CommentAuthor) _then) = __$CommentAuthorCopyWithImpl;
@override @useResult
$Res call({
 String username, String? penName, String? avatarKey
});




}
/// @nodoc
class __$CommentAuthorCopyWithImpl<$Res>
    implements _$CommentAuthorCopyWith<$Res> {
  __$CommentAuthorCopyWithImpl(this._self, this._then);

  final _CommentAuthor _self;
  final $Res Function(_CommentAuthor) _then;

/// Create a copy of CommentAuthor
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? username = null,Object? penName = freezed,Object? avatarKey = freezed,}) {
  return _then(_CommentAuthor(
username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,penName: freezed == penName ? _self.penName : penName // ignore: cast_nullable_to_non_nullable
as String?,avatarKey: freezed == avatarKey ? _self.avatarKey : avatarKey // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$Comment {

 String get id; String? get parentId; int get depth; CommentAuthor? get author; String get body; bool get isDeleted; int get replyCount; DateTime? get editedAt; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of Comment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommentCopyWith<Comment> get copyWith => _$CommentCopyWithImpl<Comment>(this as Comment, _$identity);

  /// Serializes this Comment to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Comment&&(identical(other.id, id) || other.id == id)&&(identical(other.parentId, parentId) || other.parentId == parentId)&&(identical(other.depth, depth) || other.depth == depth)&&(identical(other.author, author) || other.author == author)&&(identical(other.body, body) || other.body == body)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted)&&(identical(other.replyCount, replyCount) || other.replyCount == replyCount)&&(identical(other.editedAt, editedAt) || other.editedAt == editedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,parentId,depth,author,body,isDeleted,replyCount,editedAt,createdAt,updatedAt);

@override
String toString() {
  return 'Comment(id: $id, parentId: $parentId, depth: $depth, author: $author, body: $body, isDeleted: $isDeleted, replyCount: $replyCount, editedAt: $editedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $CommentCopyWith<$Res>  {
  factory $CommentCopyWith(Comment value, $Res Function(Comment) _then) = _$CommentCopyWithImpl;
@useResult
$Res call({
 String id, String? parentId, int depth, CommentAuthor? author, String body, bool isDeleted, int replyCount, DateTime? editedAt, DateTime? createdAt, DateTime? updatedAt
});


$CommentAuthorCopyWith<$Res>? get author;

}
/// @nodoc
class _$CommentCopyWithImpl<$Res>
    implements $CommentCopyWith<$Res> {
  _$CommentCopyWithImpl(this._self, this._then);

  final Comment _self;
  final $Res Function(Comment) _then;

/// Create a copy of Comment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? parentId = freezed,Object? depth = null,Object? author = freezed,Object? body = null,Object? isDeleted = null,Object? replyCount = null,Object? editedAt = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,parentId: freezed == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as String?,depth: null == depth ? _self.depth : depth // ignore: cast_nullable_to_non_nullable
as int,author: freezed == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as CommentAuthor?,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,replyCount: null == replyCount ? _self.replyCount : replyCount // ignore: cast_nullable_to_non_nullable
as int,editedAt: freezed == editedAt ? _self.editedAt : editedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of Comment
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CommentAuthorCopyWith<$Res>? get author {
    if (_self.author == null) {
    return null;
  }

  return $CommentAuthorCopyWith<$Res>(_self.author!, (value) {
    return _then(_self.copyWith(author: value));
  });
}
}


/// Adds pattern-matching-related methods to [Comment].
extension CommentPatterns on Comment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Comment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Comment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Comment value)  $default,){
final _that = this;
switch (_that) {
case _Comment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Comment value)?  $default,){
final _that = this;
switch (_that) {
case _Comment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? parentId,  int depth,  CommentAuthor? author,  String body,  bool isDeleted,  int replyCount,  DateTime? editedAt,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Comment() when $default != null:
return $default(_that.id,_that.parentId,_that.depth,_that.author,_that.body,_that.isDeleted,_that.replyCount,_that.editedAt,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? parentId,  int depth,  CommentAuthor? author,  String body,  bool isDeleted,  int replyCount,  DateTime? editedAt,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Comment():
return $default(_that.id,_that.parentId,_that.depth,_that.author,_that.body,_that.isDeleted,_that.replyCount,_that.editedAt,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? parentId,  int depth,  CommentAuthor? author,  String body,  bool isDeleted,  int replyCount,  DateTime? editedAt,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Comment() when $default != null:
return $default(_that.id,_that.parentId,_that.depth,_that.author,_that.body,_that.isDeleted,_that.replyCount,_that.editedAt,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Comment extends Comment {
  const _Comment({required this.id, this.parentId, this.depth = 1, this.author, this.body = '', this.isDeleted = false, this.replyCount = 0, this.editedAt, this.createdAt, this.updatedAt}): super._();
  factory _Comment.fromJson(Map<String, dynamic> json) => _$CommentFromJson(json);

@override final  String id;
@override final  String? parentId;
@override@JsonKey() final  int depth;
@override final  CommentAuthor? author;
@override@JsonKey() final  String body;
@override@JsonKey() final  bool isDeleted;
@override@JsonKey() final  int replyCount;
@override final  DateTime? editedAt;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of Comment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CommentCopyWith<_Comment> get copyWith => __$CommentCopyWithImpl<_Comment>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CommentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Comment&&(identical(other.id, id) || other.id == id)&&(identical(other.parentId, parentId) || other.parentId == parentId)&&(identical(other.depth, depth) || other.depth == depth)&&(identical(other.author, author) || other.author == author)&&(identical(other.body, body) || other.body == body)&&(identical(other.isDeleted, isDeleted) || other.isDeleted == isDeleted)&&(identical(other.replyCount, replyCount) || other.replyCount == replyCount)&&(identical(other.editedAt, editedAt) || other.editedAt == editedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,parentId,depth,author,body,isDeleted,replyCount,editedAt,createdAt,updatedAt);

@override
String toString() {
  return 'Comment(id: $id, parentId: $parentId, depth: $depth, author: $author, body: $body, isDeleted: $isDeleted, replyCount: $replyCount, editedAt: $editedAt, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$CommentCopyWith<$Res> implements $CommentCopyWith<$Res> {
  factory _$CommentCopyWith(_Comment value, $Res Function(_Comment) _then) = __$CommentCopyWithImpl;
@override @useResult
$Res call({
 String id, String? parentId, int depth, CommentAuthor? author, String body, bool isDeleted, int replyCount, DateTime? editedAt, DateTime? createdAt, DateTime? updatedAt
});


@override $CommentAuthorCopyWith<$Res>? get author;

}
/// @nodoc
class __$CommentCopyWithImpl<$Res>
    implements _$CommentCopyWith<$Res> {
  __$CommentCopyWithImpl(this._self, this._then);

  final _Comment _self;
  final $Res Function(_Comment) _then;

/// Create a copy of Comment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? parentId = freezed,Object? depth = null,Object? author = freezed,Object? body = null,Object? isDeleted = null,Object? replyCount = null,Object? editedAt = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_Comment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,parentId: freezed == parentId ? _self.parentId : parentId // ignore: cast_nullable_to_non_nullable
as String?,depth: null == depth ? _self.depth : depth // ignore: cast_nullable_to_non_nullable
as int,author: freezed == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as CommentAuthor?,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,isDeleted: null == isDeleted ? _self.isDeleted : isDeleted // ignore: cast_nullable_to_non_nullable
as bool,replyCount: null == replyCount ? _self.replyCount : replyCount // ignore: cast_nullable_to_non_nullable
as int,editedAt: freezed == editedAt ? _self.editedAt : editedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of Comment
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CommentAuthorCopyWith<$Res>? get author {
    if (_self.author == null) {
    return null;
  }

  return $CommentAuthorCopyWith<$Res>(_self.author!, (value) {
    return _then(_self.copyWith(author: value));
  });
}
}

// dart format on

// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'writer_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WriterProfile {

 String get id; String get username; String get penName; String? get avatarKey; String? get bio; bool get isPrivate; int get followersCount; int get followingCount; int get piecesCount; bool get isSelf; bool get isFollowing; bool get hasPendingRequest; bool get restricted;
/// Create a copy of WriterProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WriterProfileCopyWith<WriterProfile> get copyWith => _$WriterProfileCopyWithImpl<WriterProfile>(this as WriterProfile, _$identity);

  /// Serializes this WriterProfile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WriterProfile&&(identical(other.id, id) || other.id == id)&&(identical(other.username, username) || other.username == username)&&(identical(other.penName, penName) || other.penName == penName)&&(identical(other.avatarKey, avatarKey) || other.avatarKey == avatarKey)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.isPrivate, isPrivate) || other.isPrivate == isPrivate)&&(identical(other.followersCount, followersCount) || other.followersCount == followersCount)&&(identical(other.followingCount, followingCount) || other.followingCount == followingCount)&&(identical(other.piecesCount, piecesCount) || other.piecesCount == piecesCount)&&(identical(other.isSelf, isSelf) || other.isSelf == isSelf)&&(identical(other.isFollowing, isFollowing) || other.isFollowing == isFollowing)&&(identical(other.hasPendingRequest, hasPendingRequest) || other.hasPendingRequest == hasPendingRequest)&&(identical(other.restricted, restricted) || other.restricted == restricted));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,username,penName,avatarKey,bio,isPrivate,followersCount,followingCount,piecesCount,isSelf,isFollowing,hasPendingRequest,restricted);

@override
String toString() {
  return 'WriterProfile(id: $id, username: $username, penName: $penName, avatarKey: $avatarKey, bio: $bio, isPrivate: $isPrivate, followersCount: $followersCount, followingCount: $followingCount, piecesCount: $piecesCount, isSelf: $isSelf, isFollowing: $isFollowing, hasPendingRequest: $hasPendingRequest, restricted: $restricted)';
}


}

/// @nodoc
abstract mixin class $WriterProfileCopyWith<$Res>  {
  factory $WriterProfileCopyWith(WriterProfile value, $Res Function(WriterProfile) _then) = _$WriterProfileCopyWithImpl;
@useResult
$Res call({
 String id, String username, String penName, String? avatarKey, String? bio, bool isPrivate, int followersCount, int followingCount, int piecesCount, bool isSelf, bool isFollowing, bool hasPendingRequest, bool restricted
});




}
/// @nodoc
class _$WriterProfileCopyWithImpl<$Res>
    implements $WriterProfileCopyWith<$Res> {
  _$WriterProfileCopyWithImpl(this._self, this._then);

  final WriterProfile _self;
  final $Res Function(WriterProfile) _then;

/// Create a copy of WriterProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? username = null,Object? penName = null,Object? avatarKey = freezed,Object? bio = freezed,Object? isPrivate = null,Object? followersCount = null,Object? followingCount = null,Object? piecesCount = null,Object? isSelf = null,Object? isFollowing = null,Object? hasPendingRequest = null,Object? restricted = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,penName: null == penName ? _self.penName : penName // ignore: cast_nullable_to_non_nullable
as String,avatarKey: freezed == avatarKey ? _self.avatarKey : avatarKey // ignore: cast_nullable_to_non_nullable
as String?,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,isPrivate: null == isPrivate ? _self.isPrivate : isPrivate // ignore: cast_nullable_to_non_nullable
as bool,followersCount: null == followersCount ? _self.followersCount : followersCount // ignore: cast_nullable_to_non_nullable
as int,followingCount: null == followingCount ? _self.followingCount : followingCount // ignore: cast_nullable_to_non_nullable
as int,piecesCount: null == piecesCount ? _self.piecesCount : piecesCount // ignore: cast_nullable_to_non_nullable
as int,isSelf: null == isSelf ? _self.isSelf : isSelf // ignore: cast_nullable_to_non_nullable
as bool,isFollowing: null == isFollowing ? _self.isFollowing : isFollowing // ignore: cast_nullable_to_non_nullable
as bool,hasPendingRequest: null == hasPendingRequest ? _self.hasPendingRequest : hasPendingRequest // ignore: cast_nullable_to_non_nullable
as bool,restricted: null == restricted ? _self.restricted : restricted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [WriterProfile].
extension WriterProfilePatterns on WriterProfile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WriterProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WriterProfile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WriterProfile value)  $default,){
final _that = this;
switch (_that) {
case _WriterProfile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WriterProfile value)?  $default,){
final _that = this;
switch (_that) {
case _WriterProfile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String username,  String penName,  String? avatarKey,  String? bio,  bool isPrivate,  int followersCount,  int followingCount,  int piecesCount,  bool isSelf,  bool isFollowing,  bool hasPendingRequest,  bool restricted)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WriterProfile() when $default != null:
return $default(_that.id,_that.username,_that.penName,_that.avatarKey,_that.bio,_that.isPrivate,_that.followersCount,_that.followingCount,_that.piecesCount,_that.isSelf,_that.isFollowing,_that.hasPendingRequest,_that.restricted);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String username,  String penName,  String? avatarKey,  String? bio,  bool isPrivate,  int followersCount,  int followingCount,  int piecesCount,  bool isSelf,  bool isFollowing,  bool hasPendingRequest,  bool restricted)  $default,) {final _that = this;
switch (_that) {
case _WriterProfile():
return $default(_that.id,_that.username,_that.penName,_that.avatarKey,_that.bio,_that.isPrivate,_that.followersCount,_that.followingCount,_that.piecesCount,_that.isSelf,_that.isFollowing,_that.hasPendingRequest,_that.restricted);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String username,  String penName,  String? avatarKey,  String? bio,  bool isPrivate,  int followersCount,  int followingCount,  int piecesCount,  bool isSelf,  bool isFollowing,  bool hasPendingRequest,  bool restricted)?  $default,) {final _that = this;
switch (_that) {
case _WriterProfile() when $default != null:
return $default(_that.id,_that.username,_that.penName,_that.avatarKey,_that.bio,_that.isPrivate,_that.followersCount,_that.followingCount,_that.piecesCount,_that.isSelf,_that.isFollowing,_that.hasPendingRequest,_that.restricted);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WriterProfile extends WriterProfile {
  const _WriterProfile({required this.id, required this.username, this.penName = '', this.avatarKey, this.bio, this.isPrivate = false, this.followersCount = 0, this.followingCount = 0, this.piecesCount = 0, this.isSelf = false, this.isFollowing = false, this.hasPendingRequest = false, this.restricted = false}): super._();
  factory _WriterProfile.fromJson(Map<String, dynamic> json) => _$WriterProfileFromJson(json);

@override final  String id;
@override final  String username;
@override@JsonKey() final  String penName;
@override final  String? avatarKey;
@override final  String? bio;
@override@JsonKey() final  bool isPrivate;
@override@JsonKey() final  int followersCount;
@override@JsonKey() final  int followingCount;
@override@JsonKey() final  int piecesCount;
@override@JsonKey() final  bool isSelf;
@override@JsonKey() final  bool isFollowing;
@override@JsonKey() final  bool hasPendingRequest;
@override@JsonKey() final  bool restricted;

/// Create a copy of WriterProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WriterProfileCopyWith<_WriterProfile> get copyWith => __$WriterProfileCopyWithImpl<_WriterProfile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WriterProfileToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WriterProfile&&(identical(other.id, id) || other.id == id)&&(identical(other.username, username) || other.username == username)&&(identical(other.penName, penName) || other.penName == penName)&&(identical(other.avatarKey, avatarKey) || other.avatarKey == avatarKey)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.isPrivate, isPrivate) || other.isPrivate == isPrivate)&&(identical(other.followersCount, followersCount) || other.followersCount == followersCount)&&(identical(other.followingCount, followingCount) || other.followingCount == followingCount)&&(identical(other.piecesCount, piecesCount) || other.piecesCount == piecesCount)&&(identical(other.isSelf, isSelf) || other.isSelf == isSelf)&&(identical(other.isFollowing, isFollowing) || other.isFollowing == isFollowing)&&(identical(other.hasPendingRequest, hasPendingRequest) || other.hasPendingRequest == hasPendingRequest)&&(identical(other.restricted, restricted) || other.restricted == restricted));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,username,penName,avatarKey,bio,isPrivate,followersCount,followingCount,piecesCount,isSelf,isFollowing,hasPendingRequest,restricted);

@override
String toString() {
  return 'WriterProfile(id: $id, username: $username, penName: $penName, avatarKey: $avatarKey, bio: $bio, isPrivate: $isPrivate, followersCount: $followersCount, followingCount: $followingCount, piecesCount: $piecesCount, isSelf: $isSelf, isFollowing: $isFollowing, hasPendingRequest: $hasPendingRequest, restricted: $restricted)';
}


}

/// @nodoc
abstract mixin class _$WriterProfileCopyWith<$Res> implements $WriterProfileCopyWith<$Res> {
  factory _$WriterProfileCopyWith(_WriterProfile value, $Res Function(_WriterProfile) _then) = __$WriterProfileCopyWithImpl;
@override @useResult
$Res call({
 String id, String username, String penName, String? avatarKey, String? bio, bool isPrivate, int followersCount, int followingCount, int piecesCount, bool isSelf, bool isFollowing, bool hasPendingRequest, bool restricted
});




}
/// @nodoc
class __$WriterProfileCopyWithImpl<$Res>
    implements _$WriterProfileCopyWith<$Res> {
  __$WriterProfileCopyWithImpl(this._self, this._then);

  final _WriterProfile _self;
  final $Res Function(_WriterProfile) _then;

/// Create a copy of WriterProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? username = null,Object? penName = null,Object? avatarKey = freezed,Object? bio = freezed,Object? isPrivate = null,Object? followersCount = null,Object? followingCount = null,Object? piecesCount = null,Object? isSelf = null,Object? isFollowing = null,Object? hasPendingRequest = null,Object? restricted = null,}) {
  return _then(_WriterProfile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,penName: null == penName ? _self.penName : penName // ignore: cast_nullable_to_non_nullable
as String,avatarKey: freezed == avatarKey ? _self.avatarKey : avatarKey // ignore: cast_nullable_to_non_nullable
as String?,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,isPrivate: null == isPrivate ? _self.isPrivate : isPrivate // ignore: cast_nullable_to_non_nullable
as bool,followersCount: null == followersCount ? _self.followersCount : followersCount // ignore: cast_nullable_to_non_nullable
as int,followingCount: null == followingCount ? _self.followingCount : followingCount // ignore: cast_nullable_to_non_nullable
as int,piecesCount: null == piecesCount ? _self.piecesCount : piecesCount // ignore: cast_nullable_to_non_nullable
as int,isSelf: null == isSelf ? _self.isSelf : isSelf // ignore: cast_nullable_to_non_nullable
as bool,isFollowing: null == isFollowing ? _self.isFollowing : isFollowing // ignore: cast_nullable_to_non_nullable
as bool,hasPendingRequest: null == hasPendingRequest ? _self.hasPendingRequest : hasPendingRequest // ignore: cast_nullable_to_non_nullable
as bool,restricted: null == restricted ? _self.restricted : restricted // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on

// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'follow_user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FollowUser {

 String get id; String get username; String? get penName; String? get avatarKey;
/// Create a copy of FollowUser
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FollowUserCopyWith<FollowUser> get copyWith => _$FollowUserCopyWithImpl<FollowUser>(this as FollowUser, _$identity);

  /// Serializes this FollowUser to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FollowUser&&(identical(other.id, id) || other.id == id)&&(identical(other.username, username) || other.username == username)&&(identical(other.penName, penName) || other.penName == penName)&&(identical(other.avatarKey, avatarKey) || other.avatarKey == avatarKey));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,username,penName,avatarKey);

@override
String toString() {
  return 'FollowUser(id: $id, username: $username, penName: $penName, avatarKey: $avatarKey)';
}


}

/// @nodoc
abstract mixin class $FollowUserCopyWith<$Res>  {
  factory $FollowUserCopyWith(FollowUser value, $Res Function(FollowUser) _then) = _$FollowUserCopyWithImpl;
@useResult
$Res call({
 String id, String username, String? penName, String? avatarKey
});




}
/// @nodoc
class _$FollowUserCopyWithImpl<$Res>
    implements $FollowUserCopyWith<$Res> {
  _$FollowUserCopyWithImpl(this._self, this._then);

  final FollowUser _self;
  final $Res Function(FollowUser) _then;

/// Create a copy of FollowUser
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? username = null,Object? penName = freezed,Object? avatarKey = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,penName: freezed == penName ? _self.penName : penName // ignore: cast_nullable_to_non_nullable
as String?,avatarKey: freezed == avatarKey ? _self.avatarKey : avatarKey // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [FollowUser].
extension FollowUserPatterns on FollowUser {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FollowUser value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FollowUser() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FollowUser value)  $default,){
final _that = this;
switch (_that) {
case _FollowUser():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FollowUser value)?  $default,){
final _that = this;
switch (_that) {
case _FollowUser() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String username,  String? penName,  String? avatarKey)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FollowUser() when $default != null:
return $default(_that.id,_that.username,_that.penName,_that.avatarKey);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String username,  String? penName,  String? avatarKey)  $default,) {final _that = this;
switch (_that) {
case _FollowUser():
return $default(_that.id,_that.username,_that.penName,_that.avatarKey);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String username,  String? penName,  String? avatarKey)?  $default,) {final _that = this;
switch (_that) {
case _FollowUser() when $default != null:
return $default(_that.id,_that.username,_that.penName,_that.avatarKey);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FollowUser extends FollowUser {
  const _FollowUser({required this.id, required this.username, this.penName, this.avatarKey}): super._();
  factory _FollowUser.fromJson(Map<String, dynamic> json) => _$FollowUserFromJson(json);

@override final  String id;
@override final  String username;
@override final  String? penName;
@override final  String? avatarKey;

/// Create a copy of FollowUser
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FollowUserCopyWith<_FollowUser> get copyWith => __$FollowUserCopyWithImpl<_FollowUser>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FollowUserToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FollowUser&&(identical(other.id, id) || other.id == id)&&(identical(other.username, username) || other.username == username)&&(identical(other.penName, penName) || other.penName == penName)&&(identical(other.avatarKey, avatarKey) || other.avatarKey == avatarKey));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,username,penName,avatarKey);

@override
String toString() {
  return 'FollowUser(id: $id, username: $username, penName: $penName, avatarKey: $avatarKey)';
}


}

/// @nodoc
abstract mixin class _$FollowUserCopyWith<$Res> implements $FollowUserCopyWith<$Res> {
  factory _$FollowUserCopyWith(_FollowUser value, $Res Function(_FollowUser) _then) = __$FollowUserCopyWithImpl;
@override @useResult
$Res call({
 String id, String username, String? penName, String? avatarKey
});




}
/// @nodoc
class __$FollowUserCopyWithImpl<$Res>
    implements _$FollowUserCopyWith<$Res> {
  __$FollowUserCopyWithImpl(this._self, this._then);

  final _FollowUser _self;
  final $Res Function(_FollowUser) _then;

/// Create a copy of FollowUser
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? username = null,Object? penName = freezed,Object? avatarKey = freezed,}) {
  return _then(_FollowUser(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,penName: freezed == penName ? _self.penName : penName // ignore: cast_nullable_to_non_nullable
as String?,avatarKey: freezed == avatarKey ? _self.avatarKey : avatarKey // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$FollowRequest {

 String get id; FollowUser get requester; DateTime? get requestedAt;
/// Create a copy of FollowRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FollowRequestCopyWith<FollowRequest> get copyWith => _$FollowRequestCopyWithImpl<FollowRequest>(this as FollowRequest, _$identity);

  /// Serializes this FollowRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FollowRequest&&(identical(other.id, id) || other.id == id)&&(identical(other.requester, requester) || other.requester == requester)&&(identical(other.requestedAt, requestedAt) || other.requestedAt == requestedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,requester,requestedAt);

@override
String toString() {
  return 'FollowRequest(id: $id, requester: $requester, requestedAt: $requestedAt)';
}


}

/// @nodoc
abstract mixin class $FollowRequestCopyWith<$Res>  {
  factory $FollowRequestCopyWith(FollowRequest value, $Res Function(FollowRequest) _then) = _$FollowRequestCopyWithImpl;
@useResult
$Res call({
 String id, FollowUser requester, DateTime? requestedAt
});


$FollowUserCopyWith<$Res> get requester;

}
/// @nodoc
class _$FollowRequestCopyWithImpl<$Res>
    implements $FollowRequestCopyWith<$Res> {
  _$FollowRequestCopyWithImpl(this._self, this._then);

  final FollowRequest _self;
  final $Res Function(FollowRequest) _then;

/// Create a copy of FollowRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? requester = null,Object? requestedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,requester: null == requester ? _self.requester : requester // ignore: cast_nullable_to_non_nullable
as FollowUser,requestedAt: freezed == requestedAt ? _self.requestedAt : requestedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of FollowRequest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FollowUserCopyWith<$Res> get requester {
  
  return $FollowUserCopyWith<$Res>(_self.requester, (value) {
    return _then(_self.copyWith(requester: value));
  });
}
}


/// Adds pattern-matching-related methods to [FollowRequest].
extension FollowRequestPatterns on FollowRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FollowRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FollowRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FollowRequest value)  $default,){
final _that = this;
switch (_that) {
case _FollowRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FollowRequest value)?  $default,){
final _that = this;
switch (_that) {
case _FollowRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  FollowUser requester,  DateTime? requestedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FollowRequest() when $default != null:
return $default(_that.id,_that.requester,_that.requestedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  FollowUser requester,  DateTime? requestedAt)  $default,) {final _that = this;
switch (_that) {
case _FollowRequest():
return $default(_that.id,_that.requester,_that.requestedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  FollowUser requester,  DateTime? requestedAt)?  $default,) {final _that = this;
switch (_that) {
case _FollowRequest() when $default != null:
return $default(_that.id,_that.requester,_that.requestedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FollowRequest implements FollowRequest {
  const _FollowRequest({required this.id, required this.requester, this.requestedAt});
  factory _FollowRequest.fromJson(Map<String, dynamic> json) => _$FollowRequestFromJson(json);

@override final  String id;
@override final  FollowUser requester;
@override final  DateTime? requestedAt;

/// Create a copy of FollowRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FollowRequestCopyWith<_FollowRequest> get copyWith => __$FollowRequestCopyWithImpl<_FollowRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FollowRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FollowRequest&&(identical(other.id, id) || other.id == id)&&(identical(other.requester, requester) || other.requester == requester)&&(identical(other.requestedAt, requestedAt) || other.requestedAt == requestedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,requester,requestedAt);

@override
String toString() {
  return 'FollowRequest(id: $id, requester: $requester, requestedAt: $requestedAt)';
}


}

/// @nodoc
abstract mixin class _$FollowRequestCopyWith<$Res> implements $FollowRequestCopyWith<$Res> {
  factory _$FollowRequestCopyWith(_FollowRequest value, $Res Function(_FollowRequest) _then) = __$FollowRequestCopyWithImpl;
@override @useResult
$Res call({
 String id, FollowUser requester, DateTime? requestedAt
});


@override $FollowUserCopyWith<$Res> get requester;

}
/// @nodoc
class __$FollowRequestCopyWithImpl<$Res>
    implements _$FollowRequestCopyWith<$Res> {
  __$FollowRequestCopyWithImpl(this._self, this._then);

  final _FollowRequest _self;
  final $Res Function(_FollowRequest) _then;

/// Create a copy of FollowRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? requester = null,Object? requestedAt = freezed,}) {
  return _then(_FollowRequest(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,requester: null == requester ? _self.requester : requester // ignore: cast_nullable_to_non_nullable
as FollowUser,requestedAt: freezed == requestedAt ? _self.requestedAt : requestedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of FollowRequest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FollowUserCopyWith<$Res> get requester {
  
  return $FollowUserCopyWith<$Res>(_self.requester, (value) {
    return _then(_self.copyWith(requester: value));
  });
}
}

// dart format on

// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'social_auth_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SocialAuthState {

 SocialAuthStatus get status; SocialProvider? get provider; Failure? get error;
/// Create a copy of SocialAuthState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SocialAuthStateCopyWith<SocialAuthState> get copyWith => _$SocialAuthStateCopyWithImpl<SocialAuthState>(this as SocialAuthState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SocialAuthState&&(identical(other.status, status) || other.status == status)&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,status,provider,error);

@override
String toString() {
  return 'SocialAuthState(status: $status, provider: $provider, error: $error)';
}


}

/// @nodoc
abstract mixin class $SocialAuthStateCopyWith<$Res>  {
  factory $SocialAuthStateCopyWith(SocialAuthState value, $Res Function(SocialAuthState) _then) = _$SocialAuthStateCopyWithImpl;
@useResult
$Res call({
 SocialAuthStatus status, SocialProvider? provider, Failure? error
});


$FailureCopyWith<$Res>? get error;

}
/// @nodoc
class _$SocialAuthStateCopyWithImpl<$Res>
    implements $SocialAuthStateCopyWith<$Res> {
  _$SocialAuthStateCopyWithImpl(this._self, this._then);

  final SocialAuthState _self;
  final $Res Function(SocialAuthState) _then;

/// Create a copy of SocialAuthState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? provider = freezed,Object? error = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SocialAuthStatus,provider: freezed == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as SocialProvider?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as Failure?,
  ));
}
/// Create a copy of SocialAuthState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FailureCopyWith<$Res>? get error {
    if (_self.error == null) {
    return null;
  }

  return $FailureCopyWith<$Res>(_self.error!, (value) {
    return _then(_self.copyWith(error: value));
  });
}
}


/// Adds pattern-matching-related methods to [SocialAuthState].
extension SocialAuthStatePatterns on SocialAuthState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SocialAuthState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SocialAuthState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SocialAuthState value)  $default,){
final _that = this;
switch (_that) {
case _SocialAuthState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SocialAuthState value)?  $default,){
final _that = this;
switch (_that) {
case _SocialAuthState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( SocialAuthStatus status,  SocialProvider? provider,  Failure? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SocialAuthState() when $default != null:
return $default(_that.status,_that.provider,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( SocialAuthStatus status,  SocialProvider? provider,  Failure? error)  $default,) {final _that = this;
switch (_that) {
case _SocialAuthState():
return $default(_that.status,_that.provider,_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( SocialAuthStatus status,  SocialProvider? provider,  Failure? error)?  $default,) {final _that = this;
switch (_that) {
case _SocialAuthState() when $default != null:
return $default(_that.status,_that.provider,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _SocialAuthState extends SocialAuthState {
  const _SocialAuthState({this.status = SocialAuthStatus.idle, this.provider, this.error}): super._();
  

@override@JsonKey() final  SocialAuthStatus status;
@override final  SocialProvider? provider;
@override final  Failure? error;

/// Create a copy of SocialAuthState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SocialAuthStateCopyWith<_SocialAuthState> get copyWith => __$SocialAuthStateCopyWithImpl<_SocialAuthState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SocialAuthState&&(identical(other.status, status) || other.status == status)&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,status,provider,error);

@override
String toString() {
  return 'SocialAuthState(status: $status, provider: $provider, error: $error)';
}


}

/// @nodoc
abstract mixin class _$SocialAuthStateCopyWith<$Res> implements $SocialAuthStateCopyWith<$Res> {
  factory _$SocialAuthStateCopyWith(_SocialAuthState value, $Res Function(_SocialAuthState) _then) = __$SocialAuthStateCopyWithImpl;
@override @useResult
$Res call({
 SocialAuthStatus status, SocialProvider? provider, Failure? error
});


@override $FailureCopyWith<$Res>? get error;

}
/// @nodoc
class __$SocialAuthStateCopyWithImpl<$Res>
    implements _$SocialAuthStateCopyWith<$Res> {
  __$SocialAuthStateCopyWithImpl(this._self, this._then);

  final _SocialAuthState _self;
  final $Res Function(_SocialAuthState) _then;

/// Create a copy of SocialAuthState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? provider = freezed,Object? error = freezed,}) {
  return _then(_SocialAuthState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as SocialAuthStatus,provider: freezed == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as SocialProvider?,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as Failure?,
  ));
}

/// Create a copy of SocialAuthState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FailureCopyWith<$Res>? get error {
    if (_self.error == null) {
    return null;
  }

  return $FailureCopyWith<$Res>(_self.error!, (value) {
    return _then(_self.copyWith(error: value));
  });
}
}

// dart format on

// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'login_form_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$LoginFormState {

 FieldState get email; FieldState get password; bool get rememberMe; bool get submitting; bool get success; Failure? get formError;
/// Create a copy of LoginFormState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LoginFormStateCopyWith<LoginFormState> get copyWith => _$LoginFormStateCopyWithImpl<LoginFormState>(this as LoginFormState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoginFormState&&(identical(other.email, email) || other.email == email)&&(identical(other.password, password) || other.password == password)&&(identical(other.rememberMe, rememberMe) || other.rememberMe == rememberMe)&&(identical(other.submitting, submitting) || other.submitting == submitting)&&(identical(other.success, success) || other.success == success)&&(identical(other.formError, formError) || other.formError == formError));
}


@override
int get hashCode => Object.hash(runtimeType,email,password,rememberMe,submitting,success,formError);

@override
String toString() {
  return 'LoginFormState(email: $email, password: $password, rememberMe: $rememberMe, submitting: $submitting, success: $success, formError: $formError)';
}


}

/// @nodoc
abstract mixin class $LoginFormStateCopyWith<$Res>  {
  factory $LoginFormStateCopyWith(LoginFormState value, $Res Function(LoginFormState) _then) = _$LoginFormStateCopyWithImpl;
@useResult
$Res call({
 FieldState email, FieldState password, bool rememberMe, bool submitting, bool success, Failure? formError
});


$FieldStateCopyWith<$Res> get email;$FieldStateCopyWith<$Res> get password;$FailureCopyWith<$Res>? get formError;

}
/// @nodoc
class _$LoginFormStateCopyWithImpl<$Res>
    implements $LoginFormStateCopyWith<$Res> {
  _$LoginFormStateCopyWithImpl(this._self, this._then);

  final LoginFormState _self;
  final $Res Function(LoginFormState) _then;

/// Create a copy of LoginFormState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? email = null,Object? password = null,Object? rememberMe = null,Object? submitting = null,Object? success = null,Object? formError = freezed,}) {
  return _then(_self.copyWith(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as FieldState,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as FieldState,rememberMe: null == rememberMe ? _self.rememberMe : rememberMe // ignore: cast_nullable_to_non_nullable
as bool,submitting: null == submitting ? _self.submitting : submitting // ignore: cast_nullable_to_non_nullable
as bool,success: null == success ? _self.success : success // ignore: cast_nullable_to_non_nullable
as bool,formError: freezed == formError ? _self.formError : formError // ignore: cast_nullable_to_non_nullable
as Failure?,
  ));
}
/// Create a copy of LoginFormState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FieldStateCopyWith<$Res> get email {
  
  return $FieldStateCopyWith<$Res>(_self.email, (value) {
    return _then(_self.copyWith(email: value));
  });
}/// Create a copy of LoginFormState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FieldStateCopyWith<$Res> get password {
  
  return $FieldStateCopyWith<$Res>(_self.password, (value) {
    return _then(_self.copyWith(password: value));
  });
}/// Create a copy of LoginFormState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FailureCopyWith<$Res>? get formError {
    if (_self.formError == null) {
    return null;
  }

  return $FailureCopyWith<$Res>(_self.formError!, (value) {
    return _then(_self.copyWith(formError: value));
  });
}
}


/// Adds pattern-matching-related methods to [LoginFormState].
extension LoginFormStatePatterns on LoginFormState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LoginFormState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LoginFormState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LoginFormState value)  $default,){
final _that = this;
switch (_that) {
case _LoginFormState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LoginFormState value)?  $default,){
final _that = this;
switch (_that) {
case _LoginFormState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( FieldState email,  FieldState password,  bool rememberMe,  bool submitting,  bool success,  Failure? formError)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LoginFormState() when $default != null:
return $default(_that.email,_that.password,_that.rememberMe,_that.submitting,_that.success,_that.formError);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( FieldState email,  FieldState password,  bool rememberMe,  bool submitting,  bool success,  Failure? formError)  $default,) {final _that = this;
switch (_that) {
case _LoginFormState():
return $default(_that.email,_that.password,_that.rememberMe,_that.submitting,_that.success,_that.formError);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( FieldState email,  FieldState password,  bool rememberMe,  bool submitting,  bool success,  Failure? formError)?  $default,) {final _that = this;
switch (_that) {
case _LoginFormState() when $default != null:
return $default(_that.email,_that.password,_that.rememberMe,_that.submitting,_that.success,_that.formError);case _:
  return null;

}
}

}

/// @nodoc


class _LoginFormState extends LoginFormState {
  const _LoginFormState({this.email = const FieldState(), this.password = const FieldState(), this.rememberMe = true, this.submitting = false, this.success = false, this.formError}): super._();
  

@override@JsonKey() final  FieldState email;
@override@JsonKey() final  FieldState password;
@override@JsonKey() final  bool rememberMe;
@override@JsonKey() final  bool submitting;
@override@JsonKey() final  bool success;
@override final  Failure? formError;

/// Create a copy of LoginFormState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LoginFormStateCopyWith<_LoginFormState> get copyWith => __$LoginFormStateCopyWithImpl<_LoginFormState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LoginFormState&&(identical(other.email, email) || other.email == email)&&(identical(other.password, password) || other.password == password)&&(identical(other.rememberMe, rememberMe) || other.rememberMe == rememberMe)&&(identical(other.submitting, submitting) || other.submitting == submitting)&&(identical(other.success, success) || other.success == success)&&(identical(other.formError, formError) || other.formError == formError));
}


@override
int get hashCode => Object.hash(runtimeType,email,password,rememberMe,submitting,success,formError);

@override
String toString() {
  return 'LoginFormState(email: $email, password: $password, rememberMe: $rememberMe, submitting: $submitting, success: $success, formError: $formError)';
}


}

/// @nodoc
abstract mixin class _$LoginFormStateCopyWith<$Res> implements $LoginFormStateCopyWith<$Res> {
  factory _$LoginFormStateCopyWith(_LoginFormState value, $Res Function(_LoginFormState) _then) = __$LoginFormStateCopyWithImpl;
@override @useResult
$Res call({
 FieldState email, FieldState password, bool rememberMe, bool submitting, bool success, Failure? formError
});


@override $FieldStateCopyWith<$Res> get email;@override $FieldStateCopyWith<$Res> get password;@override $FailureCopyWith<$Res>? get formError;

}
/// @nodoc
class __$LoginFormStateCopyWithImpl<$Res>
    implements _$LoginFormStateCopyWith<$Res> {
  __$LoginFormStateCopyWithImpl(this._self, this._then);

  final _LoginFormState _self;
  final $Res Function(_LoginFormState) _then;

/// Create a copy of LoginFormState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? email = null,Object? password = null,Object? rememberMe = null,Object? submitting = null,Object? success = null,Object? formError = freezed,}) {
  return _then(_LoginFormState(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as FieldState,password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as FieldState,rememberMe: null == rememberMe ? _self.rememberMe : rememberMe // ignore: cast_nullable_to_non_nullable
as bool,submitting: null == submitting ? _self.submitting : submitting // ignore: cast_nullable_to_non_nullable
as bool,success: null == success ? _self.success : success // ignore: cast_nullable_to_non_nullable
as bool,formError: freezed == formError ? _self.formError : formError // ignore: cast_nullable_to_non_nullable
as Failure?,
  ));
}

/// Create a copy of LoginFormState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FieldStateCopyWith<$Res> get email {
  
  return $FieldStateCopyWith<$Res>(_self.email, (value) {
    return _then(_self.copyWith(email: value));
  });
}/// Create a copy of LoginFormState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FieldStateCopyWith<$Res> get password {
  
  return $FieldStateCopyWith<$Res>(_self.password, (value) {
    return _then(_self.copyWith(password: value));
  });
}/// Create a copy of LoginFormState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FailureCopyWith<$Res>? get formError {
    if (_self.formError == null) {
    return null;
  }

  return $FailureCopyWith<$Res>(_self.formError!, (value) {
    return _then(_self.copyWith(formError: value));
  });
}
}

// dart format on

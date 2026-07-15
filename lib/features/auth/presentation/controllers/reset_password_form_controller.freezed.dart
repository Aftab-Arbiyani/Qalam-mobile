// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reset_password_form_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ResetPasswordFormState {

 FieldState get password; FieldState get confirm; bool get submitting; bool get success; Failure? get formError;
/// Create a copy of ResetPasswordFormState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ResetPasswordFormStateCopyWith<ResetPasswordFormState> get copyWith => _$ResetPasswordFormStateCopyWithImpl<ResetPasswordFormState>(this as ResetPasswordFormState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ResetPasswordFormState&&(identical(other.password, password) || other.password == password)&&(identical(other.confirm, confirm) || other.confirm == confirm)&&(identical(other.submitting, submitting) || other.submitting == submitting)&&(identical(other.success, success) || other.success == success)&&(identical(other.formError, formError) || other.formError == formError));
}


@override
int get hashCode => Object.hash(runtimeType,password,confirm,submitting,success,formError);

@override
String toString() {
  return 'ResetPasswordFormState(password: $password, confirm: $confirm, submitting: $submitting, success: $success, formError: $formError)';
}


}

/// @nodoc
abstract mixin class $ResetPasswordFormStateCopyWith<$Res>  {
  factory $ResetPasswordFormStateCopyWith(ResetPasswordFormState value, $Res Function(ResetPasswordFormState) _then) = _$ResetPasswordFormStateCopyWithImpl;
@useResult
$Res call({
 FieldState password, FieldState confirm, bool submitting, bool success, Failure? formError
});


$FieldStateCopyWith<$Res> get password;$FieldStateCopyWith<$Res> get confirm;$FailureCopyWith<$Res>? get formError;

}
/// @nodoc
class _$ResetPasswordFormStateCopyWithImpl<$Res>
    implements $ResetPasswordFormStateCopyWith<$Res> {
  _$ResetPasswordFormStateCopyWithImpl(this._self, this._then);

  final ResetPasswordFormState _self;
  final $Res Function(ResetPasswordFormState) _then;

/// Create a copy of ResetPasswordFormState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? password = null,Object? confirm = null,Object? submitting = null,Object? success = null,Object? formError = freezed,}) {
  return _then(_self.copyWith(
password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as FieldState,confirm: null == confirm ? _self.confirm : confirm // ignore: cast_nullable_to_non_nullable
as FieldState,submitting: null == submitting ? _self.submitting : submitting // ignore: cast_nullable_to_non_nullable
as bool,success: null == success ? _self.success : success // ignore: cast_nullable_to_non_nullable
as bool,formError: freezed == formError ? _self.formError : formError // ignore: cast_nullable_to_non_nullable
as Failure?,
  ));
}
/// Create a copy of ResetPasswordFormState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FieldStateCopyWith<$Res> get password {
  
  return $FieldStateCopyWith<$Res>(_self.password, (value) {
    return _then(_self.copyWith(password: value));
  });
}/// Create a copy of ResetPasswordFormState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FieldStateCopyWith<$Res> get confirm {
  
  return $FieldStateCopyWith<$Res>(_self.confirm, (value) {
    return _then(_self.copyWith(confirm: value));
  });
}/// Create a copy of ResetPasswordFormState
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


/// Adds pattern-matching-related methods to [ResetPasswordFormState].
extension ResetPasswordFormStatePatterns on ResetPasswordFormState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ResetPasswordFormState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ResetPasswordFormState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ResetPasswordFormState value)  $default,){
final _that = this;
switch (_that) {
case _ResetPasswordFormState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ResetPasswordFormState value)?  $default,){
final _that = this;
switch (_that) {
case _ResetPasswordFormState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( FieldState password,  FieldState confirm,  bool submitting,  bool success,  Failure? formError)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ResetPasswordFormState() when $default != null:
return $default(_that.password,_that.confirm,_that.submitting,_that.success,_that.formError);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( FieldState password,  FieldState confirm,  bool submitting,  bool success,  Failure? formError)  $default,) {final _that = this;
switch (_that) {
case _ResetPasswordFormState():
return $default(_that.password,_that.confirm,_that.submitting,_that.success,_that.formError);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( FieldState password,  FieldState confirm,  bool submitting,  bool success,  Failure? formError)?  $default,) {final _that = this;
switch (_that) {
case _ResetPasswordFormState() when $default != null:
return $default(_that.password,_that.confirm,_that.submitting,_that.success,_that.formError);case _:
  return null;

}
}

}

/// @nodoc


class _ResetPasswordFormState extends ResetPasswordFormState {
  const _ResetPasswordFormState({this.password = const FieldState(), this.confirm = const FieldState(), this.submitting = false, this.success = false, this.formError}): super._();
  

@override@JsonKey() final  FieldState password;
@override@JsonKey() final  FieldState confirm;
@override@JsonKey() final  bool submitting;
@override@JsonKey() final  bool success;
@override final  Failure? formError;

/// Create a copy of ResetPasswordFormState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ResetPasswordFormStateCopyWith<_ResetPasswordFormState> get copyWith => __$ResetPasswordFormStateCopyWithImpl<_ResetPasswordFormState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ResetPasswordFormState&&(identical(other.password, password) || other.password == password)&&(identical(other.confirm, confirm) || other.confirm == confirm)&&(identical(other.submitting, submitting) || other.submitting == submitting)&&(identical(other.success, success) || other.success == success)&&(identical(other.formError, formError) || other.formError == formError));
}


@override
int get hashCode => Object.hash(runtimeType,password,confirm,submitting,success,formError);

@override
String toString() {
  return 'ResetPasswordFormState(password: $password, confirm: $confirm, submitting: $submitting, success: $success, formError: $formError)';
}


}

/// @nodoc
abstract mixin class _$ResetPasswordFormStateCopyWith<$Res> implements $ResetPasswordFormStateCopyWith<$Res> {
  factory _$ResetPasswordFormStateCopyWith(_ResetPasswordFormState value, $Res Function(_ResetPasswordFormState) _then) = __$ResetPasswordFormStateCopyWithImpl;
@override @useResult
$Res call({
 FieldState password, FieldState confirm, bool submitting, bool success, Failure? formError
});


@override $FieldStateCopyWith<$Res> get password;@override $FieldStateCopyWith<$Res> get confirm;@override $FailureCopyWith<$Res>? get formError;

}
/// @nodoc
class __$ResetPasswordFormStateCopyWithImpl<$Res>
    implements _$ResetPasswordFormStateCopyWith<$Res> {
  __$ResetPasswordFormStateCopyWithImpl(this._self, this._then);

  final _ResetPasswordFormState _self;
  final $Res Function(_ResetPasswordFormState) _then;

/// Create a copy of ResetPasswordFormState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? password = null,Object? confirm = null,Object? submitting = null,Object? success = null,Object? formError = freezed,}) {
  return _then(_ResetPasswordFormState(
password: null == password ? _self.password : password // ignore: cast_nullable_to_non_nullable
as FieldState,confirm: null == confirm ? _self.confirm : confirm // ignore: cast_nullable_to_non_nullable
as FieldState,submitting: null == submitting ? _self.submitting : submitting // ignore: cast_nullable_to_non_nullable
as bool,success: null == success ? _self.success : success // ignore: cast_nullable_to_non_nullable
as bool,formError: freezed == formError ? _self.formError : formError // ignore: cast_nullable_to_non_nullable
as Failure?,
  ));
}

/// Create a copy of ResetPasswordFormState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FieldStateCopyWith<$Res> get password {
  
  return $FieldStateCopyWith<$Res>(_self.password, (value) {
    return _then(_self.copyWith(password: value));
  });
}/// Create a copy of ResetPasswordFormState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FieldStateCopyWith<$Res> get confirm {
  
  return $FieldStateCopyWith<$Res>(_self.confirm, (value) {
    return _then(_self.copyWith(confirm: value));
  });
}/// Create a copy of ResetPasswordFormState
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

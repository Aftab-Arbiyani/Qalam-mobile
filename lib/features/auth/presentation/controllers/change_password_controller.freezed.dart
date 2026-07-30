// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'change_password_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ChangePasswordState {

 String get currentPassword; String get newPassword; String get confirmPassword; ChangePasswordFieldError? get currentError; ChangePasswordFieldError? get newError; ChangePasswordFieldError? get confirmError; bool get submitting; bool get success; Failure? get formError;
/// Create a copy of ChangePasswordState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChangePasswordStateCopyWith<ChangePasswordState> get copyWith => _$ChangePasswordStateCopyWithImpl<ChangePasswordState>(this as ChangePasswordState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChangePasswordState&&(identical(other.currentPassword, currentPassword) || other.currentPassword == currentPassword)&&(identical(other.newPassword, newPassword) || other.newPassword == newPassword)&&(identical(other.confirmPassword, confirmPassword) || other.confirmPassword == confirmPassword)&&(identical(other.currentError, currentError) || other.currentError == currentError)&&(identical(other.newError, newError) || other.newError == newError)&&(identical(other.confirmError, confirmError) || other.confirmError == confirmError)&&(identical(other.submitting, submitting) || other.submitting == submitting)&&(identical(other.success, success) || other.success == success)&&(identical(other.formError, formError) || other.formError == formError));
}


@override
int get hashCode => Object.hash(runtimeType,currentPassword,newPassword,confirmPassword,currentError,newError,confirmError,submitting,success,formError);

@override
String toString() {
  return 'ChangePasswordState(currentPassword: $currentPassword, newPassword: $newPassword, confirmPassword: $confirmPassword, currentError: $currentError, newError: $newError, confirmError: $confirmError, submitting: $submitting, success: $success, formError: $formError)';
}


}

/// @nodoc
abstract mixin class $ChangePasswordStateCopyWith<$Res>  {
  factory $ChangePasswordStateCopyWith(ChangePasswordState value, $Res Function(ChangePasswordState) _then) = _$ChangePasswordStateCopyWithImpl;
@useResult
$Res call({
 String currentPassword, String newPassword, String confirmPassword, ChangePasswordFieldError? currentError, ChangePasswordFieldError? newError, ChangePasswordFieldError? confirmError, bool submitting, bool success, Failure? formError
});


$FailureCopyWith<$Res>? get formError;

}
/// @nodoc
class _$ChangePasswordStateCopyWithImpl<$Res>
    implements $ChangePasswordStateCopyWith<$Res> {
  _$ChangePasswordStateCopyWithImpl(this._self, this._then);

  final ChangePasswordState _self;
  final $Res Function(ChangePasswordState) _then;

/// Create a copy of ChangePasswordState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? currentPassword = null,Object? newPassword = null,Object? confirmPassword = null,Object? currentError = freezed,Object? newError = freezed,Object? confirmError = freezed,Object? submitting = null,Object? success = null,Object? formError = freezed,}) {
  return _then(_self.copyWith(
currentPassword: null == currentPassword ? _self.currentPassword : currentPassword // ignore: cast_nullable_to_non_nullable
as String,newPassword: null == newPassword ? _self.newPassword : newPassword // ignore: cast_nullable_to_non_nullable
as String,confirmPassword: null == confirmPassword ? _self.confirmPassword : confirmPassword // ignore: cast_nullable_to_non_nullable
as String,currentError: freezed == currentError ? _self.currentError : currentError // ignore: cast_nullable_to_non_nullable
as ChangePasswordFieldError?,newError: freezed == newError ? _self.newError : newError // ignore: cast_nullable_to_non_nullable
as ChangePasswordFieldError?,confirmError: freezed == confirmError ? _self.confirmError : confirmError // ignore: cast_nullable_to_non_nullable
as ChangePasswordFieldError?,submitting: null == submitting ? _self.submitting : submitting // ignore: cast_nullable_to_non_nullable
as bool,success: null == success ? _self.success : success // ignore: cast_nullable_to_non_nullable
as bool,formError: freezed == formError ? _self.formError : formError // ignore: cast_nullable_to_non_nullable
as Failure?,
  ));
}
/// Create a copy of ChangePasswordState
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


/// Adds pattern-matching-related methods to [ChangePasswordState].
extension ChangePasswordStatePatterns on ChangePasswordState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChangePasswordState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChangePasswordState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChangePasswordState value)  $default,){
final _that = this;
switch (_that) {
case _ChangePasswordState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChangePasswordState value)?  $default,){
final _that = this;
switch (_that) {
case _ChangePasswordState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String currentPassword,  String newPassword,  String confirmPassword,  ChangePasswordFieldError? currentError,  ChangePasswordFieldError? newError,  ChangePasswordFieldError? confirmError,  bool submitting,  bool success,  Failure? formError)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChangePasswordState() when $default != null:
return $default(_that.currentPassword,_that.newPassword,_that.confirmPassword,_that.currentError,_that.newError,_that.confirmError,_that.submitting,_that.success,_that.formError);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String currentPassword,  String newPassword,  String confirmPassword,  ChangePasswordFieldError? currentError,  ChangePasswordFieldError? newError,  ChangePasswordFieldError? confirmError,  bool submitting,  bool success,  Failure? formError)  $default,) {final _that = this;
switch (_that) {
case _ChangePasswordState():
return $default(_that.currentPassword,_that.newPassword,_that.confirmPassword,_that.currentError,_that.newError,_that.confirmError,_that.submitting,_that.success,_that.formError);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String currentPassword,  String newPassword,  String confirmPassword,  ChangePasswordFieldError? currentError,  ChangePasswordFieldError? newError,  ChangePasswordFieldError? confirmError,  bool submitting,  bool success,  Failure? formError)?  $default,) {final _that = this;
switch (_that) {
case _ChangePasswordState() when $default != null:
return $default(_that.currentPassword,_that.newPassword,_that.confirmPassword,_that.currentError,_that.newError,_that.confirmError,_that.submitting,_that.success,_that.formError);case _:
  return null;

}
}

}

/// @nodoc


class _ChangePasswordState extends ChangePasswordState {
  const _ChangePasswordState({this.currentPassword = '', this.newPassword = '', this.confirmPassword = '', this.currentError, this.newError, this.confirmError, this.submitting = false, this.success = false, this.formError}): super._();
  

@override@JsonKey() final  String currentPassword;
@override@JsonKey() final  String newPassword;
@override@JsonKey() final  String confirmPassword;
@override final  ChangePasswordFieldError? currentError;
@override final  ChangePasswordFieldError? newError;
@override final  ChangePasswordFieldError? confirmError;
@override@JsonKey() final  bool submitting;
@override@JsonKey() final  bool success;
@override final  Failure? formError;

/// Create a copy of ChangePasswordState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChangePasswordStateCopyWith<_ChangePasswordState> get copyWith => __$ChangePasswordStateCopyWithImpl<_ChangePasswordState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChangePasswordState&&(identical(other.currentPassword, currentPassword) || other.currentPassword == currentPassword)&&(identical(other.newPassword, newPassword) || other.newPassword == newPassword)&&(identical(other.confirmPassword, confirmPassword) || other.confirmPassword == confirmPassword)&&(identical(other.currentError, currentError) || other.currentError == currentError)&&(identical(other.newError, newError) || other.newError == newError)&&(identical(other.confirmError, confirmError) || other.confirmError == confirmError)&&(identical(other.submitting, submitting) || other.submitting == submitting)&&(identical(other.success, success) || other.success == success)&&(identical(other.formError, formError) || other.formError == formError));
}


@override
int get hashCode => Object.hash(runtimeType,currentPassword,newPassword,confirmPassword,currentError,newError,confirmError,submitting,success,formError);

@override
String toString() {
  return 'ChangePasswordState(currentPassword: $currentPassword, newPassword: $newPassword, confirmPassword: $confirmPassword, currentError: $currentError, newError: $newError, confirmError: $confirmError, submitting: $submitting, success: $success, formError: $formError)';
}


}

/// @nodoc
abstract mixin class _$ChangePasswordStateCopyWith<$Res> implements $ChangePasswordStateCopyWith<$Res> {
  factory _$ChangePasswordStateCopyWith(_ChangePasswordState value, $Res Function(_ChangePasswordState) _then) = __$ChangePasswordStateCopyWithImpl;
@override @useResult
$Res call({
 String currentPassword, String newPassword, String confirmPassword, ChangePasswordFieldError? currentError, ChangePasswordFieldError? newError, ChangePasswordFieldError? confirmError, bool submitting, bool success, Failure? formError
});


@override $FailureCopyWith<$Res>? get formError;

}
/// @nodoc
class __$ChangePasswordStateCopyWithImpl<$Res>
    implements _$ChangePasswordStateCopyWith<$Res> {
  __$ChangePasswordStateCopyWithImpl(this._self, this._then);

  final _ChangePasswordState _self;
  final $Res Function(_ChangePasswordState) _then;

/// Create a copy of ChangePasswordState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? currentPassword = null,Object? newPassword = null,Object? confirmPassword = null,Object? currentError = freezed,Object? newError = freezed,Object? confirmError = freezed,Object? submitting = null,Object? success = null,Object? formError = freezed,}) {
  return _then(_ChangePasswordState(
currentPassword: null == currentPassword ? _self.currentPassword : currentPassword // ignore: cast_nullable_to_non_nullable
as String,newPassword: null == newPassword ? _self.newPassword : newPassword // ignore: cast_nullable_to_non_nullable
as String,confirmPassword: null == confirmPassword ? _self.confirmPassword : confirmPassword // ignore: cast_nullable_to_non_nullable
as String,currentError: freezed == currentError ? _self.currentError : currentError // ignore: cast_nullable_to_non_nullable
as ChangePasswordFieldError?,newError: freezed == newError ? _self.newError : newError // ignore: cast_nullable_to_non_nullable
as ChangePasswordFieldError?,confirmError: freezed == confirmError ? _self.confirmError : confirmError // ignore: cast_nullable_to_non_nullable
as ChangePasswordFieldError?,submitting: null == submitting ? _self.submitting : submitting // ignore: cast_nullable_to_non_nullable
as bool,success: null == success ? _self.success : success // ignore: cast_nullable_to_non_nullable
as bool,formError: freezed == formError ? _self.formError : formError // ignore: cast_nullable_to_non_nullable
as Failure?,
  ));
}

/// Create a copy of ChangePasswordState
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

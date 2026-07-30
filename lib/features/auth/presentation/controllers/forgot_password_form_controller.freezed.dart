// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'forgot_password_form_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ForgotPasswordFormState {

 FieldState get email; bool get submitting; bool get sent; Failure? get formError;
/// Create a copy of ForgotPasswordFormState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ForgotPasswordFormStateCopyWith<ForgotPasswordFormState> get copyWith => _$ForgotPasswordFormStateCopyWithImpl<ForgotPasswordFormState>(this as ForgotPasswordFormState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ForgotPasswordFormState&&(identical(other.email, email) || other.email == email)&&(identical(other.submitting, submitting) || other.submitting == submitting)&&(identical(other.sent, sent) || other.sent == sent)&&(identical(other.formError, formError) || other.formError == formError));
}


@override
int get hashCode => Object.hash(runtimeType,email,submitting,sent,formError);

@override
String toString() {
  return 'ForgotPasswordFormState(email: $email, submitting: $submitting, sent: $sent, formError: $formError)';
}


}

/// @nodoc
abstract mixin class $ForgotPasswordFormStateCopyWith<$Res>  {
  factory $ForgotPasswordFormStateCopyWith(ForgotPasswordFormState value, $Res Function(ForgotPasswordFormState) _then) = _$ForgotPasswordFormStateCopyWithImpl;
@useResult
$Res call({
 FieldState email, bool submitting, bool sent, Failure? formError
});


$FieldStateCopyWith<$Res> get email;$FailureCopyWith<$Res>? get formError;

}
/// @nodoc
class _$ForgotPasswordFormStateCopyWithImpl<$Res>
    implements $ForgotPasswordFormStateCopyWith<$Res> {
  _$ForgotPasswordFormStateCopyWithImpl(this._self, this._then);

  final ForgotPasswordFormState _self;
  final $Res Function(ForgotPasswordFormState) _then;

/// Create a copy of ForgotPasswordFormState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? email = null,Object? submitting = null,Object? sent = null,Object? formError = freezed,}) {
  return _then(_self.copyWith(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as FieldState,submitting: null == submitting ? _self.submitting : submitting // ignore: cast_nullable_to_non_nullable
as bool,sent: null == sent ? _self.sent : sent // ignore: cast_nullable_to_non_nullable
as bool,formError: freezed == formError ? _self.formError : formError // ignore: cast_nullable_to_non_nullable
as Failure?,
  ));
}
/// Create a copy of ForgotPasswordFormState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FieldStateCopyWith<$Res> get email {
  
  return $FieldStateCopyWith<$Res>(_self.email, (value) {
    return _then(_self.copyWith(email: value));
  });
}/// Create a copy of ForgotPasswordFormState
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


/// Adds pattern-matching-related methods to [ForgotPasswordFormState].
extension ForgotPasswordFormStatePatterns on ForgotPasswordFormState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ForgotPasswordFormState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ForgotPasswordFormState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ForgotPasswordFormState value)  $default,){
final _that = this;
switch (_that) {
case _ForgotPasswordFormState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ForgotPasswordFormState value)?  $default,){
final _that = this;
switch (_that) {
case _ForgotPasswordFormState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( FieldState email,  bool submitting,  bool sent,  Failure? formError)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ForgotPasswordFormState() when $default != null:
return $default(_that.email,_that.submitting,_that.sent,_that.formError);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( FieldState email,  bool submitting,  bool sent,  Failure? formError)  $default,) {final _that = this;
switch (_that) {
case _ForgotPasswordFormState():
return $default(_that.email,_that.submitting,_that.sent,_that.formError);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( FieldState email,  bool submitting,  bool sent,  Failure? formError)?  $default,) {final _that = this;
switch (_that) {
case _ForgotPasswordFormState() when $default != null:
return $default(_that.email,_that.submitting,_that.sent,_that.formError);case _:
  return null;

}
}

}

/// @nodoc


class _ForgotPasswordFormState extends ForgotPasswordFormState {
  const _ForgotPasswordFormState({this.email = const FieldState(), this.submitting = false, this.sent = false, this.formError}): super._();
  

@override@JsonKey() final  FieldState email;
@override@JsonKey() final  bool submitting;
@override@JsonKey() final  bool sent;
@override final  Failure? formError;

/// Create a copy of ForgotPasswordFormState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ForgotPasswordFormStateCopyWith<_ForgotPasswordFormState> get copyWith => __$ForgotPasswordFormStateCopyWithImpl<_ForgotPasswordFormState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ForgotPasswordFormState&&(identical(other.email, email) || other.email == email)&&(identical(other.submitting, submitting) || other.submitting == submitting)&&(identical(other.sent, sent) || other.sent == sent)&&(identical(other.formError, formError) || other.formError == formError));
}


@override
int get hashCode => Object.hash(runtimeType,email,submitting,sent,formError);

@override
String toString() {
  return 'ForgotPasswordFormState(email: $email, submitting: $submitting, sent: $sent, formError: $formError)';
}


}

/// @nodoc
abstract mixin class _$ForgotPasswordFormStateCopyWith<$Res> implements $ForgotPasswordFormStateCopyWith<$Res> {
  factory _$ForgotPasswordFormStateCopyWith(_ForgotPasswordFormState value, $Res Function(_ForgotPasswordFormState) _then) = __$ForgotPasswordFormStateCopyWithImpl;
@override @useResult
$Res call({
 FieldState email, bool submitting, bool sent, Failure? formError
});


@override $FieldStateCopyWith<$Res> get email;@override $FailureCopyWith<$Res>? get formError;

}
/// @nodoc
class __$ForgotPasswordFormStateCopyWithImpl<$Res>
    implements _$ForgotPasswordFormStateCopyWith<$Res> {
  __$ForgotPasswordFormStateCopyWithImpl(this._self, this._then);

  final _ForgotPasswordFormState _self;
  final $Res Function(_ForgotPasswordFormState) _then;

/// Create a copy of ForgotPasswordFormState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? email = null,Object? submitting = null,Object? sent = null,Object? formError = freezed,}) {
  return _then(_ForgotPasswordFormState(
email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as FieldState,submitting: null == submitting ? _self.submitting : submitting // ignore: cast_nullable_to_non_nullable
as bool,sent: null == sent ? _self.sent : sent // ignore: cast_nullable_to_non_nullable
as bool,formError: freezed == formError ? _self.formError : formError // ignore: cast_nullable_to_non_nullable
as Failure?,
  ));
}

/// Create a copy of ForgotPasswordFormState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$FieldStateCopyWith<$Res> get email {
  
  return $FieldStateCopyWith<$Res>(_self.email, (value) {
    return _then(_self.copyWith(email: value));
  });
}/// Create a copy of ForgotPasswordFormState
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

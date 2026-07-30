// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'failure.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Failure {

 String get code; String get message;
/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FailureCopyWith<Failure> get copyWith => _$FailureCopyWithImpl<Failure>(this as Failure, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Failure&&(identical(other.code, code) || other.code == code)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,code,message);

@override
String toString() {
  return 'Failure(code: $code, message: $message)';
}


}

/// @nodoc
abstract mixin class $FailureCopyWith<$Res>  {
  factory $FailureCopyWith(Failure value, $Res Function(Failure) _then) = _$FailureCopyWithImpl;
@useResult
$Res call({
 String code, String message
});




}
/// @nodoc
class _$FailureCopyWithImpl<$Res>
    implements $FailureCopyWith<$Res> {
  _$FailureCopyWithImpl(this._self, this._then);

  final Failure _self;
  final $Res Function(Failure) _then;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = null,Object? message = null,}) {
  return _then(_self.copyWith(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Failure].
extension FailurePatterns on Failure {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( NetworkFailure value)?  network,TResult Function( AuthFailure value)?  auth,TResult Function( PermissionFailure value)?  permission,TResult Function( NotFoundFailure value)?  notFound,TResult Function( ValidationFailure value)?  validation,TResult Function( ConflictFailure value)?  conflict,TResult Function( DomainRuleFailure value)?  domainRule,TResult Function( RateLimitFailure value)?  rateLimit,TResult Function( UnexpectedFailure value)?  unexpected,required TResult orElse(),}){
final _that = this;
switch (_that) {
case NetworkFailure() when network != null:
return network(_that);case AuthFailure() when auth != null:
return auth(_that);case PermissionFailure() when permission != null:
return permission(_that);case NotFoundFailure() when notFound != null:
return notFound(_that);case ValidationFailure() when validation != null:
return validation(_that);case ConflictFailure() when conflict != null:
return conflict(_that);case DomainRuleFailure() when domainRule != null:
return domainRule(_that);case RateLimitFailure() when rateLimit != null:
return rateLimit(_that);case UnexpectedFailure() when unexpected != null:
return unexpected(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( NetworkFailure value)  network,required TResult Function( AuthFailure value)  auth,required TResult Function( PermissionFailure value)  permission,required TResult Function( NotFoundFailure value)  notFound,required TResult Function( ValidationFailure value)  validation,required TResult Function( ConflictFailure value)  conflict,required TResult Function( DomainRuleFailure value)  domainRule,required TResult Function( RateLimitFailure value)  rateLimit,required TResult Function( UnexpectedFailure value)  unexpected,}){
final _that = this;
switch (_that) {
case NetworkFailure():
return network(_that);case AuthFailure():
return auth(_that);case PermissionFailure():
return permission(_that);case NotFoundFailure():
return notFound(_that);case ValidationFailure():
return validation(_that);case ConflictFailure():
return conflict(_that);case DomainRuleFailure():
return domainRule(_that);case RateLimitFailure():
return rateLimit(_that);case UnexpectedFailure():
return unexpected(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( NetworkFailure value)?  network,TResult? Function( AuthFailure value)?  auth,TResult? Function( PermissionFailure value)?  permission,TResult? Function( NotFoundFailure value)?  notFound,TResult? Function( ValidationFailure value)?  validation,TResult? Function( ConflictFailure value)?  conflict,TResult? Function( DomainRuleFailure value)?  domainRule,TResult? Function( RateLimitFailure value)?  rateLimit,TResult? Function( UnexpectedFailure value)?  unexpected,}){
final _that = this;
switch (_that) {
case NetworkFailure() when network != null:
return network(_that);case AuthFailure() when auth != null:
return auth(_that);case PermissionFailure() when permission != null:
return permission(_that);case NotFoundFailure() when notFound != null:
return notFound(_that);case ValidationFailure() when validation != null:
return validation(_that);case ConflictFailure() when conflict != null:
return conflict(_that);case DomainRuleFailure() when domainRule != null:
return domainRule(_that);case RateLimitFailure() when rateLimit != null:
return rateLimit(_that);case UnexpectedFailure() when unexpected != null:
return unexpected(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String code,  String message,  bool isOffline)?  network,TResult Function( String code,  String message)?  auth,TResult Function( String code,  String message)?  permission,TResult Function( String code,  String message)?  notFound,TResult Function( String code,  String message,  List<FieldError> fieldErrors)?  validation,TResult Function( String code,  String message)?  conflict,TResult Function( String code,  String message)?  domainRule,TResult Function( String code,  String message,  Duration? retryAfter)?  rateLimit,TResult Function( String code,  String message,  String? requestId)?  unexpected,required TResult orElse(),}) {final _that = this;
switch (_that) {
case NetworkFailure() when network != null:
return network(_that.code,_that.message,_that.isOffline);case AuthFailure() when auth != null:
return auth(_that.code,_that.message);case PermissionFailure() when permission != null:
return permission(_that.code,_that.message);case NotFoundFailure() when notFound != null:
return notFound(_that.code,_that.message);case ValidationFailure() when validation != null:
return validation(_that.code,_that.message,_that.fieldErrors);case ConflictFailure() when conflict != null:
return conflict(_that.code,_that.message);case DomainRuleFailure() when domainRule != null:
return domainRule(_that.code,_that.message);case RateLimitFailure() when rateLimit != null:
return rateLimit(_that.code,_that.message,_that.retryAfter);case UnexpectedFailure() when unexpected != null:
return unexpected(_that.code,_that.message,_that.requestId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String code,  String message,  bool isOffline)  network,required TResult Function( String code,  String message)  auth,required TResult Function( String code,  String message)  permission,required TResult Function( String code,  String message)  notFound,required TResult Function( String code,  String message,  List<FieldError> fieldErrors)  validation,required TResult Function( String code,  String message)  conflict,required TResult Function( String code,  String message)  domainRule,required TResult Function( String code,  String message,  Duration? retryAfter)  rateLimit,required TResult Function( String code,  String message,  String? requestId)  unexpected,}) {final _that = this;
switch (_that) {
case NetworkFailure():
return network(_that.code,_that.message,_that.isOffline);case AuthFailure():
return auth(_that.code,_that.message);case PermissionFailure():
return permission(_that.code,_that.message);case NotFoundFailure():
return notFound(_that.code,_that.message);case ValidationFailure():
return validation(_that.code,_that.message,_that.fieldErrors);case ConflictFailure():
return conflict(_that.code,_that.message);case DomainRuleFailure():
return domainRule(_that.code,_that.message);case RateLimitFailure():
return rateLimit(_that.code,_that.message,_that.retryAfter);case UnexpectedFailure():
return unexpected(_that.code,_that.message,_that.requestId);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String code,  String message,  bool isOffline)?  network,TResult? Function( String code,  String message)?  auth,TResult? Function( String code,  String message)?  permission,TResult? Function( String code,  String message)?  notFound,TResult? Function( String code,  String message,  List<FieldError> fieldErrors)?  validation,TResult? Function( String code,  String message)?  conflict,TResult? Function( String code,  String message)?  domainRule,TResult? Function( String code,  String message,  Duration? retryAfter)?  rateLimit,TResult? Function( String code,  String message,  String? requestId)?  unexpected,}) {final _that = this;
switch (_that) {
case NetworkFailure() when network != null:
return network(_that.code,_that.message,_that.isOffline);case AuthFailure() when auth != null:
return auth(_that.code,_that.message);case PermissionFailure() when permission != null:
return permission(_that.code,_that.message);case NotFoundFailure() when notFound != null:
return notFound(_that.code,_that.message);case ValidationFailure() when validation != null:
return validation(_that.code,_that.message,_that.fieldErrors);case ConflictFailure() when conflict != null:
return conflict(_that.code,_that.message);case DomainRuleFailure() when domainRule != null:
return domainRule(_that.code,_that.message);case RateLimitFailure() when rateLimit != null:
return rateLimit(_that.code,_that.message,_that.retryAfter);case UnexpectedFailure() when unexpected != null:
return unexpected(_that.code,_that.message,_that.requestId);case _:
  return null;

}
}

}

/// @nodoc


class NetworkFailure implements Failure {
  const NetworkFailure({required this.code, this.message = '', this.isOffline = false});
  

@override final  String code;
@override@JsonKey() final  String message;
@JsonKey() final  bool isOffline;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NetworkFailureCopyWith<NetworkFailure> get copyWith => _$NetworkFailureCopyWithImpl<NetworkFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NetworkFailure&&(identical(other.code, code) || other.code == code)&&(identical(other.message, message) || other.message == message)&&(identical(other.isOffline, isOffline) || other.isOffline == isOffline));
}


@override
int get hashCode => Object.hash(runtimeType,code,message,isOffline);

@override
String toString() {
  return 'Failure.network(code: $code, message: $message, isOffline: $isOffline)';
}


}

/// @nodoc
abstract mixin class $NetworkFailureCopyWith<$Res> implements $FailureCopyWith<$Res> {
  factory $NetworkFailureCopyWith(NetworkFailure value, $Res Function(NetworkFailure) _then) = _$NetworkFailureCopyWithImpl;
@override @useResult
$Res call({
 String code, String message, bool isOffline
});




}
/// @nodoc
class _$NetworkFailureCopyWithImpl<$Res>
    implements $NetworkFailureCopyWith<$Res> {
  _$NetworkFailureCopyWithImpl(this._self, this._then);

  final NetworkFailure _self;
  final $Res Function(NetworkFailure) _then;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,Object? message = null,Object? isOffline = null,}) {
  return _then(NetworkFailure(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,isOffline: null == isOffline ? _self.isOffline : isOffline // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

/// @nodoc


class AuthFailure implements Failure {
  const AuthFailure({required this.code, this.message = ''});
  

@override final  String code;
@override@JsonKey() final  String message;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AuthFailureCopyWith<AuthFailure> get copyWith => _$AuthFailureCopyWithImpl<AuthFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AuthFailure&&(identical(other.code, code) || other.code == code)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,code,message);

@override
String toString() {
  return 'Failure.auth(code: $code, message: $message)';
}


}

/// @nodoc
abstract mixin class $AuthFailureCopyWith<$Res> implements $FailureCopyWith<$Res> {
  factory $AuthFailureCopyWith(AuthFailure value, $Res Function(AuthFailure) _then) = _$AuthFailureCopyWithImpl;
@override @useResult
$Res call({
 String code, String message
});




}
/// @nodoc
class _$AuthFailureCopyWithImpl<$Res>
    implements $AuthFailureCopyWith<$Res> {
  _$AuthFailureCopyWithImpl(this._self, this._then);

  final AuthFailure _self;
  final $Res Function(AuthFailure) _then;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,Object? message = null,}) {
  return _then(AuthFailure(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class PermissionFailure implements Failure {
  const PermissionFailure({required this.code, this.message = ''});
  

@override final  String code;
@override@JsonKey() final  String message;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PermissionFailureCopyWith<PermissionFailure> get copyWith => _$PermissionFailureCopyWithImpl<PermissionFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PermissionFailure&&(identical(other.code, code) || other.code == code)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,code,message);

@override
String toString() {
  return 'Failure.permission(code: $code, message: $message)';
}


}

/// @nodoc
abstract mixin class $PermissionFailureCopyWith<$Res> implements $FailureCopyWith<$Res> {
  factory $PermissionFailureCopyWith(PermissionFailure value, $Res Function(PermissionFailure) _then) = _$PermissionFailureCopyWithImpl;
@override @useResult
$Res call({
 String code, String message
});




}
/// @nodoc
class _$PermissionFailureCopyWithImpl<$Res>
    implements $PermissionFailureCopyWith<$Res> {
  _$PermissionFailureCopyWithImpl(this._self, this._then);

  final PermissionFailure _self;
  final $Res Function(PermissionFailure) _then;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,Object? message = null,}) {
  return _then(PermissionFailure(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class NotFoundFailure implements Failure {
  const NotFoundFailure({required this.code, this.message = ''});
  

@override final  String code;
@override@JsonKey() final  String message;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotFoundFailureCopyWith<NotFoundFailure> get copyWith => _$NotFoundFailureCopyWithImpl<NotFoundFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotFoundFailure&&(identical(other.code, code) || other.code == code)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,code,message);

@override
String toString() {
  return 'Failure.notFound(code: $code, message: $message)';
}


}

/// @nodoc
abstract mixin class $NotFoundFailureCopyWith<$Res> implements $FailureCopyWith<$Res> {
  factory $NotFoundFailureCopyWith(NotFoundFailure value, $Res Function(NotFoundFailure) _then) = _$NotFoundFailureCopyWithImpl;
@override @useResult
$Res call({
 String code, String message
});




}
/// @nodoc
class _$NotFoundFailureCopyWithImpl<$Res>
    implements $NotFoundFailureCopyWith<$Res> {
  _$NotFoundFailureCopyWithImpl(this._self, this._then);

  final NotFoundFailure _self;
  final $Res Function(NotFoundFailure) _then;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,Object? message = null,}) {
  return _then(NotFoundFailure(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class ValidationFailure implements Failure {
  const ValidationFailure({required this.code, this.message = '', final  List<FieldError> fieldErrors = const <FieldError>[]}): _fieldErrors = fieldErrors;
  

@override final  String code;
@override@JsonKey() final  String message;
 final  List<FieldError> _fieldErrors;
@JsonKey() List<FieldError> get fieldErrors {
  if (_fieldErrors is EqualUnmodifiableListView) return _fieldErrors;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_fieldErrors);
}


/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ValidationFailureCopyWith<ValidationFailure> get copyWith => _$ValidationFailureCopyWithImpl<ValidationFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ValidationFailure&&(identical(other.code, code) || other.code == code)&&(identical(other.message, message) || other.message == message)&&const DeepCollectionEquality().equals(other._fieldErrors, _fieldErrors));
}


@override
int get hashCode => Object.hash(runtimeType,code,message,const DeepCollectionEquality().hash(_fieldErrors));

@override
String toString() {
  return 'Failure.validation(code: $code, message: $message, fieldErrors: $fieldErrors)';
}


}

/// @nodoc
abstract mixin class $ValidationFailureCopyWith<$Res> implements $FailureCopyWith<$Res> {
  factory $ValidationFailureCopyWith(ValidationFailure value, $Res Function(ValidationFailure) _then) = _$ValidationFailureCopyWithImpl;
@override @useResult
$Res call({
 String code, String message, List<FieldError> fieldErrors
});




}
/// @nodoc
class _$ValidationFailureCopyWithImpl<$Res>
    implements $ValidationFailureCopyWith<$Res> {
  _$ValidationFailureCopyWithImpl(this._self, this._then);

  final ValidationFailure _self;
  final $Res Function(ValidationFailure) _then;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,Object? message = null,Object? fieldErrors = null,}) {
  return _then(ValidationFailure(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,fieldErrors: null == fieldErrors ? _self._fieldErrors : fieldErrors // ignore: cast_nullable_to_non_nullable
as List<FieldError>,
  ));
}


}

/// @nodoc


class ConflictFailure implements Failure {
  const ConflictFailure({required this.code, this.message = ''});
  

@override final  String code;
@override@JsonKey() final  String message;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ConflictFailureCopyWith<ConflictFailure> get copyWith => _$ConflictFailureCopyWithImpl<ConflictFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ConflictFailure&&(identical(other.code, code) || other.code == code)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,code,message);

@override
String toString() {
  return 'Failure.conflict(code: $code, message: $message)';
}


}

/// @nodoc
abstract mixin class $ConflictFailureCopyWith<$Res> implements $FailureCopyWith<$Res> {
  factory $ConflictFailureCopyWith(ConflictFailure value, $Res Function(ConflictFailure) _then) = _$ConflictFailureCopyWithImpl;
@override @useResult
$Res call({
 String code, String message
});




}
/// @nodoc
class _$ConflictFailureCopyWithImpl<$Res>
    implements $ConflictFailureCopyWith<$Res> {
  _$ConflictFailureCopyWithImpl(this._self, this._then);

  final ConflictFailure _self;
  final $Res Function(ConflictFailure) _then;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,Object? message = null,}) {
  return _then(ConflictFailure(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class DomainRuleFailure implements Failure {
  const DomainRuleFailure({required this.code, this.message = ''});
  

@override final  String code;
@override@JsonKey() final  String message;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DomainRuleFailureCopyWith<DomainRuleFailure> get copyWith => _$DomainRuleFailureCopyWithImpl<DomainRuleFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DomainRuleFailure&&(identical(other.code, code) || other.code == code)&&(identical(other.message, message) || other.message == message));
}


@override
int get hashCode => Object.hash(runtimeType,code,message);

@override
String toString() {
  return 'Failure.domainRule(code: $code, message: $message)';
}


}

/// @nodoc
abstract mixin class $DomainRuleFailureCopyWith<$Res> implements $FailureCopyWith<$Res> {
  factory $DomainRuleFailureCopyWith(DomainRuleFailure value, $Res Function(DomainRuleFailure) _then) = _$DomainRuleFailureCopyWithImpl;
@override @useResult
$Res call({
 String code, String message
});




}
/// @nodoc
class _$DomainRuleFailureCopyWithImpl<$Res>
    implements $DomainRuleFailureCopyWith<$Res> {
  _$DomainRuleFailureCopyWithImpl(this._self, this._then);

  final DomainRuleFailure _self;
  final $Res Function(DomainRuleFailure) _then;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,Object? message = null,}) {
  return _then(DomainRuleFailure(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class RateLimitFailure implements Failure {
  const RateLimitFailure({required this.code, this.message = '', this.retryAfter});
  

@override final  String code;
@override@JsonKey() final  String message;
 final  Duration? retryAfter;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RateLimitFailureCopyWith<RateLimitFailure> get copyWith => _$RateLimitFailureCopyWithImpl<RateLimitFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RateLimitFailure&&(identical(other.code, code) || other.code == code)&&(identical(other.message, message) || other.message == message)&&(identical(other.retryAfter, retryAfter) || other.retryAfter == retryAfter));
}


@override
int get hashCode => Object.hash(runtimeType,code,message,retryAfter);

@override
String toString() {
  return 'Failure.rateLimit(code: $code, message: $message, retryAfter: $retryAfter)';
}


}

/// @nodoc
abstract mixin class $RateLimitFailureCopyWith<$Res> implements $FailureCopyWith<$Res> {
  factory $RateLimitFailureCopyWith(RateLimitFailure value, $Res Function(RateLimitFailure) _then) = _$RateLimitFailureCopyWithImpl;
@override @useResult
$Res call({
 String code, String message, Duration? retryAfter
});




}
/// @nodoc
class _$RateLimitFailureCopyWithImpl<$Res>
    implements $RateLimitFailureCopyWith<$Res> {
  _$RateLimitFailureCopyWithImpl(this._self, this._then);

  final RateLimitFailure _self;
  final $Res Function(RateLimitFailure) _then;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,Object? message = null,Object? retryAfter = freezed,}) {
  return _then(RateLimitFailure(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,retryAfter: freezed == retryAfter ? _self.retryAfter : retryAfter // ignore: cast_nullable_to_non_nullable
as Duration?,
  ));
}


}

/// @nodoc


class UnexpectedFailure implements Failure {
  const UnexpectedFailure({required this.code, this.message = '', this.requestId});
  

@override final  String code;
@override@JsonKey() final  String message;
 final  String? requestId;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UnexpectedFailureCopyWith<UnexpectedFailure> get copyWith => _$UnexpectedFailureCopyWithImpl<UnexpectedFailure>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UnexpectedFailure&&(identical(other.code, code) || other.code == code)&&(identical(other.message, message) || other.message == message)&&(identical(other.requestId, requestId) || other.requestId == requestId));
}


@override
int get hashCode => Object.hash(runtimeType,code,message,requestId);

@override
String toString() {
  return 'Failure.unexpected(code: $code, message: $message, requestId: $requestId)';
}


}

/// @nodoc
abstract mixin class $UnexpectedFailureCopyWith<$Res> implements $FailureCopyWith<$Res> {
  factory $UnexpectedFailureCopyWith(UnexpectedFailure value, $Res Function(UnexpectedFailure) _then) = _$UnexpectedFailureCopyWithImpl;
@override @useResult
$Res call({
 String code, String message, String? requestId
});




}
/// @nodoc
class _$UnexpectedFailureCopyWithImpl<$Res>
    implements $UnexpectedFailureCopyWith<$Res> {
  _$UnexpectedFailureCopyWithImpl(this._self, this._then);

  final UnexpectedFailure _self;
  final $Res Function(UnexpectedFailure) _then;

/// Create a copy of Failure
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,Object? message = null,Object? requestId = freezed,}) {
  return _then(UnexpectedFailure(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,requestId: freezed == requestId ? _self.requestId : requestId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on

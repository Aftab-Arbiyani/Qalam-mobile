// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'api_envelope.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ApiErrorPayload {

 String get code; String get message; List<Object?> get details; String? get requestId;
/// Create a copy of ApiErrorPayload
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ApiErrorPayloadCopyWith<ApiErrorPayload> get copyWith => _$ApiErrorPayloadCopyWithImpl<ApiErrorPayload>(this as ApiErrorPayload, _$identity);

  /// Serializes this ApiErrorPayload to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ApiErrorPayload&&(identical(other.code, code) || other.code == code)&&(identical(other.message, message) || other.message == message)&&const DeepCollectionEquality().equals(other.details, details)&&(identical(other.requestId, requestId) || other.requestId == requestId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code,message,const DeepCollectionEquality().hash(details),requestId);

@override
String toString() {
  return 'ApiErrorPayload(code: $code, message: $message, details: $details, requestId: $requestId)';
}


}

/// @nodoc
abstract mixin class $ApiErrorPayloadCopyWith<$Res>  {
  factory $ApiErrorPayloadCopyWith(ApiErrorPayload value, $Res Function(ApiErrorPayload) _then) = _$ApiErrorPayloadCopyWithImpl;
@useResult
$Res call({
 String code, String message, List<Object?> details, String? requestId
});




}
/// @nodoc
class _$ApiErrorPayloadCopyWithImpl<$Res>
    implements $ApiErrorPayloadCopyWith<$Res> {
  _$ApiErrorPayloadCopyWithImpl(this._self, this._then);

  final ApiErrorPayload _self;
  final $Res Function(ApiErrorPayload) _then;

/// Create a copy of ApiErrorPayload
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = null,Object? message = null,Object? details = null,Object? requestId = freezed,}) {
  return _then(_self.copyWith(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,details: null == details ? _self.details : details // ignore: cast_nullable_to_non_nullable
as List<Object?>,requestId: freezed == requestId ? _self.requestId : requestId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ApiErrorPayload].
extension ApiErrorPayloadPatterns on ApiErrorPayload {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ApiErrorPayload value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ApiErrorPayload() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ApiErrorPayload value)  $default,){
final _that = this;
switch (_that) {
case _ApiErrorPayload():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ApiErrorPayload value)?  $default,){
final _that = this;
switch (_that) {
case _ApiErrorPayload() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String code,  String message,  List<Object?> details,  String? requestId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ApiErrorPayload() when $default != null:
return $default(_that.code,_that.message,_that.details,_that.requestId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String code,  String message,  List<Object?> details,  String? requestId)  $default,) {final _that = this;
switch (_that) {
case _ApiErrorPayload():
return $default(_that.code,_that.message,_that.details,_that.requestId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String code,  String message,  List<Object?> details,  String? requestId)?  $default,) {final _that = this;
switch (_that) {
case _ApiErrorPayload() when $default != null:
return $default(_that.code,_that.message,_that.details,_that.requestId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ApiErrorPayload implements ApiErrorPayload {
  const _ApiErrorPayload({required this.code, this.message = '', final  List<Object?> details = const <Object?>[], this.requestId}): _details = details;
  factory _ApiErrorPayload.fromJson(Map<String, dynamic> json) => _$ApiErrorPayloadFromJson(json);

@override final  String code;
@override@JsonKey() final  String message;
 final  List<Object?> _details;
@override@JsonKey() List<Object?> get details {
  if (_details is EqualUnmodifiableListView) return _details;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_details);
}

@override final  String? requestId;

/// Create a copy of ApiErrorPayload
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ApiErrorPayloadCopyWith<_ApiErrorPayload> get copyWith => __$ApiErrorPayloadCopyWithImpl<_ApiErrorPayload>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ApiErrorPayloadToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ApiErrorPayload&&(identical(other.code, code) || other.code == code)&&(identical(other.message, message) || other.message == message)&&const DeepCollectionEquality().equals(other._details, _details)&&(identical(other.requestId, requestId) || other.requestId == requestId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code,message,const DeepCollectionEquality().hash(_details),requestId);

@override
String toString() {
  return 'ApiErrorPayload(code: $code, message: $message, details: $details, requestId: $requestId)';
}


}

/// @nodoc
abstract mixin class _$ApiErrorPayloadCopyWith<$Res> implements $ApiErrorPayloadCopyWith<$Res> {
  factory _$ApiErrorPayloadCopyWith(_ApiErrorPayload value, $Res Function(_ApiErrorPayload) _then) = __$ApiErrorPayloadCopyWithImpl;
@override @useResult
$Res call({
 String code, String message, List<Object?> details, String? requestId
});




}
/// @nodoc
class __$ApiErrorPayloadCopyWithImpl<$Res>
    implements _$ApiErrorPayloadCopyWith<$Res> {
  __$ApiErrorPayloadCopyWithImpl(this._self, this._then);

  final _ApiErrorPayload _self;
  final $Res Function(_ApiErrorPayload) _then;

/// Create a copy of ApiErrorPayload
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,Object? message = null,Object? details = null,Object? requestId = freezed,}) {
  return _then(_ApiErrorPayload(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,details: null == details ? _self._details : details // ignore: cast_nullable_to_non_nullable
as List<Object?>,requestId: freezed == requestId ? _self.requestId : requestId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$FieldError {

 String get field; String get rule; String get message;
/// Create a copy of FieldError
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FieldErrorCopyWith<FieldError> get copyWith => _$FieldErrorCopyWithImpl<FieldError>(this as FieldError, _$identity);

  /// Serializes this FieldError to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FieldError&&(identical(other.field, field) || other.field == field)&&(identical(other.rule, rule) || other.rule == rule)&&(identical(other.message, message) || other.message == message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,field,rule,message);

@override
String toString() {
  return 'FieldError(field: $field, rule: $rule, message: $message)';
}


}

/// @nodoc
abstract mixin class $FieldErrorCopyWith<$Res>  {
  factory $FieldErrorCopyWith(FieldError value, $Res Function(FieldError) _then) = _$FieldErrorCopyWithImpl;
@useResult
$Res call({
 String field, String rule, String message
});




}
/// @nodoc
class _$FieldErrorCopyWithImpl<$Res>
    implements $FieldErrorCopyWith<$Res> {
  _$FieldErrorCopyWithImpl(this._self, this._then);

  final FieldError _self;
  final $Res Function(FieldError) _then;

/// Create a copy of FieldError
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? field = null,Object? rule = null,Object? message = null,}) {
  return _then(_self.copyWith(
field: null == field ? _self.field : field // ignore: cast_nullable_to_non_nullable
as String,rule: null == rule ? _self.rule : rule // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [FieldError].
extension FieldErrorPatterns on FieldError {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FieldError value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FieldError() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FieldError value)  $default,){
final _that = this;
switch (_that) {
case _FieldError():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FieldError value)?  $default,){
final _that = this;
switch (_that) {
case _FieldError() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String field,  String rule,  String message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FieldError() when $default != null:
return $default(_that.field,_that.rule,_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String field,  String rule,  String message)  $default,) {final _that = this;
switch (_that) {
case _FieldError():
return $default(_that.field,_that.rule,_that.message);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String field,  String rule,  String message)?  $default,) {final _that = this;
switch (_that) {
case _FieldError() when $default != null:
return $default(_that.field,_that.rule,_that.message);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FieldError implements FieldError {
  const _FieldError({required this.field, this.rule = '', this.message = ''});
  factory _FieldError.fromJson(Map<String, dynamic> json) => _$FieldErrorFromJson(json);

@override final  String field;
@override@JsonKey() final  String rule;
@override@JsonKey() final  String message;

/// Create a copy of FieldError
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FieldErrorCopyWith<_FieldError> get copyWith => __$FieldErrorCopyWithImpl<_FieldError>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FieldErrorToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FieldError&&(identical(other.field, field) || other.field == field)&&(identical(other.rule, rule) || other.rule == rule)&&(identical(other.message, message) || other.message == message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,field,rule,message);

@override
String toString() {
  return 'FieldError(field: $field, rule: $rule, message: $message)';
}


}

/// @nodoc
abstract mixin class _$FieldErrorCopyWith<$Res> implements $FieldErrorCopyWith<$Res> {
  factory _$FieldErrorCopyWith(_FieldError value, $Res Function(_FieldError) _then) = __$FieldErrorCopyWithImpl;
@override @useResult
$Res call({
 String field, String rule, String message
});




}
/// @nodoc
class __$FieldErrorCopyWithImpl<$Res>
    implements _$FieldErrorCopyWith<$Res> {
  __$FieldErrorCopyWithImpl(this._self, this._then);

  final _FieldError _self;
  final $Res Function(_FieldError) _then;

/// Create a copy of FieldError
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? field = null,Object? rule = null,Object? message = null,}) {
  return _then(_FieldError(
field: null == field ? _self.field : field // ignore: cast_nullable_to_non_nullable
as String,rule: null == rule ? _self.rule : rule // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$CursorMeta {

 String? get nextCursor; bool get hasMore; int get limit;
/// Create a copy of CursorMeta
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CursorMetaCopyWith<CursorMeta> get copyWith => _$CursorMetaCopyWithImpl<CursorMeta>(this as CursorMeta, _$identity);

  /// Serializes this CursorMeta to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CursorMeta&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore)&&(identical(other.limit, limit) || other.limit == limit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,nextCursor,hasMore,limit);

@override
String toString() {
  return 'CursorMeta(nextCursor: $nextCursor, hasMore: $hasMore, limit: $limit)';
}


}

/// @nodoc
abstract mixin class $CursorMetaCopyWith<$Res>  {
  factory $CursorMetaCopyWith(CursorMeta value, $Res Function(CursorMeta) _then) = _$CursorMetaCopyWithImpl;
@useResult
$Res call({
 String? nextCursor, bool hasMore, int limit
});




}
/// @nodoc
class _$CursorMetaCopyWithImpl<$Res>
    implements $CursorMetaCopyWith<$Res> {
  _$CursorMetaCopyWithImpl(this._self, this._then);

  final CursorMeta _self;
  final $Res Function(CursorMeta) _then;

/// Create a copy of CursorMeta
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? nextCursor = freezed,Object? hasMore = null,Object? limit = null,}) {
  return _then(_self.copyWith(
nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [CursorMeta].
extension CursorMetaPatterns on CursorMeta {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CursorMeta value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CursorMeta() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CursorMeta value)  $default,){
final _that = this;
switch (_that) {
case _CursorMeta():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CursorMeta value)?  $default,){
final _that = this;
switch (_that) {
case _CursorMeta() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? nextCursor,  bool hasMore,  int limit)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CursorMeta() when $default != null:
return $default(_that.nextCursor,_that.hasMore,_that.limit);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? nextCursor,  bool hasMore,  int limit)  $default,) {final _that = this;
switch (_that) {
case _CursorMeta():
return $default(_that.nextCursor,_that.hasMore,_that.limit);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? nextCursor,  bool hasMore,  int limit)?  $default,) {final _that = this;
switch (_that) {
case _CursorMeta() when $default != null:
return $default(_that.nextCursor,_that.hasMore,_that.limit);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CursorMeta implements CursorMeta {
  const _CursorMeta({this.nextCursor, this.hasMore = false, this.limit = 20});
  factory _CursorMeta.fromJson(Map<String, dynamic> json) => _$CursorMetaFromJson(json);

@override final  String? nextCursor;
@override@JsonKey() final  bool hasMore;
@override@JsonKey() final  int limit;

/// Create a copy of CursorMeta
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CursorMetaCopyWith<_CursorMeta> get copyWith => __$CursorMetaCopyWithImpl<_CursorMeta>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CursorMetaToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CursorMeta&&(identical(other.nextCursor, nextCursor) || other.nextCursor == nextCursor)&&(identical(other.hasMore, hasMore) || other.hasMore == hasMore)&&(identical(other.limit, limit) || other.limit == limit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,nextCursor,hasMore,limit);

@override
String toString() {
  return 'CursorMeta(nextCursor: $nextCursor, hasMore: $hasMore, limit: $limit)';
}


}

/// @nodoc
abstract mixin class _$CursorMetaCopyWith<$Res> implements $CursorMetaCopyWith<$Res> {
  factory _$CursorMetaCopyWith(_CursorMeta value, $Res Function(_CursorMeta) _then) = __$CursorMetaCopyWithImpl;
@override @useResult
$Res call({
 String? nextCursor, bool hasMore, int limit
});




}
/// @nodoc
class __$CursorMetaCopyWithImpl<$Res>
    implements _$CursorMetaCopyWith<$Res> {
  __$CursorMetaCopyWithImpl(this._self, this._then);

  final _CursorMeta _self;
  final $Res Function(_CursorMeta) _then;

/// Create a copy of CursorMeta
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? nextCursor = freezed,Object? hasMore = null,Object? limit = null,}) {
  return _then(_CursorMeta(
nextCursor: freezed == nextCursor ? _self.nextCursor : nextCursor // ignore: cast_nullable_to_non_nullable
as String?,hasMore: null == hasMore ? _self.hasMore : hasMore // ignore: cast_nullable_to_non_nullable
as bool,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$OffsetMeta {

 int get page; int get limit; int get total; int get totalPages;
/// Create a copy of OffsetMeta
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OffsetMetaCopyWith<OffsetMeta> get copyWith => _$OffsetMetaCopyWithImpl<OffsetMeta>(this as OffsetMeta, _$identity);

  /// Serializes this OffsetMeta to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OffsetMeta&&(identical(other.page, page) || other.page == page)&&(identical(other.limit, limit) || other.limit == limit)&&(identical(other.total, total) || other.total == total)&&(identical(other.totalPages, totalPages) || other.totalPages == totalPages));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,page,limit,total,totalPages);

@override
String toString() {
  return 'OffsetMeta(page: $page, limit: $limit, total: $total, totalPages: $totalPages)';
}


}

/// @nodoc
abstract mixin class $OffsetMetaCopyWith<$Res>  {
  factory $OffsetMetaCopyWith(OffsetMeta value, $Res Function(OffsetMeta) _then) = _$OffsetMetaCopyWithImpl;
@useResult
$Res call({
 int page, int limit, int total, int totalPages
});




}
/// @nodoc
class _$OffsetMetaCopyWithImpl<$Res>
    implements $OffsetMetaCopyWith<$Res> {
  _$OffsetMetaCopyWithImpl(this._self, this._then);

  final OffsetMeta _self;
  final $Res Function(OffsetMeta) _then;

/// Create a copy of OffsetMeta
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? page = null,Object? limit = null,Object? total = null,Object? totalPages = null,}) {
  return _then(_self.copyWith(
page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,totalPages: null == totalPages ? _self.totalPages : totalPages // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [OffsetMeta].
extension OffsetMetaPatterns on OffsetMeta {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OffsetMeta value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OffsetMeta() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OffsetMeta value)  $default,){
final _that = this;
switch (_that) {
case _OffsetMeta():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OffsetMeta value)?  $default,){
final _that = this;
switch (_that) {
case _OffsetMeta() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int page,  int limit,  int total,  int totalPages)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OffsetMeta() when $default != null:
return $default(_that.page,_that.limit,_that.total,_that.totalPages);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int page,  int limit,  int total,  int totalPages)  $default,) {final _that = this;
switch (_that) {
case _OffsetMeta():
return $default(_that.page,_that.limit,_that.total,_that.totalPages);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int page,  int limit,  int total,  int totalPages)?  $default,) {final _that = this;
switch (_that) {
case _OffsetMeta() when $default != null:
return $default(_that.page,_that.limit,_that.total,_that.totalPages);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OffsetMeta implements OffsetMeta {
  const _OffsetMeta({this.page = 1, this.limit = 20, this.total = 0, this.totalPages = 0});
  factory _OffsetMeta.fromJson(Map<String, dynamic> json) => _$OffsetMetaFromJson(json);

@override@JsonKey() final  int page;
@override@JsonKey() final  int limit;
@override@JsonKey() final  int total;
@override@JsonKey() final  int totalPages;

/// Create a copy of OffsetMeta
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OffsetMetaCopyWith<_OffsetMeta> get copyWith => __$OffsetMetaCopyWithImpl<_OffsetMeta>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OffsetMetaToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OffsetMeta&&(identical(other.page, page) || other.page == page)&&(identical(other.limit, limit) || other.limit == limit)&&(identical(other.total, total) || other.total == total)&&(identical(other.totalPages, totalPages) || other.totalPages == totalPages));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,page,limit,total,totalPages);

@override
String toString() {
  return 'OffsetMeta(page: $page, limit: $limit, total: $total, totalPages: $totalPages)';
}


}

/// @nodoc
abstract mixin class _$OffsetMetaCopyWith<$Res> implements $OffsetMetaCopyWith<$Res> {
  factory _$OffsetMetaCopyWith(_OffsetMeta value, $Res Function(_OffsetMeta) _then) = __$OffsetMetaCopyWithImpl;
@override @useResult
$Res call({
 int page, int limit, int total, int totalPages
});




}
/// @nodoc
class __$OffsetMetaCopyWithImpl<$Res>
    implements _$OffsetMetaCopyWith<$Res> {
  __$OffsetMetaCopyWithImpl(this._self, this._then);

  final _OffsetMeta _self;
  final $Res Function(_OffsetMeta) _then;

/// Create a copy of OffsetMeta
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? page = null,Object? limit = null,Object? total = null,Object? totalPages = null,}) {
  return _then(_OffsetMeta(
page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,limit: null == limit ? _self.limit : limit // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,totalPages: null == totalPages ? _self.totalPages : totalPages // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on

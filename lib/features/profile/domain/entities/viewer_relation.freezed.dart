// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'viewer_relation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ViewerRelation {

 bool get isSelf; bool get isFollowing; bool get hasPendingRequest;
/// Create a copy of ViewerRelation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ViewerRelationCopyWith<ViewerRelation> get copyWith => _$ViewerRelationCopyWithImpl<ViewerRelation>(this as ViewerRelation, _$identity);

  /// Serializes this ViewerRelation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ViewerRelation&&(identical(other.isSelf, isSelf) || other.isSelf == isSelf)&&(identical(other.isFollowing, isFollowing) || other.isFollowing == isFollowing)&&(identical(other.hasPendingRequest, hasPendingRequest) || other.hasPendingRequest == hasPendingRequest));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,isSelf,isFollowing,hasPendingRequest);

@override
String toString() {
  return 'ViewerRelation(isSelf: $isSelf, isFollowing: $isFollowing, hasPendingRequest: $hasPendingRequest)';
}


}

/// @nodoc
abstract mixin class $ViewerRelationCopyWith<$Res>  {
  factory $ViewerRelationCopyWith(ViewerRelation value, $Res Function(ViewerRelation) _then) = _$ViewerRelationCopyWithImpl;
@useResult
$Res call({
 bool isSelf, bool isFollowing, bool hasPendingRequest
});




}
/// @nodoc
class _$ViewerRelationCopyWithImpl<$Res>
    implements $ViewerRelationCopyWith<$Res> {
  _$ViewerRelationCopyWithImpl(this._self, this._then);

  final ViewerRelation _self;
  final $Res Function(ViewerRelation) _then;

/// Create a copy of ViewerRelation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isSelf = null,Object? isFollowing = null,Object? hasPendingRequest = null,}) {
  return _then(_self.copyWith(
isSelf: null == isSelf ? _self.isSelf : isSelf // ignore: cast_nullable_to_non_nullable
as bool,isFollowing: null == isFollowing ? _self.isFollowing : isFollowing // ignore: cast_nullable_to_non_nullable
as bool,hasPendingRequest: null == hasPendingRequest ? _self.hasPendingRequest : hasPendingRequest // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ViewerRelation].
extension ViewerRelationPatterns on ViewerRelation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ViewerRelation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ViewerRelation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ViewerRelation value)  $default,){
final _that = this;
switch (_that) {
case _ViewerRelation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ViewerRelation value)?  $default,){
final _that = this;
switch (_that) {
case _ViewerRelation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isSelf,  bool isFollowing,  bool hasPendingRequest)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ViewerRelation() when $default != null:
return $default(_that.isSelf,_that.isFollowing,_that.hasPendingRequest);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isSelf,  bool isFollowing,  bool hasPendingRequest)  $default,) {final _that = this;
switch (_that) {
case _ViewerRelation():
return $default(_that.isSelf,_that.isFollowing,_that.hasPendingRequest);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isSelf,  bool isFollowing,  bool hasPendingRequest)?  $default,) {final _that = this;
switch (_that) {
case _ViewerRelation() when $default != null:
return $default(_that.isSelf,_that.isFollowing,_that.hasPendingRequest);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ViewerRelation implements ViewerRelation {
  const _ViewerRelation({this.isSelf = false, this.isFollowing = false, this.hasPendingRequest = false});
  factory _ViewerRelation.fromJson(Map<String, dynamic> json) => _$ViewerRelationFromJson(json);

@override@JsonKey() final  bool isSelf;
@override@JsonKey() final  bool isFollowing;
@override@JsonKey() final  bool hasPendingRequest;

/// Create a copy of ViewerRelation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ViewerRelationCopyWith<_ViewerRelation> get copyWith => __$ViewerRelationCopyWithImpl<_ViewerRelation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ViewerRelationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ViewerRelation&&(identical(other.isSelf, isSelf) || other.isSelf == isSelf)&&(identical(other.isFollowing, isFollowing) || other.isFollowing == isFollowing)&&(identical(other.hasPendingRequest, hasPendingRequest) || other.hasPendingRequest == hasPendingRequest));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,isSelf,isFollowing,hasPendingRequest);

@override
String toString() {
  return 'ViewerRelation(isSelf: $isSelf, isFollowing: $isFollowing, hasPendingRequest: $hasPendingRequest)';
}


}

/// @nodoc
abstract mixin class _$ViewerRelationCopyWith<$Res> implements $ViewerRelationCopyWith<$Res> {
  factory _$ViewerRelationCopyWith(_ViewerRelation value, $Res Function(_ViewerRelation) _then) = __$ViewerRelationCopyWithImpl;
@override @useResult
$Res call({
 bool isSelf, bool isFollowing, bool hasPendingRequest
});




}
/// @nodoc
class __$ViewerRelationCopyWithImpl<$Res>
    implements _$ViewerRelationCopyWith<$Res> {
  __$ViewerRelationCopyWithImpl(this._self, this._then);

  final _ViewerRelation _self;
  final $Res Function(_ViewerRelation) _then;

/// Create a copy of ViewerRelation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isSelf = null,Object? isFollowing = null,Object? hasPendingRequest = null,}) {
  return _then(_ViewerRelation(
isSelf: null == isSelf ? _self.isSelf : isSelf // ignore: cast_nullable_to_non_nullable
as bool,isFollowing: null == isFollowing ? _self.isFollowing : isFollowing // ignore: cast_nullable_to_non_nullable
as bool,hasPendingRequest: null == hasPendingRequest ? _self.hasPendingRequest : hasPendingRequest // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on

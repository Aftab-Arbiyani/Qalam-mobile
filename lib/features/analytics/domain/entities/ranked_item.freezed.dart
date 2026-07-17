// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ranked_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RankedItem {

 String get key; String get label; int get count;
/// Create a copy of RankedItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RankedItemCopyWith<RankedItem> get copyWith => _$RankedItemCopyWithImpl<RankedItem>(this as RankedItem, _$identity);

  /// Serializes this RankedItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RankedItem&&(identical(other.key, key) || other.key == key)&&(identical(other.label, label) || other.label == label)&&(identical(other.count, count) || other.count == count));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,key,label,count);

@override
String toString() {
  return 'RankedItem(key: $key, label: $label, count: $count)';
}


}

/// @nodoc
abstract mixin class $RankedItemCopyWith<$Res>  {
  factory $RankedItemCopyWith(RankedItem value, $Res Function(RankedItem) _then) = _$RankedItemCopyWithImpl;
@useResult
$Res call({
 String key, String label, int count
});




}
/// @nodoc
class _$RankedItemCopyWithImpl<$Res>
    implements $RankedItemCopyWith<$Res> {
  _$RankedItemCopyWithImpl(this._self, this._then);

  final RankedItem _self;
  final $Res Function(RankedItem) _then;

/// Create a copy of RankedItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? key = null,Object? label = null,Object? count = null,}) {
  return _then(_self.copyWith(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [RankedItem].
extension RankedItemPatterns on RankedItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RankedItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RankedItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RankedItem value)  $default,){
final _that = this;
switch (_that) {
case _RankedItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RankedItem value)?  $default,){
final _that = this;
switch (_that) {
case _RankedItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String key,  String label,  int count)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RankedItem() when $default != null:
return $default(_that.key,_that.label,_that.count);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String key,  String label,  int count)  $default,) {final _that = this;
switch (_that) {
case _RankedItem():
return $default(_that.key,_that.label,_that.count);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String key,  String label,  int count)?  $default,) {final _that = this;
switch (_that) {
case _RankedItem() when $default != null:
return $default(_that.key,_that.label,_that.count);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RankedItem implements RankedItem {
  const _RankedItem({this.key = '', this.label = '', this.count = 0});
  factory _RankedItem.fromJson(Map<String, dynamic> json) => _$RankedItemFromJson(json);

@override@JsonKey() final  String key;
@override@JsonKey() final  String label;
@override@JsonKey() final  int count;

/// Create a copy of RankedItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RankedItemCopyWith<_RankedItem> get copyWith => __$RankedItemCopyWithImpl<_RankedItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RankedItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RankedItem&&(identical(other.key, key) || other.key == key)&&(identical(other.label, label) || other.label == label)&&(identical(other.count, count) || other.count == count));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,key,label,count);

@override
String toString() {
  return 'RankedItem(key: $key, label: $label, count: $count)';
}


}

/// @nodoc
abstract mixin class _$RankedItemCopyWith<$Res> implements $RankedItemCopyWith<$Res> {
  factory _$RankedItemCopyWith(_RankedItem value, $Res Function(_RankedItem) _then) = __$RankedItemCopyWithImpl;
@override @useResult
$Res call({
 String key, String label, int count
});




}
/// @nodoc
class __$RankedItemCopyWithImpl<$Res>
    implements _$RankedItemCopyWith<$Res> {
  __$RankedItemCopyWithImpl(this._self, this._then);

  final _RankedItem _self;
  final $Res Function(_RankedItem) _then;

/// Create a copy of RankedItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? key = null,Object? label = null,Object? count = null,}) {
  return _then(_RankedItem(
key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on

// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'taxonomy.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$LanguageRef {

 String get code; String get nativeName; TextDirectionKind get direction;
/// Create a copy of LanguageRef
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LanguageRefCopyWith<LanguageRef> get copyWith => _$LanguageRefCopyWithImpl<LanguageRef>(this as LanguageRef, _$identity);

  /// Serializes this LanguageRef to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LanguageRef&&(identical(other.code, code) || other.code == code)&&(identical(other.nativeName, nativeName) || other.nativeName == nativeName)&&(identical(other.direction, direction) || other.direction == direction));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code,nativeName,direction);

@override
String toString() {
  return 'LanguageRef(code: $code, nativeName: $nativeName, direction: $direction)';
}


}

/// @nodoc
abstract mixin class $LanguageRefCopyWith<$Res>  {
  factory $LanguageRefCopyWith(LanguageRef value, $Res Function(LanguageRef) _then) = _$LanguageRefCopyWithImpl;
@useResult
$Res call({
 String code, String nativeName, TextDirectionKind direction
});




}
/// @nodoc
class _$LanguageRefCopyWithImpl<$Res>
    implements $LanguageRefCopyWith<$Res> {
  _$LanguageRefCopyWithImpl(this._self, this._then);

  final LanguageRef _self;
  final $Res Function(LanguageRef) _then;

/// Create a copy of LanguageRef
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = null,Object? nativeName = null,Object? direction = null,}) {
  return _then(_self.copyWith(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,nativeName: null == nativeName ? _self.nativeName : nativeName // ignore: cast_nullable_to_non_nullable
as String,direction: null == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as TextDirectionKind,
  ));
}

}


/// Adds pattern-matching-related methods to [LanguageRef].
extension LanguageRefPatterns on LanguageRef {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LanguageRef value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LanguageRef() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LanguageRef value)  $default,){
final _that = this;
switch (_that) {
case _LanguageRef():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LanguageRef value)?  $default,){
final _that = this;
switch (_that) {
case _LanguageRef() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String code,  String nativeName,  TextDirectionKind direction)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LanguageRef() when $default != null:
return $default(_that.code,_that.nativeName,_that.direction);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String code,  String nativeName,  TextDirectionKind direction)  $default,) {final _that = this;
switch (_that) {
case _LanguageRef():
return $default(_that.code,_that.nativeName,_that.direction);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String code,  String nativeName,  TextDirectionKind direction)?  $default,) {final _that = this;
switch (_that) {
case _LanguageRef() when $default != null:
return $default(_that.code,_that.nativeName,_that.direction);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LanguageRef implements LanguageRef {
  const _LanguageRef({required this.code, this.nativeName = '', this.direction = TextDirectionKind.ltr});
  factory _LanguageRef.fromJson(Map<String, dynamic> json) => _$LanguageRefFromJson(json);

@override final  String code;
@override@JsonKey() final  String nativeName;
@override@JsonKey() final  TextDirectionKind direction;

/// Create a copy of LanguageRef
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LanguageRefCopyWith<_LanguageRef> get copyWith => __$LanguageRefCopyWithImpl<_LanguageRef>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LanguageRefToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LanguageRef&&(identical(other.code, code) || other.code == code)&&(identical(other.nativeName, nativeName) || other.nativeName == nativeName)&&(identical(other.direction, direction) || other.direction == direction));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code,nativeName,direction);

@override
String toString() {
  return 'LanguageRef(code: $code, nativeName: $nativeName, direction: $direction)';
}


}

/// @nodoc
abstract mixin class _$LanguageRefCopyWith<$Res> implements $LanguageRefCopyWith<$Res> {
  factory _$LanguageRefCopyWith(_LanguageRef value, $Res Function(_LanguageRef) _then) = __$LanguageRefCopyWithImpl;
@override @useResult
$Res call({
 String code, String nativeName, TextDirectionKind direction
});




}
/// @nodoc
class __$LanguageRefCopyWithImpl<$Res>
    implements _$LanguageRefCopyWith<$Res> {
  __$LanguageRefCopyWithImpl(this._self, this._then);

  final _LanguageRef _self;
  final $Res Function(_LanguageRef) _then;

/// Create a copy of LanguageRef
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,Object? nativeName = null,Object? direction = null,}) {
  return _then(_LanguageRef(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,nativeName: null == nativeName ? _self.nativeName : nativeName // ignore: cast_nullable_to_non_nullable
as String,direction: null == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as TextDirectionKind,
  ));
}


}


/// @nodoc
mixin _$GenreRef {

 String get slug; String get name;
/// Create a copy of GenreRef
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GenreRefCopyWith<GenreRef> get copyWith => _$GenreRefCopyWithImpl<GenreRef>(this as GenreRef, _$identity);

  /// Serializes this GenreRef to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GenreRef&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,slug,name);

@override
String toString() {
  return 'GenreRef(slug: $slug, name: $name)';
}


}

/// @nodoc
abstract mixin class $GenreRefCopyWith<$Res>  {
  factory $GenreRefCopyWith(GenreRef value, $Res Function(GenreRef) _then) = _$GenreRefCopyWithImpl;
@useResult
$Res call({
 String slug, String name
});




}
/// @nodoc
class _$GenreRefCopyWithImpl<$Res>
    implements $GenreRefCopyWith<$Res> {
  _$GenreRefCopyWithImpl(this._self, this._then);

  final GenreRef _self;
  final $Res Function(GenreRef) _then;

/// Create a copy of GenreRef
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? slug = null,Object? name = null,}) {
  return _then(_self.copyWith(
slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [GenreRef].
extension GenreRefPatterns on GenreRef {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GenreRef value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GenreRef() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GenreRef value)  $default,){
final _that = this;
switch (_that) {
case _GenreRef():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GenreRef value)?  $default,){
final _that = this;
switch (_that) {
case _GenreRef() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String slug,  String name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GenreRef() when $default != null:
return $default(_that.slug,_that.name);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String slug,  String name)  $default,) {final _that = this;
switch (_that) {
case _GenreRef():
return $default(_that.slug,_that.name);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String slug,  String name)?  $default,) {final _that = this;
switch (_that) {
case _GenreRef() when $default != null:
return $default(_that.slug,_that.name);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GenreRef implements GenreRef {
  const _GenreRef({required this.slug, this.name = ''});
  factory _GenreRef.fromJson(Map<String, dynamic> json) => _$GenreRefFromJson(json);

@override final  String slug;
@override@JsonKey() final  String name;

/// Create a copy of GenreRef
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GenreRefCopyWith<_GenreRef> get copyWith => __$GenreRefCopyWithImpl<_GenreRef>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GenreRefToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GenreRef&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,slug,name);

@override
String toString() {
  return 'GenreRef(slug: $slug, name: $name)';
}


}

/// @nodoc
abstract mixin class _$GenreRefCopyWith<$Res> implements $GenreRefCopyWith<$Res> {
  factory _$GenreRefCopyWith(_GenreRef value, $Res Function(_GenreRef) _then) = __$GenreRefCopyWithImpl;
@override @useResult
$Res call({
 String slug, String name
});




}
/// @nodoc
class __$GenreRefCopyWithImpl<$Res>
    implements _$GenreRefCopyWith<$Res> {
  __$GenreRefCopyWithImpl(this._self, this._then);

  final _GenreRef _self;
  final $Res Function(_GenreRef) _then;

/// Create a copy of GenreRef
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? slug = null,Object? name = null,}) {
  return _then(_GenreRef(
slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$TagRef {

 String get slug; String get name;
/// Create a copy of TagRef
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TagRefCopyWith<TagRef> get copyWith => _$TagRefCopyWithImpl<TagRef>(this as TagRef, _$identity);

  /// Serializes this TagRef to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TagRef&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,slug,name);

@override
String toString() {
  return 'TagRef(slug: $slug, name: $name)';
}


}

/// @nodoc
abstract mixin class $TagRefCopyWith<$Res>  {
  factory $TagRefCopyWith(TagRef value, $Res Function(TagRef) _then) = _$TagRefCopyWithImpl;
@useResult
$Res call({
 String slug, String name
});




}
/// @nodoc
class _$TagRefCopyWithImpl<$Res>
    implements $TagRefCopyWith<$Res> {
  _$TagRefCopyWithImpl(this._self, this._then);

  final TagRef _self;
  final $Res Function(TagRef) _then;

/// Create a copy of TagRef
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? slug = null,Object? name = null,}) {
  return _then(_self.copyWith(
slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [TagRef].
extension TagRefPatterns on TagRef {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TagRef value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TagRef() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TagRef value)  $default,){
final _that = this;
switch (_that) {
case _TagRef():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TagRef value)?  $default,){
final _that = this;
switch (_that) {
case _TagRef() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String slug,  String name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TagRef() when $default != null:
return $default(_that.slug,_that.name);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String slug,  String name)  $default,) {final _that = this;
switch (_that) {
case _TagRef():
return $default(_that.slug,_that.name);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String slug,  String name)?  $default,) {final _that = this;
switch (_that) {
case _TagRef() when $default != null:
return $default(_that.slug,_that.name);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TagRef implements TagRef {
  const _TagRef({required this.slug, this.name = ''});
  factory _TagRef.fromJson(Map<String, dynamic> json) => _$TagRefFromJson(json);

@override final  String slug;
@override@JsonKey() final  String name;

/// Create a copy of TagRef
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TagRefCopyWith<_TagRef> get copyWith => __$TagRefCopyWithImpl<_TagRef>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TagRefToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TagRef&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,slug,name);

@override
String toString() {
  return 'TagRef(slug: $slug, name: $name)';
}


}

/// @nodoc
abstract mixin class _$TagRefCopyWith<$Res> implements $TagRefCopyWith<$Res> {
  factory _$TagRefCopyWith(_TagRef value, $Res Function(_TagRef) _then) = __$TagRefCopyWithImpl;
@override @useResult
$Res call({
 String slug, String name
});




}
/// @nodoc
class __$TagRefCopyWithImpl<$Res>
    implements _$TagRefCopyWith<$Res> {
  __$TagRefCopyWithImpl(this._self, this._then);

  final _TagRef _self;
  final $Res Function(_TagRef) _then;

/// Create a copy of TagRef
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? slug = null,Object? name = null,}) {
  return _then(_TagRef(
slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on

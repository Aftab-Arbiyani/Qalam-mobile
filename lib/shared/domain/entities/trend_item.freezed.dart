// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trend_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TrendingTag {

 String get slug; String get name; int get pieceCount;
/// Create a copy of TrendingTag
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrendingTagCopyWith<TrendingTag> get copyWith => _$TrendingTagCopyWithImpl<TrendingTag>(this as TrendingTag, _$identity);

  /// Serializes this TrendingTag to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrendingTag&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.name, name) || other.name == name)&&(identical(other.pieceCount, pieceCount) || other.pieceCount == pieceCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,slug,name,pieceCount);

@override
String toString() {
  return 'TrendingTag(slug: $slug, name: $name, pieceCount: $pieceCount)';
}


}

/// @nodoc
abstract mixin class $TrendingTagCopyWith<$Res>  {
  factory $TrendingTagCopyWith(TrendingTag value, $Res Function(TrendingTag) _then) = _$TrendingTagCopyWithImpl;
@useResult
$Res call({
 String slug, String name, int pieceCount
});




}
/// @nodoc
class _$TrendingTagCopyWithImpl<$Res>
    implements $TrendingTagCopyWith<$Res> {
  _$TrendingTagCopyWithImpl(this._self, this._then);

  final TrendingTag _self;
  final $Res Function(TrendingTag) _then;

/// Create a copy of TrendingTag
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? slug = null,Object? name = null,Object? pieceCount = null,}) {
  return _then(_self.copyWith(
slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,pieceCount: null == pieceCount ? _self.pieceCount : pieceCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [TrendingTag].
extension TrendingTagPatterns on TrendingTag {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrendingTag value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrendingTag() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrendingTag value)  $default,){
final _that = this;
switch (_that) {
case _TrendingTag():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrendingTag value)?  $default,){
final _that = this;
switch (_that) {
case _TrendingTag() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String slug,  String name,  int pieceCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrendingTag() when $default != null:
return $default(_that.slug,_that.name,_that.pieceCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String slug,  String name,  int pieceCount)  $default,) {final _that = this;
switch (_that) {
case _TrendingTag():
return $default(_that.slug,_that.name,_that.pieceCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String slug,  String name,  int pieceCount)?  $default,) {final _that = this;
switch (_that) {
case _TrendingTag() when $default != null:
return $default(_that.slug,_that.name,_that.pieceCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TrendingTag implements TrendingTag {
  const _TrendingTag({required this.slug, this.name = '', this.pieceCount = 0});
  factory _TrendingTag.fromJson(Map<String, dynamic> json) => _$TrendingTagFromJson(json);

@override final  String slug;
@override@JsonKey() final  String name;
@override@JsonKey() final  int pieceCount;

/// Create a copy of TrendingTag
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrendingTagCopyWith<_TrendingTag> get copyWith => __$TrendingTagCopyWithImpl<_TrendingTag>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TrendingTagToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrendingTag&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.name, name) || other.name == name)&&(identical(other.pieceCount, pieceCount) || other.pieceCount == pieceCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,slug,name,pieceCount);

@override
String toString() {
  return 'TrendingTag(slug: $slug, name: $name, pieceCount: $pieceCount)';
}


}

/// @nodoc
abstract mixin class _$TrendingTagCopyWith<$Res> implements $TrendingTagCopyWith<$Res> {
  factory _$TrendingTagCopyWith(_TrendingTag value, $Res Function(_TrendingTag) _then) = __$TrendingTagCopyWithImpl;
@override @useResult
$Res call({
 String slug, String name, int pieceCount
});




}
/// @nodoc
class __$TrendingTagCopyWithImpl<$Res>
    implements _$TrendingTagCopyWith<$Res> {
  __$TrendingTagCopyWithImpl(this._self, this._then);

  final _TrendingTag _self;
  final $Res Function(_TrendingTag) _then;

/// Create a copy of TrendingTag
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? slug = null,Object? name = null,Object? pieceCount = null,}) {
  return _then(_TrendingTag(
slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,pieceCount: null == pieceCount ? _self.pieceCount : pieceCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$TrendingGenre {

 String get slug; String get name; int get pieceCount;
/// Create a copy of TrendingGenre
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrendingGenreCopyWith<TrendingGenre> get copyWith => _$TrendingGenreCopyWithImpl<TrendingGenre>(this as TrendingGenre, _$identity);

  /// Serializes this TrendingGenre to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrendingGenre&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.name, name) || other.name == name)&&(identical(other.pieceCount, pieceCount) || other.pieceCount == pieceCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,slug,name,pieceCount);

@override
String toString() {
  return 'TrendingGenre(slug: $slug, name: $name, pieceCount: $pieceCount)';
}


}

/// @nodoc
abstract mixin class $TrendingGenreCopyWith<$Res>  {
  factory $TrendingGenreCopyWith(TrendingGenre value, $Res Function(TrendingGenre) _then) = _$TrendingGenreCopyWithImpl;
@useResult
$Res call({
 String slug, String name, int pieceCount
});




}
/// @nodoc
class _$TrendingGenreCopyWithImpl<$Res>
    implements $TrendingGenreCopyWith<$Res> {
  _$TrendingGenreCopyWithImpl(this._self, this._then);

  final TrendingGenre _self;
  final $Res Function(TrendingGenre) _then;

/// Create a copy of TrendingGenre
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? slug = null,Object? name = null,Object? pieceCount = null,}) {
  return _then(_self.copyWith(
slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,pieceCount: null == pieceCount ? _self.pieceCount : pieceCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [TrendingGenre].
extension TrendingGenrePatterns on TrendingGenre {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrendingGenre value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrendingGenre() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrendingGenre value)  $default,){
final _that = this;
switch (_that) {
case _TrendingGenre():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrendingGenre value)?  $default,){
final _that = this;
switch (_that) {
case _TrendingGenre() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String slug,  String name,  int pieceCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrendingGenre() when $default != null:
return $default(_that.slug,_that.name,_that.pieceCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String slug,  String name,  int pieceCount)  $default,) {final _that = this;
switch (_that) {
case _TrendingGenre():
return $default(_that.slug,_that.name,_that.pieceCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String slug,  String name,  int pieceCount)?  $default,) {final _that = this;
switch (_that) {
case _TrendingGenre() when $default != null:
return $default(_that.slug,_that.name,_that.pieceCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TrendingGenre implements TrendingGenre {
  const _TrendingGenre({required this.slug, this.name = '', this.pieceCount = 0});
  factory _TrendingGenre.fromJson(Map<String, dynamic> json) => _$TrendingGenreFromJson(json);

@override final  String slug;
@override@JsonKey() final  String name;
@override@JsonKey() final  int pieceCount;

/// Create a copy of TrendingGenre
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrendingGenreCopyWith<_TrendingGenre> get copyWith => __$TrendingGenreCopyWithImpl<_TrendingGenre>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TrendingGenreToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrendingGenre&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.name, name) || other.name == name)&&(identical(other.pieceCount, pieceCount) || other.pieceCount == pieceCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,slug,name,pieceCount);

@override
String toString() {
  return 'TrendingGenre(slug: $slug, name: $name, pieceCount: $pieceCount)';
}


}

/// @nodoc
abstract mixin class _$TrendingGenreCopyWith<$Res> implements $TrendingGenreCopyWith<$Res> {
  factory _$TrendingGenreCopyWith(_TrendingGenre value, $Res Function(_TrendingGenre) _then) = __$TrendingGenreCopyWithImpl;
@override @useResult
$Res call({
 String slug, String name, int pieceCount
});




}
/// @nodoc
class __$TrendingGenreCopyWithImpl<$Res>
    implements _$TrendingGenreCopyWith<$Res> {
  __$TrendingGenreCopyWithImpl(this._self, this._then);

  final _TrendingGenre _self;
  final $Res Function(_TrendingGenre) _then;

/// Create a copy of TrendingGenre
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? slug = null,Object? name = null,Object? pieceCount = null,}) {
  return _then(_TrendingGenre(
slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,pieceCount: null == pieceCount ? _self.pieceCount : pieceCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$TrendingLanguage {

 String get code; String get nativeName; TextDirectionKind get direction; int get pieceCount;
/// Create a copy of TrendingLanguage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrendingLanguageCopyWith<TrendingLanguage> get copyWith => _$TrendingLanguageCopyWithImpl<TrendingLanguage>(this as TrendingLanguage, _$identity);

  /// Serializes this TrendingLanguage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrendingLanguage&&(identical(other.code, code) || other.code == code)&&(identical(other.nativeName, nativeName) || other.nativeName == nativeName)&&(identical(other.direction, direction) || other.direction == direction)&&(identical(other.pieceCount, pieceCount) || other.pieceCount == pieceCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code,nativeName,direction,pieceCount);

@override
String toString() {
  return 'TrendingLanguage(code: $code, nativeName: $nativeName, direction: $direction, pieceCount: $pieceCount)';
}


}

/// @nodoc
abstract mixin class $TrendingLanguageCopyWith<$Res>  {
  factory $TrendingLanguageCopyWith(TrendingLanguage value, $Res Function(TrendingLanguage) _then) = _$TrendingLanguageCopyWithImpl;
@useResult
$Res call({
 String code, String nativeName, TextDirectionKind direction, int pieceCount
});




}
/// @nodoc
class _$TrendingLanguageCopyWithImpl<$Res>
    implements $TrendingLanguageCopyWith<$Res> {
  _$TrendingLanguageCopyWithImpl(this._self, this._then);

  final TrendingLanguage _self;
  final $Res Function(TrendingLanguage) _then;

/// Create a copy of TrendingLanguage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? code = null,Object? nativeName = null,Object? direction = null,Object? pieceCount = null,}) {
  return _then(_self.copyWith(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,nativeName: null == nativeName ? _self.nativeName : nativeName // ignore: cast_nullable_to_non_nullable
as String,direction: null == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as TextDirectionKind,pieceCount: null == pieceCount ? _self.pieceCount : pieceCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [TrendingLanguage].
extension TrendingLanguagePatterns on TrendingLanguage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrendingLanguage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrendingLanguage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrendingLanguage value)  $default,){
final _that = this;
switch (_that) {
case _TrendingLanguage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrendingLanguage value)?  $default,){
final _that = this;
switch (_that) {
case _TrendingLanguage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String code,  String nativeName,  TextDirectionKind direction,  int pieceCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrendingLanguage() when $default != null:
return $default(_that.code,_that.nativeName,_that.direction,_that.pieceCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String code,  String nativeName,  TextDirectionKind direction,  int pieceCount)  $default,) {final _that = this;
switch (_that) {
case _TrendingLanguage():
return $default(_that.code,_that.nativeName,_that.direction,_that.pieceCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String code,  String nativeName,  TextDirectionKind direction,  int pieceCount)?  $default,) {final _that = this;
switch (_that) {
case _TrendingLanguage() when $default != null:
return $default(_that.code,_that.nativeName,_that.direction,_that.pieceCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TrendingLanguage implements TrendingLanguage {
  const _TrendingLanguage({required this.code, this.nativeName = '', this.direction = TextDirectionKind.ltr, this.pieceCount = 0});
  factory _TrendingLanguage.fromJson(Map<String, dynamic> json) => _$TrendingLanguageFromJson(json);

@override final  String code;
@override@JsonKey() final  String nativeName;
@override@JsonKey() final  TextDirectionKind direction;
@override@JsonKey() final  int pieceCount;

/// Create a copy of TrendingLanguage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrendingLanguageCopyWith<_TrendingLanguage> get copyWith => __$TrendingLanguageCopyWithImpl<_TrendingLanguage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TrendingLanguageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrendingLanguage&&(identical(other.code, code) || other.code == code)&&(identical(other.nativeName, nativeName) || other.nativeName == nativeName)&&(identical(other.direction, direction) || other.direction == direction)&&(identical(other.pieceCount, pieceCount) || other.pieceCount == pieceCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,code,nativeName,direction,pieceCount);

@override
String toString() {
  return 'TrendingLanguage(code: $code, nativeName: $nativeName, direction: $direction, pieceCount: $pieceCount)';
}


}

/// @nodoc
abstract mixin class _$TrendingLanguageCopyWith<$Res> implements $TrendingLanguageCopyWith<$Res> {
  factory _$TrendingLanguageCopyWith(_TrendingLanguage value, $Res Function(_TrendingLanguage) _then) = __$TrendingLanguageCopyWithImpl;
@override @useResult
$Res call({
 String code, String nativeName, TextDirectionKind direction, int pieceCount
});




}
/// @nodoc
class __$TrendingLanguageCopyWithImpl<$Res>
    implements _$TrendingLanguageCopyWith<$Res> {
  __$TrendingLanguageCopyWithImpl(this._self, this._then);

  final _TrendingLanguage _self;
  final $Res Function(_TrendingLanguage) _then;

/// Create a copy of TrendingLanguage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? code = null,Object? nativeName = null,Object? direction = null,Object? pieceCount = null,}) {
  return _then(_TrendingLanguage(
code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,nativeName: null == nativeName ? _self.nativeName : nativeName // ignore: cast_nullable_to_non_nullable
as String,direction: null == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as TextDirectionKind,pieceCount: null == pieceCount ? _self.pieceCount : pieceCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on

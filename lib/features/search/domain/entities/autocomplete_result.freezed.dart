// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'autocomplete_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WriterSuggestion {

 String get username; String? get penName; String? get avatarKey;
/// Create a copy of WriterSuggestion
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WriterSuggestionCopyWith<WriterSuggestion> get copyWith => _$WriterSuggestionCopyWithImpl<WriterSuggestion>(this as WriterSuggestion, _$identity);

  /// Serializes this WriterSuggestion to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WriterSuggestion&&(identical(other.username, username) || other.username == username)&&(identical(other.penName, penName) || other.penName == penName)&&(identical(other.avatarKey, avatarKey) || other.avatarKey == avatarKey));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,username,penName,avatarKey);

@override
String toString() {
  return 'WriterSuggestion(username: $username, penName: $penName, avatarKey: $avatarKey)';
}


}

/// @nodoc
abstract mixin class $WriterSuggestionCopyWith<$Res>  {
  factory $WriterSuggestionCopyWith(WriterSuggestion value, $Res Function(WriterSuggestion) _then) = _$WriterSuggestionCopyWithImpl;
@useResult
$Res call({
 String username, String? penName, String? avatarKey
});




}
/// @nodoc
class _$WriterSuggestionCopyWithImpl<$Res>
    implements $WriterSuggestionCopyWith<$Res> {
  _$WriterSuggestionCopyWithImpl(this._self, this._then);

  final WriterSuggestion _self;
  final $Res Function(WriterSuggestion) _then;

/// Create a copy of WriterSuggestion
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? username = null,Object? penName = freezed,Object? avatarKey = freezed,}) {
  return _then(_self.copyWith(
username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,penName: freezed == penName ? _self.penName : penName // ignore: cast_nullable_to_non_nullable
as String?,avatarKey: freezed == avatarKey ? _self.avatarKey : avatarKey // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [WriterSuggestion].
extension WriterSuggestionPatterns on WriterSuggestion {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WriterSuggestion value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WriterSuggestion() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WriterSuggestion value)  $default,){
final _that = this;
switch (_that) {
case _WriterSuggestion():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WriterSuggestion value)?  $default,){
final _that = this;
switch (_that) {
case _WriterSuggestion() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String username,  String? penName,  String? avatarKey)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WriterSuggestion() when $default != null:
return $default(_that.username,_that.penName,_that.avatarKey);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String username,  String? penName,  String? avatarKey)  $default,) {final _that = this;
switch (_that) {
case _WriterSuggestion():
return $default(_that.username,_that.penName,_that.avatarKey);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String username,  String? penName,  String? avatarKey)?  $default,) {final _that = this;
switch (_that) {
case _WriterSuggestion() when $default != null:
return $default(_that.username,_that.penName,_that.avatarKey);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WriterSuggestion extends WriterSuggestion {
  const _WriterSuggestion({required this.username, this.penName, this.avatarKey}): super._();
  factory _WriterSuggestion.fromJson(Map<String, dynamic> json) => _$WriterSuggestionFromJson(json);

@override final  String username;
@override final  String? penName;
@override final  String? avatarKey;

/// Create a copy of WriterSuggestion
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WriterSuggestionCopyWith<_WriterSuggestion> get copyWith => __$WriterSuggestionCopyWithImpl<_WriterSuggestion>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WriterSuggestionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WriterSuggestion&&(identical(other.username, username) || other.username == username)&&(identical(other.penName, penName) || other.penName == penName)&&(identical(other.avatarKey, avatarKey) || other.avatarKey == avatarKey));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,username,penName,avatarKey);

@override
String toString() {
  return 'WriterSuggestion(username: $username, penName: $penName, avatarKey: $avatarKey)';
}


}

/// @nodoc
abstract mixin class _$WriterSuggestionCopyWith<$Res> implements $WriterSuggestionCopyWith<$Res> {
  factory _$WriterSuggestionCopyWith(_WriterSuggestion value, $Res Function(_WriterSuggestion) _then) = __$WriterSuggestionCopyWithImpl;
@override @useResult
$Res call({
 String username, String? penName, String? avatarKey
});




}
/// @nodoc
class __$WriterSuggestionCopyWithImpl<$Res>
    implements _$WriterSuggestionCopyWith<$Res> {
  __$WriterSuggestionCopyWithImpl(this._self, this._then);

  final _WriterSuggestion _self;
  final $Res Function(_WriterSuggestion) _then;

/// Create a copy of WriterSuggestion
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? username = null,Object? penName = freezed,Object? avatarKey = freezed,}) {
  return _then(_WriterSuggestion(
username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,penName: freezed == penName ? _self.penName : penName // ignore: cast_nullable_to_non_nullable
as String?,avatarKey: freezed == avatarKey ? _self.avatarKey : avatarKey // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$TagSuggestion {

 String get slug; String get name;
/// Create a copy of TagSuggestion
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TagSuggestionCopyWith<TagSuggestion> get copyWith => _$TagSuggestionCopyWithImpl<TagSuggestion>(this as TagSuggestion, _$identity);

  /// Serializes this TagSuggestion to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TagSuggestion&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,slug,name);

@override
String toString() {
  return 'TagSuggestion(slug: $slug, name: $name)';
}


}

/// @nodoc
abstract mixin class $TagSuggestionCopyWith<$Res>  {
  factory $TagSuggestionCopyWith(TagSuggestion value, $Res Function(TagSuggestion) _then) = _$TagSuggestionCopyWithImpl;
@useResult
$Res call({
 String slug, String name
});




}
/// @nodoc
class _$TagSuggestionCopyWithImpl<$Res>
    implements $TagSuggestionCopyWith<$Res> {
  _$TagSuggestionCopyWithImpl(this._self, this._then);

  final TagSuggestion _self;
  final $Res Function(TagSuggestion) _then;

/// Create a copy of TagSuggestion
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? slug = null,Object? name = null,}) {
  return _then(_self.copyWith(
slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [TagSuggestion].
extension TagSuggestionPatterns on TagSuggestion {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TagSuggestion value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TagSuggestion() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TagSuggestion value)  $default,){
final _that = this;
switch (_that) {
case _TagSuggestion():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TagSuggestion value)?  $default,){
final _that = this;
switch (_that) {
case _TagSuggestion() when $default != null:
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
case _TagSuggestion() when $default != null:
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
case _TagSuggestion():
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
case _TagSuggestion() when $default != null:
return $default(_that.slug,_that.name);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TagSuggestion implements TagSuggestion {
  const _TagSuggestion({required this.slug, this.name = ''});
  factory _TagSuggestion.fromJson(Map<String, dynamic> json) => _$TagSuggestionFromJson(json);

@override final  String slug;
@override@JsonKey() final  String name;

/// Create a copy of TagSuggestion
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TagSuggestionCopyWith<_TagSuggestion> get copyWith => __$TagSuggestionCopyWithImpl<_TagSuggestion>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TagSuggestionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TagSuggestion&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,slug,name);

@override
String toString() {
  return 'TagSuggestion(slug: $slug, name: $name)';
}


}

/// @nodoc
abstract mixin class _$TagSuggestionCopyWith<$Res> implements $TagSuggestionCopyWith<$Res> {
  factory _$TagSuggestionCopyWith(_TagSuggestion value, $Res Function(_TagSuggestion) _then) = __$TagSuggestionCopyWithImpl;
@override @useResult
$Res call({
 String slug, String name
});




}
/// @nodoc
class __$TagSuggestionCopyWithImpl<$Res>
    implements _$TagSuggestionCopyWith<$Res> {
  __$TagSuggestionCopyWithImpl(this._self, this._then);

  final _TagSuggestion _self;
  final $Res Function(_TagSuggestion) _then;

/// Create a copy of TagSuggestion
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? slug = null,Object? name = null,}) {
  return _then(_TagSuggestion(
slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$GenreSuggestion {

 String get slug; String get name;
/// Create a copy of GenreSuggestion
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GenreSuggestionCopyWith<GenreSuggestion> get copyWith => _$GenreSuggestionCopyWithImpl<GenreSuggestion>(this as GenreSuggestion, _$identity);

  /// Serializes this GenreSuggestion to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GenreSuggestion&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,slug,name);

@override
String toString() {
  return 'GenreSuggestion(slug: $slug, name: $name)';
}


}

/// @nodoc
abstract mixin class $GenreSuggestionCopyWith<$Res>  {
  factory $GenreSuggestionCopyWith(GenreSuggestion value, $Res Function(GenreSuggestion) _then) = _$GenreSuggestionCopyWithImpl;
@useResult
$Res call({
 String slug, String name
});




}
/// @nodoc
class _$GenreSuggestionCopyWithImpl<$Res>
    implements $GenreSuggestionCopyWith<$Res> {
  _$GenreSuggestionCopyWithImpl(this._self, this._then);

  final GenreSuggestion _self;
  final $Res Function(GenreSuggestion) _then;

/// Create a copy of GenreSuggestion
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? slug = null,Object? name = null,}) {
  return _then(_self.copyWith(
slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [GenreSuggestion].
extension GenreSuggestionPatterns on GenreSuggestion {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GenreSuggestion value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GenreSuggestion() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GenreSuggestion value)  $default,){
final _that = this;
switch (_that) {
case _GenreSuggestion():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GenreSuggestion value)?  $default,){
final _that = this;
switch (_that) {
case _GenreSuggestion() when $default != null:
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
case _GenreSuggestion() when $default != null:
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
case _GenreSuggestion():
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
case _GenreSuggestion() when $default != null:
return $default(_that.slug,_that.name);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GenreSuggestion implements GenreSuggestion {
  const _GenreSuggestion({required this.slug, this.name = ''});
  factory _GenreSuggestion.fromJson(Map<String, dynamic> json) => _$GenreSuggestionFromJson(json);

@override final  String slug;
@override@JsonKey() final  String name;

/// Create a copy of GenreSuggestion
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GenreSuggestionCopyWith<_GenreSuggestion> get copyWith => __$GenreSuggestionCopyWithImpl<_GenreSuggestion>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GenreSuggestionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GenreSuggestion&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,slug,name);

@override
String toString() {
  return 'GenreSuggestion(slug: $slug, name: $name)';
}


}

/// @nodoc
abstract mixin class _$GenreSuggestionCopyWith<$Res> implements $GenreSuggestionCopyWith<$Res> {
  factory _$GenreSuggestionCopyWith(_GenreSuggestion value, $Res Function(_GenreSuggestion) _then) = __$GenreSuggestionCopyWithImpl;
@override @useResult
$Res call({
 String slug, String name
});




}
/// @nodoc
class __$GenreSuggestionCopyWithImpl<$Res>
    implements _$GenreSuggestionCopyWith<$Res> {
  __$GenreSuggestionCopyWithImpl(this._self, this._then);

  final _GenreSuggestion _self;
  final $Res Function(_GenreSuggestion) _then;

/// Create a copy of GenreSuggestion
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? slug = null,Object? name = null,}) {
  return _then(_GenreSuggestion(
slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$PieceSuggestion {

 String? get slug; String get title;
/// Create a copy of PieceSuggestion
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PieceSuggestionCopyWith<PieceSuggestion> get copyWith => _$PieceSuggestionCopyWithImpl<PieceSuggestion>(this as PieceSuggestion, _$identity);

  /// Serializes this PieceSuggestion to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PieceSuggestion&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.title, title) || other.title == title));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,slug,title);

@override
String toString() {
  return 'PieceSuggestion(slug: $slug, title: $title)';
}


}

/// @nodoc
abstract mixin class $PieceSuggestionCopyWith<$Res>  {
  factory $PieceSuggestionCopyWith(PieceSuggestion value, $Res Function(PieceSuggestion) _then) = _$PieceSuggestionCopyWithImpl;
@useResult
$Res call({
 String? slug, String title
});




}
/// @nodoc
class _$PieceSuggestionCopyWithImpl<$Res>
    implements $PieceSuggestionCopyWith<$Res> {
  _$PieceSuggestionCopyWithImpl(this._self, this._then);

  final PieceSuggestion _self;
  final $Res Function(PieceSuggestion) _then;

/// Create a copy of PieceSuggestion
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? slug = freezed,Object? title = null,}) {
  return _then(_self.copyWith(
slug: freezed == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [PieceSuggestion].
extension PieceSuggestionPatterns on PieceSuggestion {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PieceSuggestion value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PieceSuggestion() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PieceSuggestion value)  $default,){
final _that = this;
switch (_that) {
case _PieceSuggestion():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PieceSuggestion value)?  $default,){
final _that = this;
switch (_that) {
case _PieceSuggestion() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? slug,  String title)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PieceSuggestion() when $default != null:
return $default(_that.slug,_that.title);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? slug,  String title)  $default,) {final _that = this;
switch (_that) {
case _PieceSuggestion():
return $default(_that.slug,_that.title);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? slug,  String title)?  $default,) {final _that = this;
switch (_that) {
case _PieceSuggestion() when $default != null:
return $default(_that.slug,_that.title);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PieceSuggestion implements PieceSuggestion {
  const _PieceSuggestion({this.slug, this.title = ''});
  factory _PieceSuggestion.fromJson(Map<String, dynamic> json) => _$PieceSuggestionFromJson(json);

@override final  String? slug;
@override@JsonKey() final  String title;

/// Create a copy of PieceSuggestion
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PieceSuggestionCopyWith<_PieceSuggestion> get copyWith => __$PieceSuggestionCopyWithImpl<_PieceSuggestion>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PieceSuggestionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PieceSuggestion&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.title, title) || other.title == title));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,slug,title);

@override
String toString() {
  return 'PieceSuggestion(slug: $slug, title: $title)';
}


}

/// @nodoc
abstract mixin class _$PieceSuggestionCopyWith<$Res> implements $PieceSuggestionCopyWith<$Res> {
  factory _$PieceSuggestionCopyWith(_PieceSuggestion value, $Res Function(_PieceSuggestion) _then) = __$PieceSuggestionCopyWithImpl;
@override @useResult
$Res call({
 String? slug, String title
});




}
/// @nodoc
class __$PieceSuggestionCopyWithImpl<$Res>
    implements _$PieceSuggestionCopyWith<$Res> {
  __$PieceSuggestionCopyWithImpl(this._self, this._then);

  final _PieceSuggestion _self;
  final $Res Function(_PieceSuggestion) _then;

/// Create a copy of PieceSuggestion
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? slug = freezed,Object? title = null,}) {
  return _then(_PieceSuggestion(
slug: freezed == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$AutocompleteResult {

 List<WriterSuggestion> get writers; List<TagSuggestion> get tags; List<GenreSuggestion> get genres; List<PieceSuggestion> get pieces;
/// Create a copy of AutocompleteResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AutocompleteResultCopyWith<AutocompleteResult> get copyWith => _$AutocompleteResultCopyWithImpl<AutocompleteResult>(this as AutocompleteResult, _$identity);

  /// Serializes this AutocompleteResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AutocompleteResult&&const DeepCollectionEquality().equals(other.writers, writers)&&const DeepCollectionEquality().equals(other.tags, tags)&&const DeepCollectionEquality().equals(other.genres, genres)&&const DeepCollectionEquality().equals(other.pieces, pieces));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(writers),const DeepCollectionEquality().hash(tags),const DeepCollectionEquality().hash(genres),const DeepCollectionEquality().hash(pieces));

@override
String toString() {
  return 'AutocompleteResult(writers: $writers, tags: $tags, genres: $genres, pieces: $pieces)';
}


}

/// @nodoc
abstract mixin class $AutocompleteResultCopyWith<$Res>  {
  factory $AutocompleteResultCopyWith(AutocompleteResult value, $Res Function(AutocompleteResult) _then) = _$AutocompleteResultCopyWithImpl;
@useResult
$Res call({
 List<WriterSuggestion> writers, List<TagSuggestion> tags, List<GenreSuggestion> genres, List<PieceSuggestion> pieces
});




}
/// @nodoc
class _$AutocompleteResultCopyWithImpl<$Res>
    implements $AutocompleteResultCopyWith<$Res> {
  _$AutocompleteResultCopyWithImpl(this._self, this._then);

  final AutocompleteResult _self;
  final $Res Function(AutocompleteResult) _then;

/// Create a copy of AutocompleteResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? writers = null,Object? tags = null,Object? genres = null,Object? pieces = null,}) {
  return _then(_self.copyWith(
writers: null == writers ? _self.writers : writers // ignore: cast_nullable_to_non_nullable
as List<WriterSuggestion>,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<TagSuggestion>,genres: null == genres ? _self.genres : genres // ignore: cast_nullable_to_non_nullable
as List<GenreSuggestion>,pieces: null == pieces ? _self.pieces : pieces // ignore: cast_nullable_to_non_nullable
as List<PieceSuggestion>,
  ));
}

}


/// Adds pattern-matching-related methods to [AutocompleteResult].
extension AutocompleteResultPatterns on AutocompleteResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AutocompleteResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AutocompleteResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AutocompleteResult value)  $default,){
final _that = this;
switch (_that) {
case _AutocompleteResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AutocompleteResult value)?  $default,){
final _that = this;
switch (_that) {
case _AutocompleteResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<WriterSuggestion> writers,  List<TagSuggestion> tags,  List<GenreSuggestion> genres,  List<PieceSuggestion> pieces)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AutocompleteResult() when $default != null:
return $default(_that.writers,_that.tags,_that.genres,_that.pieces);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<WriterSuggestion> writers,  List<TagSuggestion> tags,  List<GenreSuggestion> genres,  List<PieceSuggestion> pieces)  $default,) {final _that = this;
switch (_that) {
case _AutocompleteResult():
return $default(_that.writers,_that.tags,_that.genres,_that.pieces);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<WriterSuggestion> writers,  List<TagSuggestion> tags,  List<GenreSuggestion> genres,  List<PieceSuggestion> pieces)?  $default,) {final _that = this;
switch (_that) {
case _AutocompleteResult() when $default != null:
return $default(_that.writers,_that.tags,_that.genres,_that.pieces);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AutocompleteResult extends AutocompleteResult {
  const _AutocompleteResult({final  List<WriterSuggestion> writers = const <WriterSuggestion>[], final  List<TagSuggestion> tags = const <TagSuggestion>[], final  List<GenreSuggestion> genres = const <GenreSuggestion>[], final  List<PieceSuggestion> pieces = const <PieceSuggestion>[]}): _writers = writers,_tags = tags,_genres = genres,_pieces = pieces,super._();
  factory _AutocompleteResult.fromJson(Map<String, dynamic> json) => _$AutocompleteResultFromJson(json);

 final  List<WriterSuggestion> _writers;
@override@JsonKey() List<WriterSuggestion> get writers {
  if (_writers is EqualUnmodifiableListView) return _writers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_writers);
}

 final  List<TagSuggestion> _tags;
@override@JsonKey() List<TagSuggestion> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

 final  List<GenreSuggestion> _genres;
@override@JsonKey() List<GenreSuggestion> get genres {
  if (_genres is EqualUnmodifiableListView) return _genres;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_genres);
}

 final  List<PieceSuggestion> _pieces;
@override@JsonKey() List<PieceSuggestion> get pieces {
  if (_pieces is EqualUnmodifiableListView) return _pieces;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_pieces);
}


/// Create a copy of AutocompleteResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AutocompleteResultCopyWith<_AutocompleteResult> get copyWith => __$AutocompleteResultCopyWithImpl<_AutocompleteResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AutocompleteResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AutocompleteResult&&const DeepCollectionEquality().equals(other._writers, _writers)&&const DeepCollectionEquality().equals(other._tags, _tags)&&const DeepCollectionEquality().equals(other._genres, _genres)&&const DeepCollectionEquality().equals(other._pieces, _pieces));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_writers),const DeepCollectionEquality().hash(_tags),const DeepCollectionEquality().hash(_genres),const DeepCollectionEquality().hash(_pieces));

@override
String toString() {
  return 'AutocompleteResult(writers: $writers, tags: $tags, genres: $genres, pieces: $pieces)';
}


}

/// @nodoc
abstract mixin class _$AutocompleteResultCopyWith<$Res> implements $AutocompleteResultCopyWith<$Res> {
  factory _$AutocompleteResultCopyWith(_AutocompleteResult value, $Res Function(_AutocompleteResult) _then) = __$AutocompleteResultCopyWithImpl;
@override @useResult
$Res call({
 List<WriterSuggestion> writers, List<TagSuggestion> tags, List<GenreSuggestion> genres, List<PieceSuggestion> pieces
});




}
/// @nodoc
class __$AutocompleteResultCopyWithImpl<$Res>
    implements _$AutocompleteResultCopyWith<$Res> {
  __$AutocompleteResultCopyWithImpl(this._self, this._then);

  final _AutocompleteResult _self;
  final $Res Function(_AutocompleteResult) _then;

/// Create a copy of AutocompleteResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? writers = null,Object? tags = null,Object? genres = null,Object? pieces = null,}) {
  return _then(_AutocompleteResult(
writers: null == writers ? _self._writers : writers // ignore: cast_nullable_to_non_nullable
as List<WriterSuggestion>,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<TagSuggestion>,genres: null == genres ? _self._genres : genres // ignore: cast_nullable_to_non_nullable
as List<GenreSuggestion>,pieces: null == pieces ? _self._pieces : pieces // ignore: cast_nullable_to_non_nullable
as List<PieceSuggestion>,
  ));
}


}

// dart format on

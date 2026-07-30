// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'collection.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Collection {

 String get id; String get title; String get slug; String? get description; String? get coverImageKey; Visibility get visibility; bool get isDefault; int get piecesCount; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of Collection
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CollectionCopyWith<Collection> get copyWith => _$CollectionCopyWithImpl<Collection>(this as Collection, _$identity);

  /// Serializes this Collection to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Collection&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.description, description) || other.description == description)&&(identical(other.coverImageKey, coverImageKey) || other.coverImageKey == coverImageKey)&&(identical(other.visibility, visibility) || other.visibility == visibility)&&(identical(other.isDefault, isDefault) || other.isDefault == isDefault)&&(identical(other.piecesCount, piecesCount) || other.piecesCount == piecesCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,slug,description,coverImageKey,visibility,isDefault,piecesCount,createdAt,updatedAt);

@override
String toString() {
  return 'Collection(id: $id, title: $title, slug: $slug, description: $description, coverImageKey: $coverImageKey, visibility: $visibility, isDefault: $isDefault, piecesCount: $piecesCount, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $CollectionCopyWith<$Res>  {
  factory $CollectionCopyWith(Collection value, $Res Function(Collection) _then) = _$CollectionCopyWithImpl;
@useResult
$Res call({
 String id, String title, String slug, String? description, String? coverImageKey, Visibility visibility, bool isDefault, int piecesCount, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$CollectionCopyWithImpl<$Res>
    implements $CollectionCopyWith<$Res> {
  _$CollectionCopyWithImpl(this._self, this._then);

  final Collection _self;
  final $Res Function(Collection) _then;

/// Create a copy of Collection
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? slug = null,Object? description = freezed,Object? coverImageKey = freezed,Object? visibility = null,Object? isDefault = null,Object? piecesCount = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,coverImageKey: freezed == coverImageKey ? _self.coverImageKey : coverImageKey // ignore: cast_nullable_to_non_nullable
as String?,visibility: null == visibility ? _self.visibility : visibility // ignore: cast_nullable_to_non_nullable
as Visibility,isDefault: null == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool,piecesCount: null == piecesCount ? _self.piecesCount : piecesCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Collection].
extension CollectionPatterns on Collection {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Collection value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Collection() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Collection value)  $default,){
final _that = this;
switch (_that) {
case _Collection():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Collection value)?  $default,){
final _that = this;
switch (_that) {
case _Collection() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  String slug,  String? description,  String? coverImageKey,  Visibility visibility,  bool isDefault,  int piecesCount,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Collection() when $default != null:
return $default(_that.id,_that.title,_that.slug,_that.description,_that.coverImageKey,_that.visibility,_that.isDefault,_that.piecesCount,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  String slug,  String? description,  String? coverImageKey,  Visibility visibility,  bool isDefault,  int piecesCount,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Collection():
return $default(_that.id,_that.title,_that.slug,_that.description,_that.coverImageKey,_that.visibility,_that.isDefault,_that.piecesCount,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  String slug,  String? description,  String? coverImageKey,  Visibility visibility,  bool isDefault,  int piecesCount,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Collection() when $default != null:
return $default(_that.id,_that.title,_that.slug,_that.description,_that.coverImageKey,_that.visibility,_that.isDefault,_that.piecesCount,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Collection extends Collection {
  const _Collection({required this.id, this.title = '', this.slug = '', this.description, this.coverImageKey, this.visibility = Visibility.private, this.isDefault = false, this.piecesCount = 0, this.createdAt, this.updatedAt}): super._();
  factory _Collection.fromJson(Map<String, dynamic> json) => _$CollectionFromJson(json);

@override final  String id;
@override@JsonKey() final  String title;
@override@JsonKey() final  String slug;
@override final  String? description;
@override final  String? coverImageKey;
@override@JsonKey() final  Visibility visibility;
@override@JsonKey() final  bool isDefault;
@override@JsonKey() final  int piecesCount;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of Collection
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CollectionCopyWith<_Collection> get copyWith => __$CollectionCopyWithImpl<_Collection>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CollectionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Collection&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.description, description) || other.description == description)&&(identical(other.coverImageKey, coverImageKey) || other.coverImageKey == coverImageKey)&&(identical(other.visibility, visibility) || other.visibility == visibility)&&(identical(other.isDefault, isDefault) || other.isDefault == isDefault)&&(identical(other.piecesCount, piecesCount) || other.piecesCount == piecesCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,slug,description,coverImageKey,visibility,isDefault,piecesCount,createdAt,updatedAt);

@override
String toString() {
  return 'Collection(id: $id, title: $title, slug: $slug, description: $description, coverImageKey: $coverImageKey, visibility: $visibility, isDefault: $isDefault, piecesCount: $piecesCount, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$CollectionCopyWith<$Res> implements $CollectionCopyWith<$Res> {
  factory _$CollectionCopyWith(_Collection value, $Res Function(_Collection) _then) = __$CollectionCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, String slug, String? description, String? coverImageKey, Visibility visibility, bool isDefault, int piecesCount, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$CollectionCopyWithImpl<$Res>
    implements _$CollectionCopyWith<$Res> {
  __$CollectionCopyWithImpl(this._self, this._then);

  final _Collection _self;
  final $Res Function(_Collection) _then;

/// Create a copy of Collection
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? slug = null,Object? description = freezed,Object? coverImageKey = freezed,Object? visibility = null,Object? isDefault = null,Object? piecesCount = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_Collection(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,slug: null == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,coverImageKey: freezed == coverImageKey ? _self.coverImageKey : coverImageKey // ignore: cast_nullable_to_non_nullable
as String?,visibility: null == visibility ? _self.visibility : visibility // ignore: cast_nullable_to_non_nullable
as Visibility,isDefault: null == isDefault ? _self.isDefault : isDefault // ignore: cast_nullable_to_non_nullable
as bool,piecesCount: null == piecesCount ? _self.piecesCount : piecesCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$CollectionPieceItem {

 String get pieceId; String? get slug; String get title; int get position; String? get note; DateTime? get addedAt;
/// Create a copy of CollectionPieceItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CollectionPieceItemCopyWith<CollectionPieceItem> get copyWith => _$CollectionPieceItemCopyWithImpl<CollectionPieceItem>(this as CollectionPieceItem, _$identity);

  /// Serializes this CollectionPieceItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CollectionPieceItem&&(identical(other.pieceId, pieceId) || other.pieceId == pieceId)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.title, title) || other.title == title)&&(identical(other.position, position) || other.position == position)&&(identical(other.note, note) || other.note == note)&&(identical(other.addedAt, addedAt) || other.addedAt == addedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,pieceId,slug,title,position,note,addedAt);

@override
String toString() {
  return 'CollectionPieceItem(pieceId: $pieceId, slug: $slug, title: $title, position: $position, note: $note, addedAt: $addedAt)';
}


}

/// @nodoc
abstract mixin class $CollectionPieceItemCopyWith<$Res>  {
  factory $CollectionPieceItemCopyWith(CollectionPieceItem value, $Res Function(CollectionPieceItem) _then) = _$CollectionPieceItemCopyWithImpl;
@useResult
$Res call({
 String pieceId, String? slug, String title, int position, String? note, DateTime? addedAt
});




}
/// @nodoc
class _$CollectionPieceItemCopyWithImpl<$Res>
    implements $CollectionPieceItemCopyWith<$Res> {
  _$CollectionPieceItemCopyWithImpl(this._self, this._then);

  final CollectionPieceItem _self;
  final $Res Function(CollectionPieceItem) _then;

/// Create a copy of CollectionPieceItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? pieceId = null,Object? slug = freezed,Object? title = null,Object? position = null,Object? note = freezed,Object? addedAt = freezed,}) {
  return _then(_self.copyWith(
pieceId: null == pieceId ? _self.pieceId : pieceId // ignore: cast_nullable_to_non_nullable
as String,slug: freezed == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,addedAt: freezed == addedAt ? _self.addedAt : addedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [CollectionPieceItem].
extension CollectionPieceItemPatterns on CollectionPieceItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CollectionPieceItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CollectionPieceItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CollectionPieceItem value)  $default,){
final _that = this;
switch (_that) {
case _CollectionPieceItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CollectionPieceItem value)?  $default,){
final _that = this;
switch (_that) {
case _CollectionPieceItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String pieceId,  String? slug,  String title,  int position,  String? note,  DateTime? addedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CollectionPieceItem() when $default != null:
return $default(_that.pieceId,_that.slug,_that.title,_that.position,_that.note,_that.addedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String pieceId,  String? slug,  String title,  int position,  String? note,  DateTime? addedAt)  $default,) {final _that = this;
switch (_that) {
case _CollectionPieceItem():
return $default(_that.pieceId,_that.slug,_that.title,_that.position,_that.note,_that.addedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String pieceId,  String? slug,  String title,  int position,  String? note,  DateTime? addedAt)?  $default,) {final _that = this;
switch (_that) {
case _CollectionPieceItem() when $default != null:
return $default(_that.pieceId,_that.slug,_that.title,_that.position,_that.note,_that.addedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CollectionPieceItem implements CollectionPieceItem {
  const _CollectionPieceItem({required this.pieceId, this.slug, this.title = '', this.position = 0, this.note, this.addedAt});
  factory _CollectionPieceItem.fromJson(Map<String, dynamic> json) => _$CollectionPieceItemFromJson(json);

@override final  String pieceId;
@override final  String? slug;
@override@JsonKey() final  String title;
@override@JsonKey() final  int position;
@override final  String? note;
@override final  DateTime? addedAt;

/// Create a copy of CollectionPieceItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CollectionPieceItemCopyWith<_CollectionPieceItem> get copyWith => __$CollectionPieceItemCopyWithImpl<_CollectionPieceItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CollectionPieceItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CollectionPieceItem&&(identical(other.pieceId, pieceId) || other.pieceId == pieceId)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.title, title) || other.title == title)&&(identical(other.position, position) || other.position == position)&&(identical(other.note, note) || other.note == note)&&(identical(other.addedAt, addedAt) || other.addedAt == addedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,pieceId,slug,title,position,note,addedAt);

@override
String toString() {
  return 'CollectionPieceItem(pieceId: $pieceId, slug: $slug, title: $title, position: $position, note: $note, addedAt: $addedAt)';
}


}

/// @nodoc
abstract mixin class _$CollectionPieceItemCopyWith<$Res> implements $CollectionPieceItemCopyWith<$Res> {
  factory _$CollectionPieceItemCopyWith(_CollectionPieceItem value, $Res Function(_CollectionPieceItem) _then) = __$CollectionPieceItemCopyWithImpl;
@override @useResult
$Res call({
 String pieceId, String? slug, String title, int position, String? note, DateTime? addedAt
});




}
/// @nodoc
class __$CollectionPieceItemCopyWithImpl<$Res>
    implements _$CollectionPieceItemCopyWith<$Res> {
  __$CollectionPieceItemCopyWithImpl(this._self, this._then);

  final _CollectionPieceItem _self;
  final $Res Function(_CollectionPieceItem) _then;

/// Create a copy of CollectionPieceItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? pieceId = null,Object? slug = freezed,Object? title = null,Object? position = null,Object? note = freezed,Object? addedAt = freezed,}) {
  return _then(_CollectionPieceItem(
pieceId: null == pieceId ? _self.pieceId : pieceId // ignore: cast_nullable_to_non_nullable
as String,slug: freezed == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String?,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,addedAt: freezed == addedAt ? _self.addedAt : addedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on

// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Profile {

 String get id; String get username; String get penName; String? get avatarKey; String? get coverKey; bool get isPrivate; bool get restricted; String? get bio; String? get websiteUrl; String? get location; Map<String, String> get socialLinks; String? get defaultLanguageId; List<GenreRef> get genres; ProfileCounts get counts; ViewerRelation get viewerRelation;
/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileCopyWith<Profile> get copyWith => _$ProfileCopyWithImpl<Profile>(this as Profile, _$identity);

  /// Serializes this Profile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Profile&&(identical(other.id, id) || other.id == id)&&(identical(other.username, username) || other.username == username)&&(identical(other.penName, penName) || other.penName == penName)&&(identical(other.avatarKey, avatarKey) || other.avatarKey == avatarKey)&&(identical(other.coverKey, coverKey) || other.coverKey == coverKey)&&(identical(other.isPrivate, isPrivate) || other.isPrivate == isPrivate)&&(identical(other.restricted, restricted) || other.restricted == restricted)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.websiteUrl, websiteUrl) || other.websiteUrl == websiteUrl)&&(identical(other.location, location) || other.location == location)&&const DeepCollectionEquality().equals(other.socialLinks, socialLinks)&&(identical(other.defaultLanguageId, defaultLanguageId) || other.defaultLanguageId == defaultLanguageId)&&const DeepCollectionEquality().equals(other.genres, genres)&&(identical(other.counts, counts) || other.counts == counts)&&(identical(other.viewerRelation, viewerRelation) || other.viewerRelation == viewerRelation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,username,penName,avatarKey,coverKey,isPrivate,restricted,bio,websiteUrl,location,const DeepCollectionEquality().hash(socialLinks),defaultLanguageId,const DeepCollectionEquality().hash(genres),counts,viewerRelation);

@override
String toString() {
  return 'Profile(id: $id, username: $username, penName: $penName, avatarKey: $avatarKey, coverKey: $coverKey, isPrivate: $isPrivate, restricted: $restricted, bio: $bio, websiteUrl: $websiteUrl, location: $location, socialLinks: $socialLinks, defaultLanguageId: $defaultLanguageId, genres: $genres, counts: $counts, viewerRelation: $viewerRelation)';
}


}

/// @nodoc
abstract mixin class $ProfileCopyWith<$Res>  {
  factory $ProfileCopyWith(Profile value, $Res Function(Profile) _then) = _$ProfileCopyWithImpl;
@useResult
$Res call({
 String id, String username, String penName, String? avatarKey, String? coverKey, bool isPrivate, bool restricted, String? bio, String? websiteUrl, String? location, Map<String, String> socialLinks, String? defaultLanguageId, List<GenreRef> genres, ProfileCounts counts, ViewerRelation viewerRelation
});


$ProfileCountsCopyWith<$Res> get counts;$ViewerRelationCopyWith<$Res> get viewerRelation;

}
/// @nodoc
class _$ProfileCopyWithImpl<$Res>
    implements $ProfileCopyWith<$Res> {
  _$ProfileCopyWithImpl(this._self, this._then);

  final Profile _self;
  final $Res Function(Profile) _then;

/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? username = null,Object? penName = null,Object? avatarKey = freezed,Object? coverKey = freezed,Object? isPrivate = null,Object? restricted = null,Object? bio = freezed,Object? websiteUrl = freezed,Object? location = freezed,Object? socialLinks = null,Object? defaultLanguageId = freezed,Object? genres = null,Object? counts = null,Object? viewerRelation = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,penName: null == penName ? _self.penName : penName // ignore: cast_nullable_to_non_nullable
as String,avatarKey: freezed == avatarKey ? _self.avatarKey : avatarKey // ignore: cast_nullable_to_non_nullable
as String?,coverKey: freezed == coverKey ? _self.coverKey : coverKey // ignore: cast_nullable_to_non_nullable
as String?,isPrivate: null == isPrivate ? _self.isPrivate : isPrivate // ignore: cast_nullable_to_non_nullable
as bool,restricted: null == restricted ? _self.restricted : restricted // ignore: cast_nullable_to_non_nullable
as bool,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,websiteUrl: freezed == websiteUrl ? _self.websiteUrl : websiteUrl // ignore: cast_nullable_to_non_nullable
as String?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,socialLinks: null == socialLinks ? _self.socialLinks : socialLinks // ignore: cast_nullable_to_non_nullable
as Map<String, String>,defaultLanguageId: freezed == defaultLanguageId ? _self.defaultLanguageId : defaultLanguageId // ignore: cast_nullable_to_non_nullable
as String?,genres: null == genres ? _self.genres : genres // ignore: cast_nullable_to_non_nullable
as List<GenreRef>,counts: null == counts ? _self.counts : counts // ignore: cast_nullable_to_non_nullable
as ProfileCounts,viewerRelation: null == viewerRelation ? _self.viewerRelation : viewerRelation // ignore: cast_nullable_to_non_nullable
as ViewerRelation,
  ));
}
/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProfileCountsCopyWith<$Res> get counts {
  
  return $ProfileCountsCopyWith<$Res>(_self.counts, (value) {
    return _then(_self.copyWith(counts: value));
  });
}/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ViewerRelationCopyWith<$Res> get viewerRelation {
  
  return $ViewerRelationCopyWith<$Res>(_self.viewerRelation, (value) {
    return _then(_self.copyWith(viewerRelation: value));
  });
}
}


/// Adds pattern-matching-related methods to [Profile].
extension ProfilePatterns on Profile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Profile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Profile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Profile value)  $default,){
final _that = this;
switch (_that) {
case _Profile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Profile value)?  $default,){
final _that = this;
switch (_that) {
case _Profile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String username,  String penName,  String? avatarKey,  String? coverKey,  bool isPrivate,  bool restricted,  String? bio,  String? websiteUrl,  String? location,  Map<String, String> socialLinks,  String? defaultLanguageId,  List<GenreRef> genres,  ProfileCounts counts,  ViewerRelation viewerRelation)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Profile() when $default != null:
return $default(_that.id,_that.username,_that.penName,_that.avatarKey,_that.coverKey,_that.isPrivate,_that.restricted,_that.bio,_that.websiteUrl,_that.location,_that.socialLinks,_that.defaultLanguageId,_that.genres,_that.counts,_that.viewerRelation);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String username,  String penName,  String? avatarKey,  String? coverKey,  bool isPrivate,  bool restricted,  String? bio,  String? websiteUrl,  String? location,  Map<String, String> socialLinks,  String? defaultLanguageId,  List<GenreRef> genres,  ProfileCounts counts,  ViewerRelation viewerRelation)  $default,) {final _that = this;
switch (_that) {
case _Profile():
return $default(_that.id,_that.username,_that.penName,_that.avatarKey,_that.coverKey,_that.isPrivate,_that.restricted,_that.bio,_that.websiteUrl,_that.location,_that.socialLinks,_that.defaultLanguageId,_that.genres,_that.counts,_that.viewerRelation);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String username,  String penName,  String? avatarKey,  String? coverKey,  bool isPrivate,  bool restricted,  String? bio,  String? websiteUrl,  String? location,  Map<String, String> socialLinks,  String? defaultLanguageId,  List<GenreRef> genres,  ProfileCounts counts,  ViewerRelation viewerRelation)?  $default,) {final _that = this;
switch (_that) {
case _Profile() when $default != null:
return $default(_that.id,_that.username,_that.penName,_that.avatarKey,_that.coverKey,_that.isPrivate,_that.restricted,_that.bio,_that.websiteUrl,_that.location,_that.socialLinks,_that.defaultLanguageId,_that.genres,_that.counts,_that.viewerRelation);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Profile extends Profile {
  const _Profile({required this.id, required this.username, this.penName = '', this.avatarKey, this.coverKey, this.isPrivate = false, this.restricted = false, this.bio, this.websiteUrl, this.location, final  Map<String, String> socialLinks = const <String, String>{}, this.defaultLanguageId, final  List<GenreRef> genres = const <GenreRef>[], this.counts = const ProfileCounts(), this.viewerRelation = const ViewerRelation()}): _socialLinks = socialLinks,_genres = genres,super._();
  factory _Profile.fromJson(Map<String, dynamic> json) => _$ProfileFromJson(json);

@override final  String id;
@override final  String username;
@override@JsonKey() final  String penName;
@override final  String? avatarKey;
@override final  String? coverKey;
@override@JsonKey() final  bool isPrivate;
@override@JsonKey() final  bool restricted;
@override final  String? bio;
@override final  String? websiteUrl;
@override final  String? location;
 final  Map<String, String> _socialLinks;
@override@JsonKey() Map<String, String> get socialLinks {
  if (_socialLinks is EqualUnmodifiableMapView) return _socialLinks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_socialLinks);
}

@override final  String? defaultLanguageId;
 final  List<GenreRef> _genres;
@override@JsonKey() List<GenreRef> get genres {
  if (_genres is EqualUnmodifiableListView) return _genres;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_genres);
}

@override@JsonKey() final  ProfileCounts counts;
@override@JsonKey() final  ViewerRelation viewerRelation;

/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfileCopyWith<_Profile> get copyWith => __$ProfileCopyWithImpl<_Profile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProfileToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Profile&&(identical(other.id, id) || other.id == id)&&(identical(other.username, username) || other.username == username)&&(identical(other.penName, penName) || other.penName == penName)&&(identical(other.avatarKey, avatarKey) || other.avatarKey == avatarKey)&&(identical(other.coverKey, coverKey) || other.coverKey == coverKey)&&(identical(other.isPrivate, isPrivate) || other.isPrivate == isPrivate)&&(identical(other.restricted, restricted) || other.restricted == restricted)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.websiteUrl, websiteUrl) || other.websiteUrl == websiteUrl)&&(identical(other.location, location) || other.location == location)&&const DeepCollectionEquality().equals(other._socialLinks, _socialLinks)&&(identical(other.defaultLanguageId, defaultLanguageId) || other.defaultLanguageId == defaultLanguageId)&&const DeepCollectionEquality().equals(other._genres, _genres)&&(identical(other.counts, counts) || other.counts == counts)&&(identical(other.viewerRelation, viewerRelation) || other.viewerRelation == viewerRelation));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,username,penName,avatarKey,coverKey,isPrivate,restricted,bio,websiteUrl,location,const DeepCollectionEquality().hash(_socialLinks),defaultLanguageId,const DeepCollectionEquality().hash(_genres),counts,viewerRelation);

@override
String toString() {
  return 'Profile(id: $id, username: $username, penName: $penName, avatarKey: $avatarKey, coverKey: $coverKey, isPrivate: $isPrivate, restricted: $restricted, bio: $bio, websiteUrl: $websiteUrl, location: $location, socialLinks: $socialLinks, defaultLanguageId: $defaultLanguageId, genres: $genres, counts: $counts, viewerRelation: $viewerRelation)';
}


}

/// @nodoc
abstract mixin class _$ProfileCopyWith<$Res> implements $ProfileCopyWith<$Res> {
  factory _$ProfileCopyWith(_Profile value, $Res Function(_Profile) _then) = __$ProfileCopyWithImpl;
@override @useResult
$Res call({
 String id, String username, String penName, String? avatarKey, String? coverKey, bool isPrivate, bool restricted, String? bio, String? websiteUrl, String? location, Map<String, String> socialLinks, String? defaultLanguageId, List<GenreRef> genres, ProfileCounts counts, ViewerRelation viewerRelation
});


@override $ProfileCountsCopyWith<$Res> get counts;@override $ViewerRelationCopyWith<$Res> get viewerRelation;

}
/// @nodoc
class __$ProfileCopyWithImpl<$Res>
    implements _$ProfileCopyWith<$Res> {
  __$ProfileCopyWithImpl(this._self, this._then);

  final _Profile _self;
  final $Res Function(_Profile) _then;

/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? username = null,Object? penName = null,Object? avatarKey = freezed,Object? coverKey = freezed,Object? isPrivate = null,Object? restricted = null,Object? bio = freezed,Object? websiteUrl = freezed,Object? location = freezed,Object? socialLinks = null,Object? defaultLanguageId = freezed,Object? genres = null,Object? counts = null,Object? viewerRelation = null,}) {
  return _then(_Profile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,penName: null == penName ? _self.penName : penName // ignore: cast_nullable_to_non_nullable
as String,avatarKey: freezed == avatarKey ? _self.avatarKey : avatarKey // ignore: cast_nullable_to_non_nullable
as String?,coverKey: freezed == coverKey ? _self.coverKey : coverKey // ignore: cast_nullable_to_non_nullable
as String?,isPrivate: null == isPrivate ? _self.isPrivate : isPrivate // ignore: cast_nullable_to_non_nullable
as bool,restricted: null == restricted ? _self.restricted : restricted // ignore: cast_nullable_to_non_nullable
as bool,bio: freezed == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String?,websiteUrl: freezed == websiteUrl ? _self.websiteUrl : websiteUrl // ignore: cast_nullable_to_non_nullable
as String?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,socialLinks: null == socialLinks ? _self._socialLinks : socialLinks // ignore: cast_nullable_to_non_nullable
as Map<String, String>,defaultLanguageId: freezed == defaultLanguageId ? _self.defaultLanguageId : defaultLanguageId // ignore: cast_nullable_to_non_nullable
as String?,genres: null == genres ? _self._genres : genres // ignore: cast_nullable_to_non_nullable
as List<GenreRef>,counts: null == counts ? _self.counts : counts // ignore: cast_nullable_to_non_nullable
as ProfileCounts,viewerRelation: null == viewerRelation ? _self.viewerRelation : viewerRelation // ignore: cast_nullable_to_non_nullable
as ViewerRelation,
  ));
}

/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProfileCountsCopyWith<$Res> get counts {
  
  return $ProfileCountsCopyWith<$Res>(_self.counts, (value) {
    return _then(_self.copyWith(counts: value));
  });
}/// Create a copy of Profile
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ViewerRelationCopyWith<$Res> get viewerRelation {
  
  return $ViewerRelationCopyWith<$Res>(_self.viewerRelation, (value) {
    return _then(_self.copyWith(viewerRelation: value));
  });
}
}

// dart format on

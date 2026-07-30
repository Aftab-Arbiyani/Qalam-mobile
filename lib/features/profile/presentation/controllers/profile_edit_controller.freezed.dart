// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_edit_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ProfileEditState implements DiagnosticableTreeMixin {

 String get penName; String get bio; String get websiteUrl; String get location; List<GenreRef> get genres; LanguageRef? get defaultLanguage; bool get isPrivate; String? get penNameError; String? get websiteError; bool get submitting; bool get saved; double? get avatarProgress; double? get coverProgress; Failure? get formError; ProfileEditSnapshot? get seed;
/// Create a copy of ProfileEditState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileEditStateCopyWith<ProfileEditState> get copyWith => _$ProfileEditStateCopyWithImpl<ProfileEditState>(this as ProfileEditState, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'ProfileEditState'))
    ..add(DiagnosticsProperty('penName', penName))..add(DiagnosticsProperty('bio', bio))..add(DiagnosticsProperty('websiteUrl', websiteUrl))..add(DiagnosticsProperty('location', location))..add(DiagnosticsProperty('genres', genres))..add(DiagnosticsProperty('defaultLanguage', defaultLanguage))..add(DiagnosticsProperty('isPrivate', isPrivate))..add(DiagnosticsProperty('penNameError', penNameError))..add(DiagnosticsProperty('websiteError', websiteError))..add(DiagnosticsProperty('submitting', submitting))..add(DiagnosticsProperty('saved', saved))..add(DiagnosticsProperty('avatarProgress', avatarProgress))..add(DiagnosticsProperty('coverProgress', coverProgress))..add(DiagnosticsProperty('formError', formError))..add(DiagnosticsProperty('seed', seed));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileEditState&&(identical(other.penName, penName) || other.penName == penName)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.websiteUrl, websiteUrl) || other.websiteUrl == websiteUrl)&&(identical(other.location, location) || other.location == location)&&const DeepCollectionEquality().equals(other.genres, genres)&&(identical(other.defaultLanguage, defaultLanguage) || other.defaultLanguage == defaultLanguage)&&(identical(other.isPrivate, isPrivate) || other.isPrivate == isPrivate)&&(identical(other.penNameError, penNameError) || other.penNameError == penNameError)&&(identical(other.websiteError, websiteError) || other.websiteError == websiteError)&&(identical(other.submitting, submitting) || other.submitting == submitting)&&(identical(other.saved, saved) || other.saved == saved)&&(identical(other.avatarProgress, avatarProgress) || other.avatarProgress == avatarProgress)&&(identical(other.coverProgress, coverProgress) || other.coverProgress == coverProgress)&&(identical(other.formError, formError) || other.formError == formError)&&(identical(other.seed, seed) || other.seed == seed));
}


@override
int get hashCode => Object.hash(runtimeType,penName,bio,websiteUrl,location,const DeepCollectionEquality().hash(genres),defaultLanguage,isPrivate,penNameError,websiteError,submitting,saved,avatarProgress,coverProgress,formError,seed);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'ProfileEditState(penName: $penName, bio: $bio, websiteUrl: $websiteUrl, location: $location, genres: $genres, defaultLanguage: $defaultLanguage, isPrivate: $isPrivate, penNameError: $penNameError, websiteError: $websiteError, submitting: $submitting, saved: $saved, avatarProgress: $avatarProgress, coverProgress: $coverProgress, formError: $formError, seed: $seed)';
}


}

/// @nodoc
abstract mixin class $ProfileEditStateCopyWith<$Res>  {
  factory $ProfileEditStateCopyWith(ProfileEditState value, $Res Function(ProfileEditState) _then) = _$ProfileEditStateCopyWithImpl;
@useResult
$Res call({
 String penName, String bio, String websiteUrl, String location, List<GenreRef> genres, LanguageRef? defaultLanguage, bool isPrivate, String? penNameError, String? websiteError, bool submitting, bool saved, double? avatarProgress, double? coverProgress, Failure? formError, ProfileEditSnapshot? seed
});


$LanguageRefCopyWith<$Res>? get defaultLanguage;$FailureCopyWith<$Res>? get formError;

}
/// @nodoc
class _$ProfileEditStateCopyWithImpl<$Res>
    implements $ProfileEditStateCopyWith<$Res> {
  _$ProfileEditStateCopyWithImpl(this._self, this._then);

  final ProfileEditState _self;
  final $Res Function(ProfileEditState) _then;

/// Create a copy of ProfileEditState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? penName = null,Object? bio = null,Object? websiteUrl = null,Object? location = null,Object? genres = null,Object? defaultLanguage = freezed,Object? isPrivate = null,Object? penNameError = freezed,Object? websiteError = freezed,Object? submitting = null,Object? saved = null,Object? avatarProgress = freezed,Object? coverProgress = freezed,Object? formError = freezed,Object? seed = freezed,}) {
  return _then(_self.copyWith(
penName: null == penName ? _self.penName : penName // ignore: cast_nullable_to_non_nullable
as String,bio: null == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String,websiteUrl: null == websiteUrl ? _self.websiteUrl : websiteUrl // ignore: cast_nullable_to_non_nullable
as String,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String,genres: null == genres ? _self.genres : genres // ignore: cast_nullable_to_non_nullable
as List<GenreRef>,defaultLanguage: freezed == defaultLanguage ? _self.defaultLanguage : defaultLanguage // ignore: cast_nullable_to_non_nullable
as LanguageRef?,isPrivate: null == isPrivate ? _self.isPrivate : isPrivate // ignore: cast_nullable_to_non_nullable
as bool,penNameError: freezed == penNameError ? _self.penNameError : penNameError // ignore: cast_nullable_to_non_nullable
as String?,websiteError: freezed == websiteError ? _self.websiteError : websiteError // ignore: cast_nullable_to_non_nullable
as String?,submitting: null == submitting ? _self.submitting : submitting // ignore: cast_nullable_to_non_nullable
as bool,saved: null == saved ? _self.saved : saved // ignore: cast_nullable_to_non_nullable
as bool,avatarProgress: freezed == avatarProgress ? _self.avatarProgress : avatarProgress // ignore: cast_nullable_to_non_nullable
as double?,coverProgress: freezed == coverProgress ? _self.coverProgress : coverProgress // ignore: cast_nullable_to_non_nullable
as double?,formError: freezed == formError ? _self.formError : formError // ignore: cast_nullable_to_non_nullable
as Failure?,seed: freezed == seed ? _self.seed : seed // ignore: cast_nullable_to_non_nullable
as ProfileEditSnapshot?,
  ));
}
/// Create a copy of ProfileEditState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LanguageRefCopyWith<$Res>? get defaultLanguage {
    if (_self.defaultLanguage == null) {
    return null;
  }

  return $LanguageRefCopyWith<$Res>(_self.defaultLanguage!, (value) {
    return _then(_self.copyWith(defaultLanguage: value));
  });
}/// Create a copy of ProfileEditState
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


/// Adds pattern-matching-related methods to [ProfileEditState].
extension ProfileEditStatePatterns on ProfileEditState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProfileEditState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProfileEditState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProfileEditState value)  $default,){
final _that = this;
switch (_that) {
case _ProfileEditState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProfileEditState value)?  $default,){
final _that = this;
switch (_that) {
case _ProfileEditState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String penName,  String bio,  String websiteUrl,  String location,  List<GenreRef> genres,  LanguageRef? defaultLanguage,  bool isPrivate,  String? penNameError,  String? websiteError,  bool submitting,  bool saved,  double? avatarProgress,  double? coverProgress,  Failure? formError,  ProfileEditSnapshot? seed)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProfileEditState() when $default != null:
return $default(_that.penName,_that.bio,_that.websiteUrl,_that.location,_that.genres,_that.defaultLanguage,_that.isPrivate,_that.penNameError,_that.websiteError,_that.submitting,_that.saved,_that.avatarProgress,_that.coverProgress,_that.formError,_that.seed);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String penName,  String bio,  String websiteUrl,  String location,  List<GenreRef> genres,  LanguageRef? defaultLanguage,  bool isPrivate,  String? penNameError,  String? websiteError,  bool submitting,  bool saved,  double? avatarProgress,  double? coverProgress,  Failure? formError,  ProfileEditSnapshot? seed)  $default,) {final _that = this;
switch (_that) {
case _ProfileEditState():
return $default(_that.penName,_that.bio,_that.websiteUrl,_that.location,_that.genres,_that.defaultLanguage,_that.isPrivate,_that.penNameError,_that.websiteError,_that.submitting,_that.saved,_that.avatarProgress,_that.coverProgress,_that.formError,_that.seed);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String penName,  String bio,  String websiteUrl,  String location,  List<GenreRef> genres,  LanguageRef? defaultLanguage,  bool isPrivate,  String? penNameError,  String? websiteError,  bool submitting,  bool saved,  double? avatarProgress,  double? coverProgress,  Failure? formError,  ProfileEditSnapshot? seed)?  $default,) {final _that = this;
switch (_that) {
case _ProfileEditState() when $default != null:
return $default(_that.penName,_that.bio,_that.websiteUrl,_that.location,_that.genres,_that.defaultLanguage,_that.isPrivate,_that.penNameError,_that.websiteError,_that.submitting,_that.saved,_that.avatarProgress,_that.coverProgress,_that.formError,_that.seed);case _:
  return null;

}
}

}

/// @nodoc


class _ProfileEditState extends ProfileEditState with DiagnosticableTreeMixin {
  const _ProfileEditState({this.penName = '', this.bio = '', this.websiteUrl = '', this.location = '', final  List<GenreRef> genres = const <GenreRef>[], this.defaultLanguage, this.isPrivate = false, this.penNameError, this.websiteError, this.submitting = false, this.saved = false, this.avatarProgress, this.coverProgress, this.formError, this.seed}): _genres = genres,super._();
  

@override@JsonKey() final  String penName;
@override@JsonKey() final  String bio;
@override@JsonKey() final  String websiteUrl;
@override@JsonKey() final  String location;
 final  List<GenreRef> _genres;
@override@JsonKey() List<GenreRef> get genres {
  if (_genres is EqualUnmodifiableListView) return _genres;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_genres);
}

@override final  LanguageRef? defaultLanguage;
@override@JsonKey() final  bool isPrivate;
@override final  String? penNameError;
@override final  String? websiteError;
@override@JsonKey() final  bool submitting;
@override@JsonKey() final  bool saved;
@override final  double? avatarProgress;
@override final  double? coverProgress;
@override final  Failure? formError;
@override final  ProfileEditSnapshot? seed;

/// Create a copy of ProfileEditState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfileEditStateCopyWith<_ProfileEditState> get copyWith => __$ProfileEditStateCopyWithImpl<_ProfileEditState>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'ProfileEditState'))
    ..add(DiagnosticsProperty('penName', penName))..add(DiagnosticsProperty('bio', bio))..add(DiagnosticsProperty('websiteUrl', websiteUrl))..add(DiagnosticsProperty('location', location))..add(DiagnosticsProperty('genres', genres))..add(DiagnosticsProperty('defaultLanguage', defaultLanguage))..add(DiagnosticsProperty('isPrivate', isPrivate))..add(DiagnosticsProperty('penNameError', penNameError))..add(DiagnosticsProperty('websiteError', websiteError))..add(DiagnosticsProperty('submitting', submitting))..add(DiagnosticsProperty('saved', saved))..add(DiagnosticsProperty('avatarProgress', avatarProgress))..add(DiagnosticsProperty('coverProgress', coverProgress))..add(DiagnosticsProperty('formError', formError))..add(DiagnosticsProperty('seed', seed));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProfileEditState&&(identical(other.penName, penName) || other.penName == penName)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.websiteUrl, websiteUrl) || other.websiteUrl == websiteUrl)&&(identical(other.location, location) || other.location == location)&&const DeepCollectionEquality().equals(other._genres, _genres)&&(identical(other.defaultLanguage, defaultLanguage) || other.defaultLanguage == defaultLanguage)&&(identical(other.isPrivate, isPrivate) || other.isPrivate == isPrivate)&&(identical(other.penNameError, penNameError) || other.penNameError == penNameError)&&(identical(other.websiteError, websiteError) || other.websiteError == websiteError)&&(identical(other.submitting, submitting) || other.submitting == submitting)&&(identical(other.saved, saved) || other.saved == saved)&&(identical(other.avatarProgress, avatarProgress) || other.avatarProgress == avatarProgress)&&(identical(other.coverProgress, coverProgress) || other.coverProgress == coverProgress)&&(identical(other.formError, formError) || other.formError == formError)&&(identical(other.seed, seed) || other.seed == seed));
}


@override
int get hashCode => Object.hash(runtimeType,penName,bio,websiteUrl,location,const DeepCollectionEquality().hash(_genres),defaultLanguage,isPrivate,penNameError,websiteError,submitting,saved,avatarProgress,coverProgress,formError,seed);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'ProfileEditState(penName: $penName, bio: $bio, websiteUrl: $websiteUrl, location: $location, genres: $genres, defaultLanguage: $defaultLanguage, isPrivate: $isPrivate, penNameError: $penNameError, websiteError: $websiteError, submitting: $submitting, saved: $saved, avatarProgress: $avatarProgress, coverProgress: $coverProgress, formError: $formError, seed: $seed)';
}


}

/// @nodoc
abstract mixin class _$ProfileEditStateCopyWith<$Res> implements $ProfileEditStateCopyWith<$Res> {
  factory _$ProfileEditStateCopyWith(_ProfileEditState value, $Res Function(_ProfileEditState) _then) = __$ProfileEditStateCopyWithImpl;
@override @useResult
$Res call({
 String penName, String bio, String websiteUrl, String location, List<GenreRef> genres, LanguageRef? defaultLanguage, bool isPrivate, String? penNameError, String? websiteError, bool submitting, bool saved, double? avatarProgress, double? coverProgress, Failure? formError, ProfileEditSnapshot? seed
});


@override $LanguageRefCopyWith<$Res>? get defaultLanguage;@override $FailureCopyWith<$Res>? get formError;

}
/// @nodoc
class __$ProfileEditStateCopyWithImpl<$Res>
    implements _$ProfileEditStateCopyWith<$Res> {
  __$ProfileEditStateCopyWithImpl(this._self, this._then);

  final _ProfileEditState _self;
  final $Res Function(_ProfileEditState) _then;

/// Create a copy of ProfileEditState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? penName = null,Object? bio = null,Object? websiteUrl = null,Object? location = null,Object? genres = null,Object? defaultLanguage = freezed,Object? isPrivate = null,Object? penNameError = freezed,Object? websiteError = freezed,Object? submitting = null,Object? saved = null,Object? avatarProgress = freezed,Object? coverProgress = freezed,Object? formError = freezed,Object? seed = freezed,}) {
  return _then(_ProfileEditState(
penName: null == penName ? _self.penName : penName // ignore: cast_nullable_to_non_nullable
as String,bio: null == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String,websiteUrl: null == websiteUrl ? _self.websiteUrl : websiteUrl // ignore: cast_nullable_to_non_nullable
as String,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String,genres: null == genres ? _self._genres : genres // ignore: cast_nullable_to_non_nullable
as List<GenreRef>,defaultLanguage: freezed == defaultLanguage ? _self.defaultLanguage : defaultLanguage // ignore: cast_nullable_to_non_nullable
as LanguageRef?,isPrivate: null == isPrivate ? _self.isPrivate : isPrivate // ignore: cast_nullable_to_non_nullable
as bool,penNameError: freezed == penNameError ? _self.penNameError : penNameError // ignore: cast_nullable_to_non_nullable
as String?,websiteError: freezed == websiteError ? _self.websiteError : websiteError // ignore: cast_nullable_to_non_nullable
as String?,submitting: null == submitting ? _self.submitting : submitting // ignore: cast_nullable_to_non_nullable
as bool,saved: null == saved ? _self.saved : saved // ignore: cast_nullable_to_non_nullable
as bool,avatarProgress: freezed == avatarProgress ? _self.avatarProgress : avatarProgress // ignore: cast_nullable_to_non_nullable
as double?,coverProgress: freezed == coverProgress ? _self.coverProgress : coverProgress // ignore: cast_nullable_to_non_nullable
as double?,formError: freezed == formError ? _self.formError : formError // ignore: cast_nullable_to_non_nullable
as Failure?,seed: freezed == seed ? _self.seed : seed // ignore: cast_nullable_to_non_nullable
as ProfileEditSnapshot?,
  ));
}

/// Create a copy of ProfileEditState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LanguageRefCopyWith<$Res>? get defaultLanguage {
    if (_self.defaultLanguage == null) {
    return null;
  }

  return $LanguageRefCopyWith<$Res>(_self.defaultLanguage!, (value) {
    return _then(_self.copyWith(defaultLanguage: value));
  });
}/// Create a copy of ProfileEditState
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

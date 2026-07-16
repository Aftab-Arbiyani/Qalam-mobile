// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'global_search_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GlobalSearchResult {

 List<WriterSummary> get writers; List<PieceSummary> get pieces; List<TrendingTag> get tags; List<TrendingGenre> get genres; List<TrendingLanguage> get languages;
/// Create a copy of GlobalSearchResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GlobalSearchResultCopyWith<GlobalSearchResult> get copyWith => _$GlobalSearchResultCopyWithImpl<GlobalSearchResult>(this as GlobalSearchResult, _$identity);

  /// Serializes this GlobalSearchResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GlobalSearchResult&&const DeepCollectionEquality().equals(other.writers, writers)&&const DeepCollectionEquality().equals(other.pieces, pieces)&&const DeepCollectionEquality().equals(other.tags, tags)&&const DeepCollectionEquality().equals(other.genres, genres)&&const DeepCollectionEquality().equals(other.languages, languages));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(writers),const DeepCollectionEquality().hash(pieces),const DeepCollectionEquality().hash(tags),const DeepCollectionEquality().hash(genres),const DeepCollectionEquality().hash(languages));

@override
String toString() {
  return 'GlobalSearchResult(writers: $writers, pieces: $pieces, tags: $tags, genres: $genres, languages: $languages)';
}


}

/// @nodoc
abstract mixin class $GlobalSearchResultCopyWith<$Res>  {
  factory $GlobalSearchResultCopyWith(GlobalSearchResult value, $Res Function(GlobalSearchResult) _then) = _$GlobalSearchResultCopyWithImpl;
@useResult
$Res call({
 List<WriterSummary> writers, List<PieceSummary> pieces, List<TrendingTag> tags, List<TrendingGenre> genres, List<TrendingLanguage> languages
});




}
/// @nodoc
class _$GlobalSearchResultCopyWithImpl<$Res>
    implements $GlobalSearchResultCopyWith<$Res> {
  _$GlobalSearchResultCopyWithImpl(this._self, this._then);

  final GlobalSearchResult _self;
  final $Res Function(GlobalSearchResult) _then;

/// Create a copy of GlobalSearchResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? writers = null,Object? pieces = null,Object? tags = null,Object? genres = null,Object? languages = null,}) {
  return _then(_self.copyWith(
writers: null == writers ? _self.writers : writers // ignore: cast_nullable_to_non_nullable
as List<WriterSummary>,pieces: null == pieces ? _self.pieces : pieces // ignore: cast_nullable_to_non_nullable
as List<PieceSummary>,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<TrendingTag>,genres: null == genres ? _self.genres : genres // ignore: cast_nullable_to_non_nullable
as List<TrendingGenre>,languages: null == languages ? _self.languages : languages // ignore: cast_nullable_to_non_nullable
as List<TrendingLanguage>,
  ));
}

}


/// Adds pattern-matching-related methods to [GlobalSearchResult].
extension GlobalSearchResultPatterns on GlobalSearchResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GlobalSearchResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GlobalSearchResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GlobalSearchResult value)  $default,){
final _that = this;
switch (_that) {
case _GlobalSearchResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GlobalSearchResult value)?  $default,){
final _that = this;
switch (_that) {
case _GlobalSearchResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<WriterSummary> writers,  List<PieceSummary> pieces,  List<TrendingTag> tags,  List<TrendingGenre> genres,  List<TrendingLanguage> languages)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GlobalSearchResult() when $default != null:
return $default(_that.writers,_that.pieces,_that.tags,_that.genres,_that.languages);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<WriterSummary> writers,  List<PieceSummary> pieces,  List<TrendingTag> tags,  List<TrendingGenre> genres,  List<TrendingLanguage> languages)  $default,) {final _that = this;
switch (_that) {
case _GlobalSearchResult():
return $default(_that.writers,_that.pieces,_that.tags,_that.genres,_that.languages);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<WriterSummary> writers,  List<PieceSummary> pieces,  List<TrendingTag> tags,  List<TrendingGenre> genres,  List<TrendingLanguage> languages)?  $default,) {final _that = this;
switch (_that) {
case _GlobalSearchResult() when $default != null:
return $default(_that.writers,_that.pieces,_that.tags,_that.genres,_that.languages);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GlobalSearchResult extends GlobalSearchResult {
  const _GlobalSearchResult({final  List<WriterSummary> writers = const <WriterSummary>[], final  List<PieceSummary> pieces = const <PieceSummary>[], final  List<TrendingTag> tags = const <TrendingTag>[], final  List<TrendingGenre> genres = const <TrendingGenre>[], final  List<TrendingLanguage> languages = const <TrendingLanguage>[]}): _writers = writers,_pieces = pieces,_tags = tags,_genres = genres,_languages = languages,super._();
  factory _GlobalSearchResult.fromJson(Map<String, dynamic> json) => _$GlobalSearchResultFromJson(json);

 final  List<WriterSummary> _writers;
@override@JsonKey() List<WriterSummary> get writers {
  if (_writers is EqualUnmodifiableListView) return _writers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_writers);
}

 final  List<PieceSummary> _pieces;
@override@JsonKey() List<PieceSummary> get pieces {
  if (_pieces is EqualUnmodifiableListView) return _pieces;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_pieces);
}

 final  List<TrendingTag> _tags;
@override@JsonKey() List<TrendingTag> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

 final  List<TrendingGenre> _genres;
@override@JsonKey() List<TrendingGenre> get genres {
  if (_genres is EqualUnmodifiableListView) return _genres;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_genres);
}

 final  List<TrendingLanguage> _languages;
@override@JsonKey() List<TrendingLanguage> get languages {
  if (_languages is EqualUnmodifiableListView) return _languages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_languages);
}


/// Create a copy of GlobalSearchResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GlobalSearchResultCopyWith<_GlobalSearchResult> get copyWith => __$GlobalSearchResultCopyWithImpl<_GlobalSearchResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GlobalSearchResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GlobalSearchResult&&const DeepCollectionEquality().equals(other._writers, _writers)&&const DeepCollectionEquality().equals(other._pieces, _pieces)&&const DeepCollectionEquality().equals(other._tags, _tags)&&const DeepCollectionEquality().equals(other._genres, _genres)&&const DeepCollectionEquality().equals(other._languages, _languages));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_writers),const DeepCollectionEquality().hash(_pieces),const DeepCollectionEquality().hash(_tags),const DeepCollectionEquality().hash(_genres),const DeepCollectionEquality().hash(_languages));

@override
String toString() {
  return 'GlobalSearchResult(writers: $writers, pieces: $pieces, tags: $tags, genres: $genres, languages: $languages)';
}


}

/// @nodoc
abstract mixin class _$GlobalSearchResultCopyWith<$Res> implements $GlobalSearchResultCopyWith<$Res> {
  factory _$GlobalSearchResultCopyWith(_GlobalSearchResult value, $Res Function(_GlobalSearchResult) _then) = __$GlobalSearchResultCopyWithImpl;
@override @useResult
$Res call({
 List<WriterSummary> writers, List<PieceSummary> pieces, List<TrendingTag> tags, List<TrendingGenre> genres, List<TrendingLanguage> languages
});




}
/// @nodoc
class __$GlobalSearchResultCopyWithImpl<$Res>
    implements _$GlobalSearchResultCopyWith<$Res> {
  __$GlobalSearchResultCopyWithImpl(this._self, this._then);

  final _GlobalSearchResult _self;
  final $Res Function(_GlobalSearchResult) _then;

/// Create a copy of GlobalSearchResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? writers = null,Object? pieces = null,Object? tags = null,Object? genres = null,Object? languages = null,}) {
  return _then(_GlobalSearchResult(
writers: null == writers ? _self._writers : writers // ignore: cast_nullable_to_non_nullable
as List<WriterSummary>,pieces: null == pieces ? _self._pieces : pieces // ignore: cast_nullable_to_non_nullable
as List<PieceSummary>,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<TrendingTag>,genres: null == genres ? _self._genres : genres // ignore: cast_nullable_to_non_nullable
as List<TrendingGenre>,languages: null == languages ? _self._languages : languages // ignore: cast_nullable_to_non_nullable
as List<TrendingLanguage>,
  ));
}


}

// dart format on

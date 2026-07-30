// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trending_searches.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$TrendingKeyword {

 String get keyword; int get searchCount;
/// Create a copy of TrendingKeyword
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrendingKeywordCopyWith<TrendingKeyword> get copyWith => _$TrendingKeywordCopyWithImpl<TrendingKeyword>(this as TrendingKeyword, _$identity);

  /// Serializes this TrendingKeyword to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrendingKeyword&&(identical(other.keyword, keyword) || other.keyword == keyword)&&(identical(other.searchCount, searchCount) || other.searchCount == searchCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,keyword,searchCount);

@override
String toString() {
  return 'TrendingKeyword(keyword: $keyword, searchCount: $searchCount)';
}


}

/// @nodoc
abstract mixin class $TrendingKeywordCopyWith<$Res>  {
  factory $TrendingKeywordCopyWith(TrendingKeyword value, $Res Function(TrendingKeyword) _then) = _$TrendingKeywordCopyWithImpl;
@useResult
$Res call({
 String keyword, int searchCount
});




}
/// @nodoc
class _$TrendingKeywordCopyWithImpl<$Res>
    implements $TrendingKeywordCopyWith<$Res> {
  _$TrendingKeywordCopyWithImpl(this._self, this._then);

  final TrendingKeyword _self;
  final $Res Function(TrendingKeyword) _then;

/// Create a copy of TrendingKeyword
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? keyword = null,Object? searchCount = null,}) {
  return _then(_self.copyWith(
keyword: null == keyword ? _self.keyword : keyword // ignore: cast_nullable_to_non_nullable
as String,searchCount: null == searchCount ? _self.searchCount : searchCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [TrendingKeyword].
extension TrendingKeywordPatterns on TrendingKeyword {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrendingKeyword value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrendingKeyword() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrendingKeyword value)  $default,){
final _that = this;
switch (_that) {
case _TrendingKeyword():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrendingKeyword value)?  $default,){
final _that = this;
switch (_that) {
case _TrendingKeyword() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String keyword,  int searchCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrendingKeyword() when $default != null:
return $default(_that.keyword,_that.searchCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String keyword,  int searchCount)  $default,) {final _that = this;
switch (_that) {
case _TrendingKeyword():
return $default(_that.keyword,_that.searchCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String keyword,  int searchCount)?  $default,) {final _that = this;
switch (_that) {
case _TrendingKeyword() when $default != null:
return $default(_that.keyword,_that.searchCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TrendingKeyword implements TrendingKeyword {
  const _TrendingKeyword({required this.keyword, this.searchCount = 0});
  factory _TrendingKeyword.fromJson(Map<String, dynamic> json) => _$TrendingKeywordFromJson(json);

@override final  String keyword;
@override@JsonKey() final  int searchCount;

/// Create a copy of TrendingKeyword
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrendingKeywordCopyWith<_TrendingKeyword> get copyWith => __$TrendingKeywordCopyWithImpl<_TrendingKeyword>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TrendingKeywordToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrendingKeyword&&(identical(other.keyword, keyword) || other.keyword == keyword)&&(identical(other.searchCount, searchCount) || other.searchCount == searchCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,keyword,searchCount);

@override
String toString() {
  return 'TrendingKeyword(keyword: $keyword, searchCount: $searchCount)';
}


}

/// @nodoc
abstract mixin class _$TrendingKeywordCopyWith<$Res> implements $TrendingKeywordCopyWith<$Res> {
  factory _$TrendingKeywordCopyWith(_TrendingKeyword value, $Res Function(_TrendingKeyword) _then) = __$TrendingKeywordCopyWithImpl;
@override @useResult
$Res call({
 String keyword, int searchCount
});




}
/// @nodoc
class __$TrendingKeywordCopyWithImpl<$Res>
    implements _$TrendingKeywordCopyWith<$Res> {
  __$TrendingKeywordCopyWithImpl(this._self, this._then);

  final _TrendingKeyword _self;
  final $Res Function(_TrendingKeyword) _then;

/// Create a copy of TrendingKeyword
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? keyword = null,Object? searchCount = null,}) {
  return _then(_TrendingKeyword(
keyword: null == keyword ? _self.keyword : keyword // ignore: cast_nullable_to_non_nullable
as String,searchCount: null == searchCount ? _self.searchCount : searchCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$TrendingSearches {

 List<TrendingKeyword> get keywords; List<TrendingTag> get tags; List<TrendingGenre> get genres; List<WriterSummary> get writers;
/// Create a copy of TrendingSearches
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TrendingSearchesCopyWith<TrendingSearches> get copyWith => _$TrendingSearchesCopyWithImpl<TrendingSearches>(this as TrendingSearches, _$identity);

  /// Serializes this TrendingSearches to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TrendingSearches&&const DeepCollectionEquality().equals(other.keywords, keywords)&&const DeepCollectionEquality().equals(other.tags, tags)&&const DeepCollectionEquality().equals(other.genres, genres)&&const DeepCollectionEquality().equals(other.writers, writers));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(keywords),const DeepCollectionEquality().hash(tags),const DeepCollectionEquality().hash(genres),const DeepCollectionEquality().hash(writers));

@override
String toString() {
  return 'TrendingSearches(keywords: $keywords, tags: $tags, genres: $genres, writers: $writers)';
}


}

/// @nodoc
abstract mixin class $TrendingSearchesCopyWith<$Res>  {
  factory $TrendingSearchesCopyWith(TrendingSearches value, $Res Function(TrendingSearches) _then) = _$TrendingSearchesCopyWithImpl;
@useResult
$Res call({
 List<TrendingKeyword> keywords, List<TrendingTag> tags, List<TrendingGenre> genres, List<WriterSummary> writers
});




}
/// @nodoc
class _$TrendingSearchesCopyWithImpl<$Res>
    implements $TrendingSearchesCopyWith<$Res> {
  _$TrendingSearchesCopyWithImpl(this._self, this._then);

  final TrendingSearches _self;
  final $Res Function(TrendingSearches) _then;

/// Create a copy of TrendingSearches
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? keywords = null,Object? tags = null,Object? genres = null,Object? writers = null,}) {
  return _then(_self.copyWith(
keywords: null == keywords ? _self.keywords : keywords // ignore: cast_nullable_to_non_nullable
as List<TrendingKeyword>,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<TrendingTag>,genres: null == genres ? _self.genres : genres // ignore: cast_nullable_to_non_nullable
as List<TrendingGenre>,writers: null == writers ? _self.writers : writers // ignore: cast_nullable_to_non_nullable
as List<WriterSummary>,
  ));
}

}


/// Adds pattern-matching-related methods to [TrendingSearches].
extension TrendingSearchesPatterns on TrendingSearches {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TrendingSearches value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TrendingSearches() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TrendingSearches value)  $default,){
final _that = this;
switch (_that) {
case _TrendingSearches():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TrendingSearches value)?  $default,){
final _that = this;
switch (_that) {
case _TrendingSearches() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<TrendingKeyword> keywords,  List<TrendingTag> tags,  List<TrendingGenre> genres,  List<WriterSummary> writers)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TrendingSearches() when $default != null:
return $default(_that.keywords,_that.tags,_that.genres,_that.writers);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<TrendingKeyword> keywords,  List<TrendingTag> tags,  List<TrendingGenre> genres,  List<WriterSummary> writers)  $default,) {final _that = this;
switch (_that) {
case _TrendingSearches():
return $default(_that.keywords,_that.tags,_that.genres,_that.writers);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<TrendingKeyword> keywords,  List<TrendingTag> tags,  List<TrendingGenre> genres,  List<WriterSummary> writers)?  $default,) {final _that = this;
switch (_that) {
case _TrendingSearches() when $default != null:
return $default(_that.keywords,_that.tags,_that.genres,_that.writers);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TrendingSearches extends TrendingSearches {
  const _TrendingSearches({final  List<TrendingKeyword> keywords = const <TrendingKeyword>[], final  List<TrendingTag> tags = const <TrendingTag>[], final  List<TrendingGenre> genres = const <TrendingGenre>[], final  List<WriterSummary> writers = const <WriterSummary>[]}): _keywords = keywords,_tags = tags,_genres = genres,_writers = writers,super._();
  factory _TrendingSearches.fromJson(Map<String, dynamic> json) => _$TrendingSearchesFromJson(json);

 final  List<TrendingKeyword> _keywords;
@override@JsonKey() List<TrendingKeyword> get keywords {
  if (_keywords is EqualUnmodifiableListView) return _keywords;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_keywords);
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

 final  List<WriterSummary> _writers;
@override@JsonKey() List<WriterSummary> get writers {
  if (_writers is EqualUnmodifiableListView) return _writers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_writers);
}


/// Create a copy of TrendingSearches
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TrendingSearchesCopyWith<_TrendingSearches> get copyWith => __$TrendingSearchesCopyWithImpl<_TrendingSearches>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TrendingSearchesToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TrendingSearches&&const DeepCollectionEquality().equals(other._keywords, _keywords)&&const DeepCollectionEquality().equals(other._tags, _tags)&&const DeepCollectionEquality().equals(other._genres, _genres)&&const DeepCollectionEquality().equals(other._writers, _writers));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_keywords),const DeepCollectionEquality().hash(_tags),const DeepCollectionEquality().hash(_genres),const DeepCollectionEquality().hash(_writers));

@override
String toString() {
  return 'TrendingSearches(keywords: $keywords, tags: $tags, genres: $genres, writers: $writers)';
}


}

/// @nodoc
abstract mixin class _$TrendingSearchesCopyWith<$Res> implements $TrendingSearchesCopyWith<$Res> {
  factory _$TrendingSearchesCopyWith(_TrendingSearches value, $Res Function(_TrendingSearches) _then) = __$TrendingSearchesCopyWithImpl;
@override @useResult
$Res call({
 List<TrendingKeyword> keywords, List<TrendingTag> tags, List<TrendingGenre> genres, List<WriterSummary> writers
});




}
/// @nodoc
class __$TrendingSearchesCopyWithImpl<$Res>
    implements _$TrendingSearchesCopyWith<$Res> {
  __$TrendingSearchesCopyWithImpl(this._self, this._then);

  final _TrendingSearches _self;
  final $Res Function(_TrendingSearches) _then;

/// Create a copy of TrendingSearches
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? keywords = null,Object? tags = null,Object? genres = null,Object? writers = null,}) {
  return _then(_TrendingSearches(
keywords: null == keywords ? _self._keywords : keywords // ignore: cast_nullable_to_non_nullable
as List<TrendingKeyword>,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<TrendingTag>,genres: null == genres ? _self._genres : genres // ignore: cast_nullable_to_non_nullable
as List<TrendingGenre>,writers: null == writers ? _self._writers : writers // ignore: cast_nullable_to_non_nullable
as List<WriterSummary>,
  ));
}


}

// dart format on

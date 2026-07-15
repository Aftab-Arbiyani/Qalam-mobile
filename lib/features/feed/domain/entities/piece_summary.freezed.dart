// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'piece_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PieceSummaryStats {

 int get likes; int get claps; int get comments; int get responses;
/// Create a copy of PieceSummaryStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PieceSummaryStatsCopyWith<PieceSummaryStats> get copyWith => _$PieceSummaryStatsCopyWithImpl<PieceSummaryStats>(this as PieceSummaryStats, _$identity);

  /// Serializes this PieceSummaryStats to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PieceSummaryStats&&(identical(other.likes, likes) || other.likes == likes)&&(identical(other.claps, claps) || other.claps == claps)&&(identical(other.comments, comments) || other.comments == comments)&&(identical(other.responses, responses) || other.responses == responses));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,likes,claps,comments,responses);

@override
String toString() {
  return 'PieceSummaryStats(likes: $likes, claps: $claps, comments: $comments, responses: $responses)';
}


}

/// @nodoc
abstract mixin class $PieceSummaryStatsCopyWith<$Res>  {
  factory $PieceSummaryStatsCopyWith(PieceSummaryStats value, $Res Function(PieceSummaryStats) _then) = _$PieceSummaryStatsCopyWithImpl;
@useResult
$Res call({
 int likes, int claps, int comments, int responses
});




}
/// @nodoc
class _$PieceSummaryStatsCopyWithImpl<$Res>
    implements $PieceSummaryStatsCopyWith<$Res> {
  _$PieceSummaryStatsCopyWithImpl(this._self, this._then);

  final PieceSummaryStats _self;
  final $Res Function(PieceSummaryStats) _then;

/// Create a copy of PieceSummaryStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? likes = null,Object? claps = null,Object? comments = null,Object? responses = null,}) {
  return _then(_self.copyWith(
likes: null == likes ? _self.likes : likes // ignore: cast_nullable_to_non_nullable
as int,claps: null == claps ? _self.claps : claps // ignore: cast_nullable_to_non_nullable
as int,comments: null == comments ? _self.comments : comments // ignore: cast_nullable_to_non_nullable
as int,responses: null == responses ? _self.responses : responses // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PieceSummaryStats].
extension PieceSummaryStatsPatterns on PieceSummaryStats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PieceSummaryStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PieceSummaryStats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PieceSummaryStats value)  $default,){
final _that = this;
switch (_that) {
case _PieceSummaryStats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PieceSummaryStats value)?  $default,){
final _that = this;
switch (_that) {
case _PieceSummaryStats() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int likes,  int claps,  int comments,  int responses)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PieceSummaryStats() when $default != null:
return $default(_that.likes,_that.claps,_that.comments,_that.responses);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int likes,  int claps,  int comments,  int responses)  $default,) {final _that = this;
switch (_that) {
case _PieceSummaryStats():
return $default(_that.likes,_that.claps,_that.comments,_that.responses);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int likes,  int claps,  int comments,  int responses)?  $default,) {final _that = this;
switch (_that) {
case _PieceSummaryStats() when $default != null:
return $default(_that.likes,_that.claps,_that.comments,_that.responses);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PieceSummaryStats implements PieceSummaryStats {
  const _PieceSummaryStats({this.likes = 0, this.claps = 0, this.comments = 0, this.responses = 0});
  factory _PieceSummaryStats.fromJson(Map<String, dynamic> json) => _$PieceSummaryStatsFromJson(json);

@override@JsonKey() final  int likes;
@override@JsonKey() final  int claps;
@override@JsonKey() final  int comments;
@override@JsonKey() final  int responses;

/// Create a copy of PieceSummaryStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PieceSummaryStatsCopyWith<_PieceSummaryStats> get copyWith => __$PieceSummaryStatsCopyWithImpl<_PieceSummaryStats>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PieceSummaryStatsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PieceSummaryStats&&(identical(other.likes, likes) || other.likes == likes)&&(identical(other.claps, claps) || other.claps == claps)&&(identical(other.comments, comments) || other.comments == comments)&&(identical(other.responses, responses) || other.responses == responses));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,likes,claps,comments,responses);

@override
String toString() {
  return 'PieceSummaryStats(likes: $likes, claps: $claps, comments: $comments, responses: $responses)';
}


}

/// @nodoc
abstract mixin class _$PieceSummaryStatsCopyWith<$Res> implements $PieceSummaryStatsCopyWith<$Res> {
  factory _$PieceSummaryStatsCopyWith(_PieceSummaryStats value, $Res Function(_PieceSummaryStats) _then) = __$PieceSummaryStatsCopyWithImpl;
@override @useResult
$Res call({
 int likes, int claps, int comments, int responses
});




}
/// @nodoc
class __$PieceSummaryStatsCopyWithImpl<$Res>
    implements _$PieceSummaryStatsCopyWith<$Res> {
  __$PieceSummaryStatsCopyWithImpl(this._self, this._then);

  final _PieceSummaryStats _self;
  final $Res Function(_PieceSummaryStats) _then;

/// Create a copy of PieceSummaryStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? likes = null,Object? claps = null,Object? comments = null,Object? responses = null,}) {
  return _then(_PieceSummaryStats(
likes: null == likes ? _self.likes : likes // ignore: cast_nullable_to_non_nullable
as int,claps: null == claps ? _self.claps : claps // ignore: cast_nullable_to_non_nullable
as int,comments: null == comments ? _self.comments : comments // ignore: cast_nullable_to_non_nullable
as int,responses: null == responses ? _self.responses : responses // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$PieceSummary {

 String get id; String get title; Author get author; LanguageRef get language; String? get slug; String? get subtitle; String? get featuredQuote; String? get coverImageKey; GenreRef? get genre; PieceSummaryStats get stats; Visibility get visibility; int get wordCount; int get readingTimeSeconds; DateTime? get publishedAt;
/// Create a copy of PieceSummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PieceSummaryCopyWith<PieceSummary> get copyWith => _$PieceSummaryCopyWithImpl<PieceSummary>(this as PieceSummary, _$identity);

  /// Serializes this PieceSummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PieceSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.author, author) || other.author == author)&&(identical(other.language, language) || other.language == language)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle)&&(identical(other.featuredQuote, featuredQuote) || other.featuredQuote == featuredQuote)&&(identical(other.coverImageKey, coverImageKey) || other.coverImageKey == coverImageKey)&&(identical(other.genre, genre) || other.genre == genre)&&(identical(other.stats, stats) || other.stats == stats)&&(identical(other.visibility, visibility) || other.visibility == visibility)&&(identical(other.wordCount, wordCount) || other.wordCount == wordCount)&&(identical(other.readingTimeSeconds, readingTimeSeconds) || other.readingTimeSeconds == readingTimeSeconds)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,author,language,slug,subtitle,featuredQuote,coverImageKey,genre,stats,visibility,wordCount,readingTimeSeconds,publishedAt);

@override
String toString() {
  return 'PieceSummary(id: $id, title: $title, author: $author, language: $language, slug: $slug, subtitle: $subtitle, featuredQuote: $featuredQuote, coverImageKey: $coverImageKey, genre: $genre, stats: $stats, visibility: $visibility, wordCount: $wordCount, readingTimeSeconds: $readingTimeSeconds, publishedAt: $publishedAt)';
}


}

/// @nodoc
abstract mixin class $PieceSummaryCopyWith<$Res>  {
  factory $PieceSummaryCopyWith(PieceSummary value, $Res Function(PieceSummary) _then) = _$PieceSummaryCopyWithImpl;
@useResult
$Res call({
 String id, String title, Author author, LanguageRef language, String? slug, String? subtitle, String? featuredQuote, String? coverImageKey, GenreRef? genre, PieceSummaryStats stats, Visibility visibility, int wordCount, int readingTimeSeconds, DateTime? publishedAt
});


$AuthorCopyWith<$Res> get author;$LanguageRefCopyWith<$Res> get language;$GenreRefCopyWith<$Res>? get genre;$PieceSummaryStatsCopyWith<$Res> get stats;

}
/// @nodoc
class _$PieceSummaryCopyWithImpl<$Res>
    implements $PieceSummaryCopyWith<$Res> {
  _$PieceSummaryCopyWithImpl(this._self, this._then);

  final PieceSummary _self;
  final $Res Function(PieceSummary) _then;

/// Create a copy of PieceSummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? author = null,Object? language = null,Object? slug = freezed,Object? subtitle = freezed,Object? featuredQuote = freezed,Object? coverImageKey = freezed,Object? genre = freezed,Object? stats = null,Object? visibility = null,Object? wordCount = null,Object? readingTimeSeconds = null,Object? publishedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as Author,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as LanguageRef,slug: freezed == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String?,subtitle: freezed == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String?,featuredQuote: freezed == featuredQuote ? _self.featuredQuote : featuredQuote // ignore: cast_nullable_to_non_nullable
as String?,coverImageKey: freezed == coverImageKey ? _self.coverImageKey : coverImageKey // ignore: cast_nullable_to_non_nullable
as String?,genre: freezed == genre ? _self.genre : genre // ignore: cast_nullable_to_non_nullable
as GenreRef?,stats: null == stats ? _self.stats : stats // ignore: cast_nullable_to_non_nullable
as PieceSummaryStats,visibility: null == visibility ? _self.visibility : visibility // ignore: cast_nullable_to_non_nullable
as Visibility,wordCount: null == wordCount ? _self.wordCount : wordCount // ignore: cast_nullable_to_non_nullable
as int,readingTimeSeconds: null == readingTimeSeconds ? _self.readingTimeSeconds : readingTimeSeconds // ignore: cast_nullable_to_non_nullable
as int,publishedAt: freezed == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of PieceSummary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AuthorCopyWith<$Res> get author {
  
  return $AuthorCopyWith<$Res>(_self.author, (value) {
    return _then(_self.copyWith(author: value));
  });
}/// Create a copy of PieceSummary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LanguageRefCopyWith<$Res> get language {
  
  return $LanguageRefCopyWith<$Res>(_self.language, (value) {
    return _then(_self.copyWith(language: value));
  });
}/// Create a copy of PieceSummary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GenreRefCopyWith<$Res>? get genre {
    if (_self.genre == null) {
    return null;
  }

  return $GenreRefCopyWith<$Res>(_self.genre!, (value) {
    return _then(_self.copyWith(genre: value));
  });
}/// Create a copy of PieceSummary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PieceSummaryStatsCopyWith<$Res> get stats {
  
  return $PieceSummaryStatsCopyWith<$Res>(_self.stats, (value) {
    return _then(_self.copyWith(stats: value));
  });
}
}


/// Adds pattern-matching-related methods to [PieceSummary].
extension PieceSummaryPatterns on PieceSummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PieceSummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PieceSummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PieceSummary value)  $default,){
final _that = this;
switch (_that) {
case _PieceSummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PieceSummary value)?  $default,){
final _that = this;
switch (_that) {
case _PieceSummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  Author author,  LanguageRef language,  String? slug,  String? subtitle,  String? featuredQuote,  String? coverImageKey,  GenreRef? genre,  PieceSummaryStats stats,  Visibility visibility,  int wordCount,  int readingTimeSeconds,  DateTime? publishedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PieceSummary() when $default != null:
return $default(_that.id,_that.title,_that.author,_that.language,_that.slug,_that.subtitle,_that.featuredQuote,_that.coverImageKey,_that.genre,_that.stats,_that.visibility,_that.wordCount,_that.readingTimeSeconds,_that.publishedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  Author author,  LanguageRef language,  String? slug,  String? subtitle,  String? featuredQuote,  String? coverImageKey,  GenreRef? genre,  PieceSummaryStats stats,  Visibility visibility,  int wordCount,  int readingTimeSeconds,  DateTime? publishedAt)  $default,) {final _that = this;
switch (_that) {
case _PieceSummary():
return $default(_that.id,_that.title,_that.author,_that.language,_that.slug,_that.subtitle,_that.featuredQuote,_that.coverImageKey,_that.genre,_that.stats,_that.visibility,_that.wordCount,_that.readingTimeSeconds,_that.publishedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  Author author,  LanguageRef language,  String? slug,  String? subtitle,  String? featuredQuote,  String? coverImageKey,  GenreRef? genre,  PieceSummaryStats stats,  Visibility visibility,  int wordCount,  int readingTimeSeconds,  DateTime? publishedAt)?  $default,) {final _that = this;
switch (_that) {
case _PieceSummary() when $default != null:
return $default(_that.id,_that.title,_that.author,_that.language,_that.slug,_that.subtitle,_that.featuredQuote,_that.coverImageKey,_that.genre,_that.stats,_that.visibility,_that.wordCount,_that.readingTimeSeconds,_that.publishedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PieceSummary extends PieceSummary {
  const _PieceSummary({required this.id, required this.title, required this.author, required this.language, this.slug, this.subtitle, this.featuredQuote, this.coverImageKey, this.genre, this.stats = const PieceSummaryStats(), this.visibility = Visibility.public, this.wordCount = 0, this.readingTimeSeconds = 0, this.publishedAt}): super._();
  factory _PieceSummary.fromJson(Map<String, dynamic> json) => _$PieceSummaryFromJson(json);

@override final  String id;
@override final  String title;
@override final  Author author;
@override final  LanguageRef language;
@override final  String? slug;
@override final  String? subtitle;
@override final  String? featuredQuote;
@override final  String? coverImageKey;
@override final  GenreRef? genre;
@override@JsonKey() final  PieceSummaryStats stats;
@override@JsonKey() final  Visibility visibility;
@override@JsonKey() final  int wordCount;
@override@JsonKey() final  int readingTimeSeconds;
@override final  DateTime? publishedAt;

/// Create a copy of PieceSummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PieceSummaryCopyWith<_PieceSummary> get copyWith => __$PieceSummaryCopyWithImpl<_PieceSummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PieceSummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PieceSummary&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.author, author) || other.author == author)&&(identical(other.language, language) || other.language == language)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle)&&(identical(other.featuredQuote, featuredQuote) || other.featuredQuote == featuredQuote)&&(identical(other.coverImageKey, coverImageKey) || other.coverImageKey == coverImageKey)&&(identical(other.genre, genre) || other.genre == genre)&&(identical(other.stats, stats) || other.stats == stats)&&(identical(other.visibility, visibility) || other.visibility == visibility)&&(identical(other.wordCount, wordCount) || other.wordCount == wordCount)&&(identical(other.readingTimeSeconds, readingTimeSeconds) || other.readingTimeSeconds == readingTimeSeconds)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,author,language,slug,subtitle,featuredQuote,coverImageKey,genre,stats,visibility,wordCount,readingTimeSeconds,publishedAt);

@override
String toString() {
  return 'PieceSummary(id: $id, title: $title, author: $author, language: $language, slug: $slug, subtitle: $subtitle, featuredQuote: $featuredQuote, coverImageKey: $coverImageKey, genre: $genre, stats: $stats, visibility: $visibility, wordCount: $wordCount, readingTimeSeconds: $readingTimeSeconds, publishedAt: $publishedAt)';
}


}

/// @nodoc
abstract mixin class _$PieceSummaryCopyWith<$Res> implements $PieceSummaryCopyWith<$Res> {
  factory _$PieceSummaryCopyWith(_PieceSummary value, $Res Function(_PieceSummary) _then) = __$PieceSummaryCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, Author author, LanguageRef language, String? slug, String? subtitle, String? featuredQuote, String? coverImageKey, GenreRef? genre, PieceSummaryStats stats, Visibility visibility, int wordCount, int readingTimeSeconds, DateTime? publishedAt
});


@override $AuthorCopyWith<$Res> get author;@override $LanguageRefCopyWith<$Res> get language;@override $GenreRefCopyWith<$Res>? get genre;@override $PieceSummaryStatsCopyWith<$Res> get stats;

}
/// @nodoc
class __$PieceSummaryCopyWithImpl<$Res>
    implements _$PieceSummaryCopyWith<$Res> {
  __$PieceSummaryCopyWithImpl(this._self, this._then);

  final _PieceSummary _self;
  final $Res Function(_PieceSummary) _then;

/// Create a copy of PieceSummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? author = null,Object? language = null,Object? slug = freezed,Object? subtitle = freezed,Object? featuredQuote = freezed,Object? coverImageKey = freezed,Object? genre = freezed,Object? stats = null,Object? visibility = null,Object? wordCount = null,Object? readingTimeSeconds = null,Object? publishedAt = freezed,}) {
  return _then(_PieceSummary(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as Author,language: null == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as LanguageRef,slug: freezed == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String?,subtitle: freezed == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String?,featuredQuote: freezed == featuredQuote ? _self.featuredQuote : featuredQuote // ignore: cast_nullable_to_non_nullable
as String?,coverImageKey: freezed == coverImageKey ? _self.coverImageKey : coverImageKey // ignore: cast_nullable_to_non_nullable
as String?,genre: freezed == genre ? _self.genre : genre // ignore: cast_nullable_to_non_nullable
as GenreRef?,stats: null == stats ? _self.stats : stats // ignore: cast_nullable_to_non_nullable
as PieceSummaryStats,visibility: null == visibility ? _self.visibility : visibility // ignore: cast_nullable_to_non_nullable
as Visibility,wordCount: null == wordCount ? _self.wordCount : wordCount // ignore: cast_nullable_to_non_nullable
as int,readingTimeSeconds: null == readingTimeSeconds ? _self.readingTimeSeconds : readingTimeSeconds // ignore: cast_nullable_to_non_nullable
as int,publishedAt: freezed == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of PieceSummary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AuthorCopyWith<$Res> get author {
  
  return $AuthorCopyWith<$Res>(_self.author, (value) {
    return _then(_self.copyWith(author: value));
  });
}/// Create a copy of PieceSummary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LanguageRefCopyWith<$Res> get language {
  
  return $LanguageRefCopyWith<$Res>(_self.language, (value) {
    return _then(_self.copyWith(language: value));
  });
}/// Create a copy of PieceSummary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$GenreRefCopyWith<$Res>? get genre {
    if (_self.genre == null) {
    return null;
  }

  return $GenreRefCopyWith<$Res>(_self.genre!, (value) {
    return _then(_self.copyWith(genre: value));
  });
}/// Create a copy of PieceSummary
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$PieceSummaryStatsCopyWith<$Res> get stats {
  
  return $PieceSummaryStatsCopyWith<$Res>(_self.stats, (value) {
    return _then(_self.copyWith(stats: value));
  });
}
}

// dart format on

// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'piece_detail.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PieceDetail {

 String get id; String get title; Author get author; Map<String, dynamic> get content; String? get subtitle; String? get slug; String? get featuredQuote; String? get coverImageKey; LanguageRef? get language; GenreRef? get genre; List<TagRef> get tags; PieceStatus get status; Visibility get visibility; int get wordCount; int get readingTimeSeconds; DateTime? get publishedAt;
/// Create a copy of PieceDetail
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PieceDetailCopyWith<PieceDetail> get copyWith => _$PieceDetailCopyWithImpl<PieceDetail>(this as PieceDetail, _$identity);

  /// Serializes this PieceDetail to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PieceDetail&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.author, author) || other.author == author)&&const DeepCollectionEquality().equals(other.content, content)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.featuredQuote, featuredQuote) || other.featuredQuote == featuredQuote)&&(identical(other.coverImageKey, coverImageKey) || other.coverImageKey == coverImageKey)&&(identical(other.language, language) || other.language == language)&&(identical(other.genre, genre) || other.genre == genre)&&const DeepCollectionEquality().equals(other.tags, tags)&&(identical(other.status, status) || other.status == status)&&(identical(other.visibility, visibility) || other.visibility == visibility)&&(identical(other.wordCount, wordCount) || other.wordCount == wordCount)&&(identical(other.readingTimeSeconds, readingTimeSeconds) || other.readingTimeSeconds == readingTimeSeconds)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,author,const DeepCollectionEquality().hash(content),subtitle,slug,featuredQuote,coverImageKey,language,genre,const DeepCollectionEquality().hash(tags),status,visibility,wordCount,readingTimeSeconds,publishedAt);

@override
String toString() {
  return 'PieceDetail(id: $id, title: $title, author: $author, content: $content, subtitle: $subtitle, slug: $slug, featuredQuote: $featuredQuote, coverImageKey: $coverImageKey, language: $language, genre: $genre, tags: $tags, status: $status, visibility: $visibility, wordCount: $wordCount, readingTimeSeconds: $readingTimeSeconds, publishedAt: $publishedAt)';
}


}

/// @nodoc
abstract mixin class $PieceDetailCopyWith<$Res>  {
  factory $PieceDetailCopyWith(PieceDetail value, $Res Function(PieceDetail) _then) = _$PieceDetailCopyWithImpl;
@useResult
$Res call({
 String id, String title, Author author, Map<String, dynamic> content, String? subtitle, String? slug, String? featuredQuote, String? coverImageKey, LanguageRef? language, GenreRef? genre, List<TagRef> tags, PieceStatus status, Visibility visibility, int wordCount, int readingTimeSeconds, DateTime? publishedAt
});


$AuthorCopyWith<$Res> get author;$LanguageRefCopyWith<$Res>? get language;$GenreRefCopyWith<$Res>? get genre;

}
/// @nodoc
class _$PieceDetailCopyWithImpl<$Res>
    implements $PieceDetailCopyWith<$Res> {
  _$PieceDetailCopyWithImpl(this._self, this._then);

  final PieceDetail _self;
  final $Res Function(PieceDetail) _then;

/// Create a copy of PieceDetail
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? author = null,Object? content = null,Object? subtitle = freezed,Object? slug = freezed,Object? featuredQuote = freezed,Object? coverImageKey = freezed,Object? language = freezed,Object? genre = freezed,Object? tags = null,Object? status = null,Object? visibility = null,Object? wordCount = null,Object? readingTimeSeconds = null,Object? publishedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as Author,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,subtitle: freezed == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String?,slug: freezed == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String?,featuredQuote: freezed == featuredQuote ? _self.featuredQuote : featuredQuote // ignore: cast_nullable_to_non_nullable
as String?,coverImageKey: freezed == coverImageKey ? _self.coverImageKey : coverImageKey // ignore: cast_nullable_to_non_nullable
as String?,language: freezed == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as LanguageRef?,genre: freezed == genre ? _self.genre : genre // ignore: cast_nullable_to_non_nullable
as GenreRef?,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<TagRef>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PieceStatus,visibility: null == visibility ? _self.visibility : visibility // ignore: cast_nullable_to_non_nullable
as Visibility,wordCount: null == wordCount ? _self.wordCount : wordCount // ignore: cast_nullable_to_non_nullable
as int,readingTimeSeconds: null == readingTimeSeconds ? _self.readingTimeSeconds : readingTimeSeconds // ignore: cast_nullable_to_non_nullable
as int,publishedAt: freezed == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of PieceDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AuthorCopyWith<$Res> get author {
  
  return $AuthorCopyWith<$Res>(_self.author, (value) {
    return _then(_self.copyWith(author: value));
  });
}/// Create a copy of PieceDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LanguageRefCopyWith<$Res>? get language {
    if (_self.language == null) {
    return null;
  }

  return $LanguageRefCopyWith<$Res>(_self.language!, (value) {
    return _then(_self.copyWith(language: value));
  });
}/// Create a copy of PieceDetail
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
}
}


/// Adds pattern-matching-related methods to [PieceDetail].
extension PieceDetailPatterns on PieceDetail {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PieceDetail value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PieceDetail() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PieceDetail value)  $default,){
final _that = this;
switch (_that) {
case _PieceDetail():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PieceDetail value)?  $default,){
final _that = this;
switch (_that) {
case _PieceDetail() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String title,  Author author,  Map<String, dynamic> content,  String? subtitle,  String? slug,  String? featuredQuote,  String? coverImageKey,  LanguageRef? language,  GenreRef? genre,  List<TagRef> tags,  PieceStatus status,  Visibility visibility,  int wordCount,  int readingTimeSeconds,  DateTime? publishedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PieceDetail() when $default != null:
return $default(_that.id,_that.title,_that.author,_that.content,_that.subtitle,_that.slug,_that.featuredQuote,_that.coverImageKey,_that.language,_that.genre,_that.tags,_that.status,_that.visibility,_that.wordCount,_that.readingTimeSeconds,_that.publishedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String title,  Author author,  Map<String, dynamic> content,  String? subtitle,  String? slug,  String? featuredQuote,  String? coverImageKey,  LanguageRef? language,  GenreRef? genre,  List<TagRef> tags,  PieceStatus status,  Visibility visibility,  int wordCount,  int readingTimeSeconds,  DateTime? publishedAt)  $default,) {final _that = this;
switch (_that) {
case _PieceDetail():
return $default(_that.id,_that.title,_that.author,_that.content,_that.subtitle,_that.slug,_that.featuredQuote,_that.coverImageKey,_that.language,_that.genre,_that.tags,_that.status,_that.visibility,_that.wordCount,_that.readingTimeSeconds,_that.publishedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String title,  Author author,  Map<String, dynamic> content,  String? subtitle,  String? slug,  String? featuredQuote,  String? coverImageKey,  LanguageRef? language,  GenreRef? genre,  List<TagRef> tags,  PieceStatus status,  Visibility visibility,  int wordCount,  int readingTimeSeconds,  DateTime? publishedAt)?  $default,) {final _that = this;
switch (_that) {
case _PieceDetail() when $default != null:
return $default(_that.id,_that.title,_that.author,_that.content,_that.subtitle,_that.slug,_that.featuredQuote,_that.coverImageKey,_that.language,_that.genre,_that.tags,_that.status,_that.visibility,_that.wordCount,_that.readingTimeSeconds,_that.publishedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PieceDetail extends PieceDetail {
  const _PieceDetail({required this.id, required this.title, required this.author, final  Map<String, dynamic> content = const <String, dynamic>{}, this.subtitle, this.slug, this.featuredQuote, this.coverImageKey, this.language, this.genre, final  List<TagRef> tags = const <TagRef>[], this.status = PieceStatus.published, this.visibility = Visibility.public, this.wordCount = 0, this.readingTimeSeconds = 0, this.publishedAt}): _content = content,_tags = tags,super._();
  factory _PieceDetail.fromJson(Map<String, dynamic> json) => _$PieceDetailFromJson(json);

@override final  String id;
@override final  String title;
@override final  Author author;
 final  Map<String, dynamic> _content;
@override@JsonKey() Map<String, dynamic> get content {
  if (_content is EqualUnmodifiableMapView) return _content;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_content);
}

@override final  String? subtitle;
@override final  String? slug;
@override final  String? featuredQuote;
@override final  String? coverImageKey;
@override final  LanguageRef? language;
@override final  GenreRef? genre;
 final  List<TagRef> _tags;
@override@JsonKey() List<TagRef> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

@override@JsonKey() final  PieceStatus status;
@override@JsonKey() final  Visibility visibility;
@override@JsonKey() final  int wordCount;
@override@JsonKey() final  int readingTimeSeconds;
@override final  DateTime? publishedAt;

/// Create a copy of PieceDetail
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PieceDetailCopyWith<_PieceDetail> get copyWith => __$PieceDetailCopyWithImpl<_PieceDetail>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PieceDetailToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PieceDetail&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.author, author) || other.author == author)&&const DeepCollectionEquality().equals(other._content, _content)&&(identical(other.subtitle, subtitle) || other.subtitle == subtitle)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.featuredQuote, featuredQuote) || other.featuredQuote == featuredQuote)&&(identical(other.coverImageKey, coverImageKey) || other.coverImageKey == coverImageKey)&&(identical(other.language, language) || other.language == language)&&(identical(other.genre, genre) || other.genre == genre)&&const DeepCollectionEquality().equals(other._tags, _tags)&&(identical(other.status, status) || other.status == status)&&(identical(other.visibility, visibility) || other.visibility == visibility)&&(identical(other.wordCount, wordCount) || other.wordCount == wordCount)&&(identical(other.readingTimeSeconds, readingTimeSeconds) || other.readingTimeSeconds == readingTimeSeconds)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,author,const DeepCollectionEquality().hash(_content),subtitle,slug,featuredQuote,coverImageKey,language,genre,const DeepCollectionEquality().hash(_tags),status,visibility,wordCount,readingTimeSeconds,publishedAt);

@override
String toString() {
  return 'PieceDetail(id: $id, title: $title, author: $author, content: $content, subtitle: $subtitle, slug: $slug, featuredQuote: $featuredQuote, coverImageKey: $coverImageKey, language: $language, genre: $genre, tags: $tags, status: $status, visibility: $visibility, wordCount: $wordCount, readingTimeSeconds: $readingTimeSeconds, publishedAt: $publishedAt)';
}


}

/// @nodoc
abstract mixin class _$PieceDetailCopyWith<$Res> implements $PieceDetailCopyWith<$Res> {
  factory _$PieceDetailCopyWith(_PieceDetail value, $Res Function(_PieceDetail) _then) = __$PieceDetailCopyWithImpl;
@override @useResult
$Res call({
 String id, String title, Author author, Map<String, dynamic> content, String? subtitle, String? slug, String? featuredQuote, String? coverImageKey, LanguageRef? language, GenreRef? genre, List<TagRef> tags, PieceStatus status, Visibility visibility, int wordCount, int readingTimeSeconds, DateTime? publishedAt
});


@override $AuthorCopyWith<$Res> get author;@override $LanguageRefCopyWith<$Res>? get language;@override $GenreRefCopyWith<$Res>? get genre;

}
/// @nodoc
class __$PieceDetailCopyWithImpl<$Res>
    implements _$PieceDetailCopyWith<$Res> {
  __$PieceDetailCopyWithImpl(this._self, this._then);

  final _PieceDetail _self;
  final $Res Function(_PieceDetail) _then;

/// Create a copy of PieceDetail
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? author = null,Object? content = null,Object? subtitle = freezed,Object? slug = freezed,Object? featuredQuote = freezed,Object? coverImageKey = freezed,Object? language = freezed,Object? genre = freezed,Object? tags = null,Object? status = null,Object? visibility = null,Object? wordCount = null,Object? readingTimeSeconds = null,Object? publishedAt = freezed,}) {
  return _then(_PieceDetail(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,author: null == author ? _self.author : author // ignore: cast_nullable_to_non_nullable
as Author,content: null == content ? _self._content : content // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,subtitle: freezed == subtitle ? _self.subtitle : subtitle // ignore: cast_nullable_to_non_nullable
as String?,slug: freezed == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String?,featuredQuote: freezed == featuredQuote ? _self.featuredQuote : featuredQuote // ignore: cast_nullable_to_non_nullable
as String?,coverImageKey: freezed == coverImageKey ? _self.coverImageKey : coverImageKey // ignore: cast_nullable_to_non_nullable
as String?,language: freezed == language ? _self.language : language // ignore: cast_nullable_to_non_nullable
as LanguageRef?,genre: freezed == genre ? _self.genre : genre // ignore: cast_nullable_to_non_nullable
as GenreRef?,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<TagRef>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as PieceStatus,visibility: null == visibility ? _self.visibility : visibility // ignore: cast_nullable_to_non_nullable
as Visibility,wordCount: null == wordCount ? _self.wordCount : wordCount // ignore: cast_nullable_to_non_nullable
as int,readingTimeSeconds: null == readingTimeSeconds ? _self.readingTimeSeconds : readingTimeSeconds // ignore: cast_nullable_to_non_nullable
as int,publishedAt: freezed == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of PieceDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AuthorCopyWith<$Res> get author {
  
  return $AuthorCopyWith<$Res>(_self.author, (value) {
    return _then(_self.copyWith(author: value));
  });
}/// Create a copy of PieceDetail
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LanguageRefCopyWith<$Res>? get language {
    if (_self.language == null) {
    return null;
  }

  return $LanguageRefCopyWith<$Res>(_self.language!, (value) {
    return _then(_self.copyWith(language: value));
  });
}/// Create a copy of PieceDetail
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
}
}

// dart format on

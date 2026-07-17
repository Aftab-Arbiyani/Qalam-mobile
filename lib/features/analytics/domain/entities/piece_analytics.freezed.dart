// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'piece_analytics.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PieceAnalytics {

 String get pieceId; int get views; int get uniqueViews; int get reads;/// Completed reads ÷ views, 0.0–1.0.
 double get completionRate; int get averageReadTimeSeconds; int get claps; int get comments; int get responses; int get bookmarks; int get shares; ReadingSources get readingSources; String? get publishedAt;
/// Create a copy of PieceAnalytics
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PieceAnalyticsCopyWith<PieceAnalytics> get copyWith => _$PieceAnalyticsCopyWithImpl<PieceAnalytics>(this as PieceAnalytics, _$identity);

  /// Serializes this PieceAnalytics to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PieceAnalytics&&(identical(other.pieceId, pieceId) || other.pieceId == pieceId)&&(identical(other.views, views) || other.views == views)&&(identical(other.uniqueViews, uniqueViews) || other.uniqueViews == uniqueViews)&&(identical(other.reads, reads) || other.reads == reads)&&(identical(other.completionRate, completionRate) || other.completionRate == completionRate)&&(identical(other.averageReadTimeSeconds, averageReadTimeSeconds) || other.averageReadTimeSeconds == averageReadTimeSeconds)&&(identical(other.claps, claps) || other.claps == claps)&&(identical(other.comments, comments) || other.comments == comments)&&(identical(other.responses, responses) || other.responses == responses)&&(identical(other.bookmarks, bookmarks) || other.bookmarks == bookmarks)&&(identical(other.shares, shares) || other.shares == shares)&&(identical(other.readingSources, readingSources) || other.readingSources == readingSources)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,pieceId,views,uniqueViews,reads,completionRate,averageReadTimeSeconds,claps,comments,responses,bookmarks,shares,readingSources,publishedAt);

@override
String toString() {
  return 'PieceAnalytics(pieceId: $pieceId, views: $views, uniqueViews: $uniqueViews, reads: $reads, completionRate: $completionRate, averageReadTimeSeconds: $averageReadTimeSeconds, claps: $claps, comments: $comments, responses: $responses, bookmarks: $bookmarks, shares: $shares, readingSources: $readingSources, publishedAt: $publishedAt)';
}


}

/// @nodoc
abstract mixin class $PieceAnalyticsCopyWith<$Res>  {
  factory $PieceAnalyticsCopyWith(PieceAnalytics value, $Res Function(PieceAnalytics) _then) = _$PieceAnalyticsCopyWithImpl;
@useResult
$Res call({
 String pieceId, int views, int uniqueViews, int reads, double completionRate, int averageReadTimeSeconds, int claps, int comments, int responses, int bookmarks, int shares, ReadingSources readingSources, String? publishedAt
});


$ReadingSourcesCopyWith<$Res> get readingSources;

}
/// @nodoc
class _$PieceAnalyticsCopyWithImpl<$Res>
    implements $PieceAnalyticsCopyWith<$Res> {
  _$PieceAnalyticsCopyWithImpl(this._self, this._then);

  final PieceAnalytics _self;
  final $Res Function(PieceAnalytics) _then;

/// Create a copy of PieceAnalytics
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? pieceId = null,Object? views = null,Object? uniqueViews = null,Object? reads = null,Object? completionRate = null,Object? averageReadTimeSeconds = null,Object? claps = null,Object? comments = null,Object? responses = null,Object? bookmarks = null,Object? shares = null,Object? readingSources = null,Object? publishedAt = freezed,}) {
  return _then(_self.copyWith(
pieceId: null == pieceId ? _self.pieceId : pieceId // ignore: cast_nullable_to_non_nullable
as String,views: null == views ? _self.views : views // ignore: cast_nullable_to_non_nullable
as int,uniqueViews: null == uniqueViews ? _self.uniqueViews : uniqueViews // ignore: cast_nullable_to_non_nullable
as int,reads: null == reads ? _self.reads : reads // ignore: cast_nullable_to_non_nullable
as int,completionRate: null == completionRate ? _self.completionRate : completionRate // ignore: cast_nullable_to_non_nullable
as double,averageReadTimeSeconds: null == averageReadTimeSeconds ? _self.averageReadTimeSeconds : averageReadTimeSeconds // ignore: cast_nullable_to_non_nullable
as int,claps: null == claps ? _self.claps : claps // ignore: cast_nullable_to_non_nullable
as int,comments: null == comments ? _self.comments : comments // ignore: cast_nullable_to_non_nullable
as int,responses: null == responses ? _self.responses : responses // ignore: cast_nullable_to_non_nullable
as int,bookmarks: null == bookmarks ? _self.bookmarks : bookmarks // ignore: cast_nullable_to_non_nullable
as int,shares: null == shares ? _self.shares : shares // ignore: cast_nullable_to_non_nullable
as int,readingSources: null == readingSources ? _self.readingSources : readingSources // ignore: cast_nullable_to_non_nullable
as ReadingSources,publishedAt: freezed == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of PieceAnalytics
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReadingSourcesCopyWith<$Res> get readingSources {
  
  return $ReadingSourcesCopyWith<$Res>(_self.readingSources, (value) {
    return _then(_self.copyWith(readingSources: value));
  });
}
}


/// Adds pattern-matching-related methods to [PieceAnalytics].
extension PieceAnalyticsPatterns on PieceAnalytics {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PieceAnalytics value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PieceAnalytics() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PieceAnalytics value)  $default,){
final _that = this;
switch (_that) {
case _PieceAnalytics():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PieceAnalytics value)?  $default,){
final _that = this;
switch (_that) {
case _PieceAnalytics() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String pieceId,  int views,  int uniqueViews,  int reads,  double completionRate,  int averageReadTimeSeconds,  int claps,  int comments,  int responses,  int bookmarks,  int shares,  ReadingSources readingSources,  String? publishedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PieceAnalytics() when $default != null:
return $default(_that.pieceId,_that.views,_that.uniqueViews,_that.reads,_that.completionRate,_that.averageReadTimeSeconds,_that.claps,_that.comments,_that.responses,_that.bookmarks,_that.shares,_that.readingSources,_that.publishedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String pieceId,  int views,  int uniqueViews,  int reads,  double completionRate,  int averageReadTimeSeconds,  int claps,  int comments,  int responses,  int bookmarks,  int shares,  ReadingSources readingSources,  String? publishedAt)  $default,) {final _that = this;
switch (_that) {
case _PieceAnalytics():
return $default(_that.pieceId,_that.views,_that.uniqueViews,_that.reads,_that.completionRate,_that.averageReadTimeSeconds,_that.claps,_that.comments,_that.responses,_that.bookmarks,_that.shares,_that.readingSources,_that.publishedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String pieceId,  int views,  int uniqueViews,  int reads,  double completionRate,  int averageReadTimeSeconds,  int claps,  int comments,  int responses,  int bookmarks,  int shares,  ReadingSources readingSources,  String? publishedAt)?  $default,) {final _that = this;
switch (_that) {
case _PieceAnalytics() when $default != null:
return $default(_that.pieceId,_that.views,_that.uniqueViews,_that.reads,_that.completionRate,_that.averageReadTimeSeconds,_that.claps,_that.comments,_that.responses,_that.bookmarks,_that.shares,_that.readingSources,_that.publishedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PieceAnalytics implements PieceAnalytics {
  const _PieceAnalytics({this.pieceId = '', this.views = 0, this.uniqueViews = 0, this.reads = 0, this.completionRate = 0, this.averageReadTimeSeconds = 0, this.claps = 0, this.comments = 0, this.responses = 0, this.bookmarks = 0, this.shares = 0, this.readingSources = const ReadingSources(), this.publishedAt});
  factory _PieceAnalytics.fromJson(Map<String, dynamic> json) => _$PieceAnalyticsFromJson(json);

@override@JsonKey() final  String pieceId;
@override@JsonKey() final  int views;
@override@JsonKey() final  int uniqueViews;
@override@JsonKey() final  int reads;
/// Completed reads ÷ views, 0.0–1.0.
@override@JsonKey() final  double completionRate;
@override@JsonKey() final  int averageReadTimeSeconds;
@override@JsonKey() final  int claps;
@override@JsonKey() final  int comments;
@override@JsonKey() final  int responses;
@override@JsonKey() final  int bookmarks;
@override@JsonKey() final  int shares;
@override@JsonKey() final  ReadingSources readingSources;
@override final  String? publishedAt;

/// Create a copy of PieceAnalytics
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PieceAnalyticsCopyWith<_PieceAnalytics> get copyWith => __$PieceAnalyticsCopyWithImpl<_PieceAnalytics>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PieceAnalyticsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PieceAnalytics&&(identical(other.pieceId, pieceId) || other.pieceId == pieceId)&&(identical(other.views, views) || other.views == views)&&(identical(other.uniqueViews, uniqueViews) || other.uniqueViews == uniqueViews)&&(identical(other.reads, reads) || other.reads == reads)&&(identical(other.completionRate, completionRate) || other.completionRate == completionRate)&&(identical(other.averageReadTimeSeconds, averageReadTimeSeconds) || other.averageReadTimeSeconds == averageReadTimeSeconds)&&(identical(other.claps, claps) || other.claps == claps)&&(identical(other.comments, comments) || other.comments == comments)&&(identical(other.responses, responses) || other.responses == responses)&&(identical(other.bookmarks, bookmarks) || other.bookmarks == bookmarks)&&(identical(other.shares, shares) || other.shares == shares)&&(identical(other.readingSources, readingSources) || other.readingSources == readingSources)&&(identical(other.publishedAt, publishedAt) || other.publishedAt == publishedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,pieceId,views,uniqueViews,reads,completionRate,averageReadTimeSeconds,claps,comments,responses,bookmarks,shares,readingSources,publishedAt);

@override
String toString() {
  return 'PieceAnalytics(pieceId: $pieceId, views: $views, uniqueViews: $uniqueViews, reads: $reads, completionRate: $completionRate, averageReadTimeSeconds: $averageReadTimeSeconds, claps: $claps, comments: $comments, responses: $responses, bookmarks: $bookmarks, shares: $shares, readingSources: $readingSources, publishedAt: $publishedAt)';
}


}

/// @nodoc
abstract mixin class _$PieceAnalyticsCopyWith<$Res> implements $PieceAnalyticsCopyWith<$Res> {
  factory _$PieceAnalyticsCopyWith(_PieceAnalytics value, $Res Function(_PieceAnalytics) _then) = __$PieceAnalyticsCopyWithImpl;
@override @useResult
$Res call({
 String pieceId, int views, int uniqueViews, int reads, double completionRate, int averageReadTimeSeconds, int claps, int comments, int responses, int bookmarks, int shares, ReadingSources readingSources, String? publishedAt
});


@override $ReadingSourcesCopyWith<$Res> get readingSources;

}
/// @nodoc
class __$PieceAnalyticsCopyWithImpl<$Res>
    implements _$PieceAnalyticsCopyWith<$Res> {
  __$PieceAnalyticsCopyWithImpl(this._self, this._then);

  final _PieceAnalytics _self;
  final $Res Function(_PieceAnalytics) _then;

/// Create a copy of PieceAnalytics
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? pieceId = null,Object? views = null,Object? uniqueViews = null,Object? reads = null,Object? completionRate = null,Object? averageReadTimeSeconds = null,Object? claps = null,Object? comments = null,Object? responses = null,Object? bookmarks = null,Object? shares = null,Object? readingSources = null,Object? publishedAt = freezed,}) {
  return _then(_PieceAnalytics(
pieceId: null == pieceId ? _self.pieceId : pieceId // ignore: cast_nullable_to_non_nullable
as String,views: null == views ? _self.views : views // ignore: cast_nullable_to_non_nullable
as int,uniqueViews: null == uniqueViews ? _self.uniqueViews : uniqueViews // ignore: cast_nullable_to_non_nullable
as int,reads: null == reads ? _self.reads : reads // ignore: cast_nullable_to_non_nullable
as int,completionRate: null == completionRate ? _self.completionRate : completionRate // ignore: cast_nullable_to_non_nullable
as double,averageReadTimeSeconds: null == averageReadTimeSeconds ? _self.averageReadTimeSeconds : averageReadTimeSeconds // ignore: cast_nullable_to_non_nullable
as int,claps: null == claps ? _self.claps : claps // ignore: cast_nullable_to_non_nullable
as int,comments: null == comments ? _self.comments : comments // ignore: cast_nullable_to_non_nullable
as int,responses: null == responses ? _self.responses : responses // ignore: cast_nullable_to_non_nullable
as int,bookmarks: null == bookmarks ? _self.bookmarks : bookmarks // ignore: cast_nullable_to_non_nullable
as int,shares: null == shares ? _self.shares : shares // ignore: cast_nullable_to_non_nullable
as int,readingSources: null == readingSources ? _self.readingSources : readingSources // ignore: cast_nullable_to_non_nullable
as ReadingSources,publishedAt: freezed == publishedAt ? _self.publishedAt : publishedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of PieceAnalytics
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ReadingSourcesCopyWith<$Res> get readingSources {
  
  return $ReadingSourcesCopyWith<$Res>(_self.readingSources, (value) {
    return _then(_self.copyWith(readingSources: value));
  });
}
}


/// @nodoc
mixin _$ReadingSources {

 int get internal; int get external; int get copyLink;
/// Create a copy of ReadingSources
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReadingSourcesCopyWith<ReadingSources> get copyWith => _$ReadingSourcesCopyWithImpl<ReadingSources>(this as ReadingSources, _$identity);

  /// Serializes this ReadingSources to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReadingSources&&(identical(other.internal, internal) || other.internal == internal)&&(identical(other.external, external) || other.external == external)&&(identical(other.copyLink, copyLink) || other.copyLink == copyLink));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,internal,external,copyLink);

@override
String toString() {
  return 'ReadingSources(internal: $internal, external: $external, copyLink: $copyLink)';
}


}

/// @nodoc
abstract mixin class $ReadingSourcesCopyWith<$Res>  {
  factory $ReadingSourcesCopyWith(ReadingSources value, $Res Function(ReadingSources) _then) = _$ReadingSourcesCopyWithImpl;
@useResult
$Res call({
 int internal, int external, int copyLink
});




}
/// @nodoc
class _$ReadingSourcesCopyWithImpl<$Res>
    implements $ReadingSourcesCopyWith<$Res> {
  _$ReadingSourcesCopyWithImpl(this._self, this._then);

  final ReadingSources _self;
  final $Res Function(ReadingSources) _then;

/// Create a copy of ReadingSources
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? internal = null,Object? external = null,Object? copyLink = null,}) {
  return _then(_self.copyWith(
internal: null == internal ? _self.internal : internal // ignore: cast_nullable_to_non_nullable
as int,external: null == external ? _self.external : external // ignore: cast_nullable_to_non_nullable
as int,copyLink: null == copyLink ? _self.copyLink : copyLink // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ReadingSources].
extension ReadingSourcesPatterns on ReadingSources {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReadingSources value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReadingSources() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReadingSources value)  $default,){
final _that = this;
switch (_that) {
case _ReadingSources():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReadingSources value)?  $default,){
final _that = this;
switch (_that) {
case _ReadingSources() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int internal,  int external,  int copyLink)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReadingSources() when $default != null:
return $default(_that.internal,_that.external,_that.copyLink);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int internal,  int external,  int copyLink)  $default,) {final _that = this;
switch (_that) {
case _ReadingSources():
return $default(_that.internal,_that.external,_that.copyLink);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int internal,  int external,  int copyLink)?  $default,) {final _that = this;
switch (_that) {
case _ReadingSources() when $default != null:
return $default(_that.internal,_that.external,_that.copyLink);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReadingSources implements ReadingSources {
  const _ReadingSources({this.internal = 0, this.external = 0, this.copyLink = 0});
  factory _ReadingSources.fromJson(Map<String, dynamic> json) => _$ReadingSourcesFromJson(json);

@override@JsonKey() final  int internal;
@override@JsonKey() final  int external;
@override@JsonKey() final  int copyLink;

/// Create a copy of ReadingSources
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReadingSourcesCopyWith<_ReadingSources> get copyWith => __$ReadingSourcesCopyWithImpl<_ReadingSources>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReadingSourcesToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReadingSources&&(identical(other.internal, internal) || other.internal == internal)&&(identical(other.external, external) || other.external == external)&&(identical(other.copyLink, copyLink) || other.copyLink == copyLink));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,internal,external,copyLink);

@override
String toString() {
  return 'ReadingSources(internal: $internal, external: $external, copyLink: $copyLink)';
}


}

/// @nodoc
abstract mixin class _$ReadingSourcesCopyWith<$Res> implements $ReadingSourcesCopyWith<$Res> {
  factory _$ReadingSourcesCopyWith(_ReadingSources value, $Res Function(_ReadingSources) _then) = __$ReadingSourcesCopyWithImpl;
@override @useResult
$Res call({
 int internal, int external, int copyLink
});




}
/// @nodoc
class __$ReadingSourcesCopyWithImpl<$Res>
    implements _$ReadingSourcesCopyWith<$Res> {
  __$ReadingSourcesCopyWithImpl(this._self, this._then);

  final _ReadingSources _self;
  final $Res Function(_ReadingSources) _then;

/// Create a copy of ReadingSources
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? internal = null,Object? external = null,Object? copyLink = null,}) {
  return _then(_ReadingSources(
internal: null == internal ? _self.internal : internal // ignore: cast_nullable_to_non_nullable
as int,external: null == external ? _self.external : external // ignore: cast_nullable_to_non_nullable
as int,copyLink: null == copyLink ? _self.copyLink : copyLink // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on

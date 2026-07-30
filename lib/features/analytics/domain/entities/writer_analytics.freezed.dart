// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'writer_analytics.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WriterAnalytics {

 int get totalViews; int get uniqueViews; int get reads;/// Completed reads ÷ views, 0.0–1.0.
 double get completionRate; int get totalReadSeconds; int get averageReadTimeSeconds; int get followersGained; int get piecesPublished; int get piecesArchived; int get commentsReceived; int get clapsReceived; int get bookmarksReceived; int get responsesReceived; MostPopularPiece? get mostPopularPiece;
/// Create a copy of WriterAnalytics
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WriterAnalyticsCopyWith<WriterAnalytics> get copyWith => _$WriterAnalyticsCopyWithImpl<WriterAnalytics>(this as WriterAnalytics, _$identity);

  /// Serializes this WriterAnalytics to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WriterAnalytics&&(identical(other.totalViews, totalViews) || other.totalViews == totalViews)&&(identical(other.uniqueViews, uniqueViews) || other.uniqueViews == uniqueViews)&&(identical(other.reads, reads) || other.reads == reads)&&(identical(other.completionRate, completionRate) || other.completionRate == completionRate)&&(identical(other.totalReadSeconds, totalReadSeconds) || other.totalReadSeconds == totalReadSeconds)&&(identical(other.averageReadTimeSeconds, averageReadTimeSeconds) || other.averageReadTimeSeconds == averageReadTimeSeconds)&&(identical(other.followersGained, followersGained) || other.followersGained == followersGained)&&(identical(other.piecesPublished, piecesPublished) || other.piecesPublished == piecesPublished)&&(identical(other.piecesArchived, piecesArchived) || other.piecesArchived == piecesArchived)&&(identical(other.commentsReceived, commentsReceived) || other.commentsReceived == commentsReceived)&&(identical(other.clapsReceived, clapsReceived) || other.clapsReceived == clapsReceived)&&(identical(other.bookmarksReceived, bookmarksReceived) || other.bookmarksReceived == bookmarksReceived)&&(identical(other.responsesReceived, responsesReceived) || other.responsesReceived == responsesReceived)&&(identical(other.mostPopularPiece, mostPopularPiece) || other.mostPopularPiece == mostPopularPiece));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalViews,uniqueViews,reads,completionRate,totalReadSeconds,averageReadTimeSeconds,followersGained,piecesPublished,piecesArchived,commentsReceived,clapsReceived,bookmarksReceived,responsesReceived,mostPopularPiece);

@override
String toString() {
  return 'WriterAnalytics(totalViews: $totalViews, uniqueViews: $uniqueViews, reads: $reads, completionRate: $completionRate, totalReadSeconds: $totalReadSeconds, averageReadTimeSeconds: $averageReadTimeSeconds, followersGained: $followersGained, piecesPublished: $piecesPublished, piecesArchived: $piecesArchived, commentsReceived: $commentsReceived, clapsReceived: $clapsReceived, bookmarksReceived: $bookmarksReceived, responsesReceived: $responsesReceived, mostPopularPiece: $mostPopularPiece)';
}


}

/// @nodoc
abstract mixin class $WriterAnalyticsCopyWith<$Res>  {
  factory $WriterAnalyticsCopyWith(WriterAnalytics value, $Res Function(WriterAnalytics) _then) = _$WriterAnalyticsCopyWithImpl;
@useResult
$Res call({
 int totalViews, int uniqueViews, int reads, double completionRate, int totalReadSeconds, int averageReadTimeSeconds, int followersGained, int piecesPublished, int piecesArchived, int commentsReceived, int clapsReceived, int bookmarksReceived, int responsesReceived, MostPopularPiece? mostPopularPiece
});


$MostPopularPieceCopyWith<$Res>? get mostPopularPiece;

}
/// @nodoc
class _$WriterAnalyticsCopyWithImpl<$Res>
    implements $WriterAnalyticsCopyWith<$Res> {
  _$WriterAnalyticsCopyWithImpl(this._self, this._then);

  final WriterAnalytics _self;
  final $Res Function(WriterAnalytics) _then;

/// Create a copy of WriterAnalytics
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalViews = null,Object? uniqueViews = null,Object? reads = null,Object? completionRate = null,Object? totalReadSeconds = null,Object? averageReadTimeSeconds = null,Object? followersGained = null,Object? piecesPublished = null,Object? piecesArchived = null,Object? commentsReceived = null,Object? clapsReceived = null,Object? bookmarksReceived = null,Object? responsesReceived = null,Object? mostPopularPiece = freezed,}) {
  return _then(_self.copyWith(
totalViews: null == totalViews ? _self.totalViews : totalViews // ignore: cast_nullable_to_non_nullable
as int,uniqueViews: null == uniqueViews ? _self.uniqueViews : uniqueViews // ignore: cast_nullable_to_non_nullable
as int,reads: null == reads ? _self.reads : reads // ignore: cast_nullable_to_non_nullable
as int,completionRate: null == completionRate ? _self.completionRate : completionRate // ignore: cast_nullable_to_non_nullable
as double,totalReadSeconds: null == totalReadSeconds ? _self.totalReadSeconds : totalReadSeconds // ignore: cast_nullable_to_non_nullable
as int,averageReadTimeSeconds: null == averageReadTimeSeconds ? _self.averageReadTimeSeconds : averageReadTimeSeconds // ignore: cast_nullable_to_non_nullable
as int,followersGained: null == followersGained ? _self.followersGained : followersGained // ignore: cast_nullable_to_non_nullable
as int,piecesPublished: null == piecesPublished ? _self.piecesPublished : piecesPublished // ignore: cast_nullable_to_non_nullable
as int,piecesArchived: null == piecesArchived ? _self.piecesArchived : piecesArchived // ignore: cast_nullable_to_non_nullable
as int,commentsReceived: null == commentsReceived ? _self.commentsReceived : commentsReceived // ignore: cast_nullable_to_non_nullable
as int,clapsReceived: null == clapsReceived ? _self.clapsReceived : clapsReceived // ignore: cast_nullable_to_non_nullable
as int,bookmarksReceived: null == bookmarksReceived ? _self.bookmarksReceived : bookmarksReceived // ignore: cast_nullable_to_non_nullable
as int,responsesReceived: null == responsesReceived ? _self.responsesReceived : responsesReceived // ignore: cast_nullable_to_non_nullable
as int,mostPopularPiece: freezed == mostPopularPiece ? _self.mostPopularPiece : mostPopularPiece // ignore: cast_nullable_to_non_nullable
as MostPopularPiece?,
  ));
}
/// Create a copy of WriterAnalytics
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MostPopularPieceCopyWith<$Res>? get mostPopularPiece {
    if (_self.mostPopularPiece == null) {
    return null;
  }

  return $MostPopularPieceCopyWith<$Res>(_self.mostPopularPiece!, (value) {
    return _then(_self.copyWith(mostPopularPiece: value));
  });
}
}


/// Adds pattern-matching-related methods to [WriterAnalytics].
extension WriterAnalyticsPatterns on WriterAnalytics {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WriterAnalytics value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WriterAnalytics() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WriterAnalytics value)  $default,){
final _that = this;
switch (_that) {
case _WriterAnalytics():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WriterAnalytics value)?  $default,){
final _that = this;
switch (_that) {
case _WriterAnalytics() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int totalViews,  int uniqueViews,  int reads,  double completionRate,  int totalReadSeconds,  int averageReadTimeSeconds,  int followersGained,  int piecesPublished,  int piecesArchived,  int commentsReceived,  int clapsReceived,  int bookmarksReceived,  int responsesReceived,  MostPopularPiece? mostPopularPiece)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WriterAnalytics() when $default != null:
return $default(_that.totalViews,_that.uniqueViews,_that.reads,_that.completionRate,_that.totalReadSeconds,_that.averageReadTimeSeconds,_that.followersGained,_that.piecesPublished,_that.piecesArchived,_that.commentsReceived,_that.clapsReceived,_that.bookmarksReceived,_that.responsesReceived,_that.mostPopularPiece);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int totalViews,  int uniqueViews,  int reads,  double completionRate,  int totalReadSeconds,  int averageReadTimeSeconds,  int followersGained,  int piecesPublished,  int piecesArchived,  int commentsReceived,  int clapsReceived,  int bookmarksReceived,  int responsesReceived,  MostPopularPiece? mostPopularPiece)  $default,) {final _that = this;
switch (_that) {
case _WriterAnalytics():
return $default(_that.totalViews,_that.uniqueViews,_that.reads,_that.completionRate,_that.totalReadSeconds,_that.averageReadTimeSeconds,_that.followersGained,_that.piecesPublished,_that.piecesArchived,_that.commentsReceived,_that.clapsReceived,_that.bookmarksReceived,_that.responsesReceived,_that.mostPopularPiece);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int totalViews,  int uniqueViews,  int reads,  double completionRate,  int totalReadSeconds,  int averageReadTimeSeconds,  int followersGained,  int piecesPublished,  int piecesArchived,  int commentsReceived,  int clapsReceived,  int bookmarksReceived,  int responsesReceived,  MostPopularPiece? mostPopularPiece)?  $default,) {final _that = this;
switch (_that) {
case _WriterAnalytics() when $default != null:
return $default(_that.totalViews,_that.uniqueViews,_that.reads,_that.completionRate,_that.totalReadSeconds,_that.averageReadTimeSeconds,_that.followersGained,_that.piecesPublished,_that.piecesArchived,_that.commentsReceived,_that.clapsReceived,_that.bookmarksReceived,_that.responsesReceived,_that.mostPopularPiece);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WriterAnalytics implements WriterAnalytics {
  const _WriterAnalytics({this.totalViews = 0, this.uniqueViews = 0, this.reads = 0, this.completionRate = 0, this.totalReadSeconds = 0, this.averageReadTimeSeconds = 0, this.followersGained = 0, this.piecesPublished = 0, this.piecesArchived = 0, this.commentsReceived = 0, this.clapsReceived = 0, this.bookmarksReceived = 0, this.responsesReceived = 0, this.mostPopularPiece});
  factory _WriterAnalytics.fromJson(Map<String, dynamic> json) => _$WriterAnalyticsFromJson(json);

@override@JsonKey() final  int totalViews;
@override@JsonKey() final  int uniqueViews;
@override@JsonKey() final  int reads;
/// Completed reads ÷ views, 0.0–1.0.
@override@JsonKey() final  double completionRate;
@override@JsonKey() final  int totalReadSeconds;
@override@JsonKey() final  int averageReadTimeSeconds;
@override@JsonKey() final  int followersGained;
@override@JsonKey() final  int piecesPublished;
@override@JsonKey() final  int piecesArchived;
@override@JsonKey() final  int commentsReceived;
@override@JsonKey() final  int clapsReceived;
@override@JsonKey() final  int bookmarksReceived;
@override@JsonKey() final  int responsesReceived;
@override final  MostPopularPiece? mostPopularPiece;

/// Create a copy of WriterAnalytics
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WriterAnalyticsCopyWith<_WriterAnalytics> get copyWith => __$WriterAnalyticsCopyWithImpl<_WriterAnalytics>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WriterAnalyticsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WriterAnalytics&&(identical(other.totalViews, totalViews) || other.totalViews == totalViews)&&(identical(other.uniqueViews, uniqueViews) || other.uniqueViews == uniqueViews)&&(identical(other.reads, reads) || other.reads == reads)&&(identical(other.completionRate, completionRate) || other.completionRate == completionRate)&&(identical(other.totalReadSeconds, totalReadSeconds) || other.totalReadSeconds == totalReadSeconds)&&(identical(other.averageReadTimeSeconds, averageReadTimeSeconds) || other.averageReadTimeSeconds == averageReadTimeSeconds)&&(identical(other.followersGained, followersGained) || other.followersGained == followersGained)&&(identical(other.piecesPublished, piecesPublished) || other.piecesPublished == piecesPublished)&&(identical(other.piecesArchived, piecesArchived) || other.piecesArchived == piecesArchived)&&(identical(other.commentsReceived, commentsReceived) || other.commentsReceived == commentsReceived)&&(identical(other.clapsReceived, clapsReceived) || other.clapsReceived == clapsReceived)&&(identical(other.bookmarksReceived, bookmarksReceived) || other.bookmarksReceived == bookmarksReceived)&&(identical(other.responsesReceived, responsesReceived) || other.responsesReceived == responsesReceived)&&(identical(other.mostPopularPiece, mostPopularPiece) || other.mostPopularPiece == mostPopularPiece));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalViews,uniqueViews,reads,completionRate,totalReadSeconds,averageReadTimeSeconds,followersGained,piecesPublished,piecesArchived,commentsReceived,clapsReceived,bookmarksReceived,responsesReceived,mostPopularPiece);

@override
String toString() {
  return 'WriterAnalytics(totalViews: $totalViews, uniqueViews: $uniqueViews, reads: $reads, completionRate: $completionRate, totalReadSeconds: $totalReadSeconds, averageReadTimeSeconds: $averageReadTimeSeconds, followersGained: $followersGained, piecesPublished: $piecesPublished, piecesArchived: $piecesArchived, commentsReceived: $commentsReceived, clapsReceived: $clapsReceived, bookmarksReceived: $bookmarksReceived, responsesReceived: $responsesReceived, mostPopularPiece: $mostPopularPiece)';
}


}

/// @nodoc
abstract mixin class _$WriterAnalyticsCopyWith<$Res> implements $WriterAnalyticsCopyWith<$Res> {
  factory _$WriterAnalyticsCopyWith(_WriterAnalytics value, $Res Function(_WriterAnalytics) _then) = __$WriterAnalyticsCopyWithImpl;
@override @useResult
$Res call({
 int totalViews, int uniqueViews, int reads, double completionRate, int totalReadSeconds, int averageReadTimeSeconds, int followersGained, int piecesPublished, int piecesArchived, int commentsReceived, int clapsReceived, int bookmarksReceived, int responsesReceived, MostPopularPiece? mostPopularPiece
});


@override $MostPopularPieceCopyWith<$Res>? get mostPopularPiece;

}
/// @nodoc
class __$WriterAnalyticsCopyWithImpl<$Res>
    implements _$WriterAnalyticsCopyWith<$Res> {
  __$WriterAnalyticsCopyWithImpl(this._self, this._then);

  final _WriterAnalytics _self;
  final $Res Function(_WriterAnalytics) _then;

/// Create a copy of WriterAnalytics
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalViews = null,Object? uniqueViews = null,Object? reads = null,Object? completionRate = null,Object? totalReadSeconds = null,Object? averageReadTimeSeconds = null,Object? followersGained = null,Object? piecesPublished = null,Object? piecesArchived = null,Object? commentsReceived = null,Object? clapsReceived = null,Object? bookmarksReceived = null,Object? responsesReceived = null,Object? mostPopularPiece = freezed,}) {
  return _then(_WriterAnalytics(
totalViews: null == totalViews ? _self.totalViews : totalViews // ignore: cast_nullable_to_non_nullable
as int,uniqueViews: null == uniqueViews ? _self.uniqueViews : uniqueViews // ignore: cast_nullable_to_non_nullable
as int,reads: null == reads ? _self.reads : reads // ignore: cast_nullable_to_non_nullable
as int,completionRate: null == completionRate ? _self.completionRate : completionRate // ignore: cast_nullable_to_non_nullable
as double,totalReadSeconds: null == totalReadSeconds ? _self.totalReadSeconds : totalReadSeconds // ignore: cast_nullable_to_non_nullable
as int,averageReadTimeSeconds: null == averageReadTimeSeconds ? _self.averageReadTimeSeconds : averageReadTimeSeconds // ignore: cast_nullable_to_non_nullable
as int,followersGained: null == followersGained ? _self.followersGained : followersGained // ignore: cast_nullable_to_non_nullable
as int,piecesPublished: null == piecesPublished ? _self.piecesPublished : piecesPublished // ignore: cast_nullable_to_non_nullable
as int,piecesArchived: null == piecesArchived ? _self.piecesArchived : piecesArchived // ignore: cast_nullable_to_non_nullable
as int,commentsReceived: null == commentsReceived ? _self.commentsReceived : commentsReceived // ignore: cast_nullable_to_non_nullable
as int,clapsReceived: null == clapsReceived ? _self.clapsReceived : clapsReceived // ignore: cast_nullable_to_non_nullable
as int,bookmarksReceived: null == bookmarksReceived ? _self.bookmarksReceived : bookmarksReceived // ignore: cast_nullable_to_non_nullable
as int,responsesReceived: null == responsesReceived ? _self.responsesReceived : responsesReceived // ignore: cast_nullable_to_non_nullable
as int,mostPopularPiece: freezed == mostPopularPiece ? _self.mostPopularPiece : mostPopularPiece // ignore: cast_nullable_to_non_nullable
as MostPopularPiece?,
  ));
}

/// Create a copy of WriterAnalytics
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MostPopularPieceCopyWith<$Res>? get mostPopularPiece {
    if (_self.mostPopularPiece == null) {
    return null;
  }

  return $MostPopularPieceCopyWith<$Res>(_self.mostPopularPiece!, (value) {
    return _then(_self.copyWith(mostPopularPiece: value));
  });
}
}


/// @nodoc
mixin _$MostPopularPiece {

 String get pieceId; String get title; String? get slug; int get views;
/// Create a copy of MostPopularPiece
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MostPopularPieceCopyWith<MostPopularPiece> get copyWith => _$MostPopularPieceCopyWithImpl<MostPopularPiece>(this as MostPopularPiece, _$identity);

  /// Serializes this MostPopularPiece to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MostPopularPiece&&(identical(other.pieceId, pieceId) || other.pieceId == pieceId)&&(identical(other.title, title) || other.title == title)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.views, views) || other.views == views));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,pieceId,title,slug,views);

@override
String toString() {
  return 'MostPopularPiece(pieceId: $pieceId, title: $title, slug: $slug, views: $views)';
}


}

/// @nodoc
abstract mixin class $MostPopularPieceCopyWith<$Res>  {
  factory $MostPopularPieceCopyWith(MostPopularPiece value, $Res Function(MostPopularPiece) _then) = _$MostPopularPieceCopyWithImpl;
@useResult
$Res call({
 String pieceId, String title, String? slug, int views
});




}
/// @nodoc
class _$MostPopularPieceCopyWithImpl<$Res>
    implements $MostPopularPieceCopyWith<$Res> {
  _$MostPopularPieceCopyWithImpl(this._self, this._then);

  final MostPopularPiece _self;
  final $Res Function(MostPopularPiece) _then;

/// Create a copy of MostPopularPiece
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? pieceId = null,Object? title = null,Object? slug = freezed,Object? views = null,}) {
  return _then(_self.copyWith(
pieceId: null == pieceId ? _self.pieceId : pieceId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,slug: freezed == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String?,views: null == views ? _self.views : views // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [MostPopularPiece].
extension MostPopularPiecePatterns on MostPopularPiece {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MostPopularPiece value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MostPopularPiece() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MostPopularPiece value)  $default,){
final _that = this;
switch (_that) {
case _MostPopularPiece():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MostPopularPiece value)?  $default,){
final _that = this;
switch (_that) {
case _MostPopularPiece() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String pieceId,  String title,  String? slug,  int views)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MostPopularPiece() when $default != null:
return $default(_that.pieceId,_that.title,_that.slug,_that.views);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String pieceId,  String title,  String? slug,  int views)  $default,) {final _that = this;
switch (_that) {
case _MostPopularPiece():
return $default(_that.pieceId,_that.title,_that.slug,_that.views);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String pieceId,  String title,  String? slug,  int views)?  $default,) {final _that = this;
switch (_that) {
case _MostPopularPiece() when $default != null:
return $default(_that.pieceId,_that.title,_that.slug,_that.views);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MostPopularPiece implements MostPopularPiece {
  const _MostPopularPiece({required this.pieceId, this.title = '', this.slug, this.views = 0});
  factory _MostPopularPiece.fromJson(Map<String, dynamic> json) => _$MostPopularPieceFromJson(json);

@override final  String pieceId;
@override@JsonKey() final  String title;
@override final  String? slug;
@override@JsonKey() final  int views;

/// Create a copy of MostPopularPiece
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MostPopularPieceCopyWith<_MostPopularPiece> get copyWith => __$MostPopularPieceCopyWithImpl<_MostPopularPiece>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MostPopularPieceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MostPopularPiece&&(identical(other.pieceId, pieceId) || other.pieceId == pieceId)&&(identical(other.title, title) || other.title == title)&&(identical(other.slug, slug) || other.slug == slug)&&(identical(other.views, views) || other.views == views));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,pieceId,title,slug,views);

@override
String toString() {
  return 'MostPopularPiece(pieceId: $pieceId, title: $title, slug: $slug, views: $views)';
}


}

/// @nodoc
abstract mixin class _$MostPopularPieceCopyWith<$Res> implements $MostPopularPieceCopyWith<$Res> {
  factory _$MostPopularPieceCopyWith(_MostPopularPiece value, $Res Function(_MostPopularPiece) _then) = __$MostPopularPieceCopyWithImpl;
@override @useResult
$Res call({
 String pieceId, String title, String? slug, int views
});




}
/// @nodoc
class __$MostPopularPieceCopyWithImpl<$Res>
    implements _$MostPopularPieceCopyWith<$Res> {
  __$MostPopularPieceCopyWithImpl(this._self, this._then);

  final _MostPopularPiece _self;
  final $Res Function(_MostPopularPiece) _then;

/// Create a copy of MostPopularPiece
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? pieceId = null,Object? title = null,Object? slug = freezed,Object? views = null,}) {
  return _then(_MostPopularPiece(
pieceId: null == pieceId ? _self.pieceId : pieceId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,slug: freezed == slug ? _self.slug : slug // ignore: cast_nullable_to_non_nullable
as String?,views: null == views ? _self.views : views // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on

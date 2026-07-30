// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'reader_analytics.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ReaderAnalytics {

 int get piecesRead; int get readingTimeSeconds; int get completedReads; int get currentStreak; int get longestStreak; List<RankedItem> get favoriteGenres; List<RankedItem> get favoriteLanguages;
/// Create a copy of ReaderAnalytics
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReaderAnalyticsCopyWith<ReaderAnalytics> get copyWith => _$ReaderAnalyticsCopyWithImpl<ReaderAnalytics>(this as ReaderAnalytics, _$identity);

  /// Serializes this ReaderAnalytics to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReaderAnalytics&&(identical(other.piecesRead, piecesRead) || other.piecesRead == piecesRead)&&(identical(other.readingTimeSeconds, readingTimeSeconds) || other.readingTimeSeconds == readingTimeSeconds)&&(identical(other.completedReads, completedReads) || other.completedReads == completedReads)&&(identical(other.currentStreak, currentStreak) || other.currentStreak == currentStreak)&&(identical(other.longestStreak, longestStreak) || other.longestStreak == longestStreak)&&const DeepCollectionEquality().equals(other.favoriteGenres, favoriteGenres)&&const DeepCollectionEquality().equals(other.favoriteLanguages, favoriteLanguages));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,piecesRead,readingTimeSeconds,completedReads,currentStreak,longestStreak,const DeepCollectionEquality().hash(favoriteGenres),const DeepCollectionEquality().hash(favoriteLanguages));

@override
String toString() {
  return 'ReaderAnalytics(piecesRead: $piecesRead, readingTimeSeconds: $readingTimeSeconds, completedReads: $completedReads, currentStreak: $currentStreak, longestStreak: $longestStreak, favoriteGenres: $favoriteGenres, favoriteLanguages: $favoriteLanguages)';
}


}

/// @nodoc
abstract mixin class $ReaderAnalyticsCopyWith<$Res>  {
  factory $ReaderAnalyticsCopyWith(ReaderAnalytics value, $Res Function(ReaderAnalytics) _then) = _$ReaderAnalyticsCopyWithImpl;
@useResult
$Res call({
 int piecesRead, int readingTimeSeconds, int completedReads, int currentStreak, int longestStreak, List<RankedItem> favoriteGenres, List<RankedItem> favoriteLanguages
});




}
/// @nodoc
class _$ReaderAnalyticsCopyWithImpl<$Res>
    implements $ReaderAnalyticsCopyWith<$Res> {
  _$ReaderAnalyticsCopyWithImpl(this._self, this._then);

  final ReaderAnalytics _self;
  final $Res Function(ReaderAnalytics) _then;

/// Create a copy of ReaderAnalytics
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? piecesRead = null,Object? readingTimeSeconds = null,Object? completedReads = null,Object? currentStreak = null,Object? longestStreak = null,Object? favoriteGenres = null,Object? favoriteLanguages = null,}) {
  return _then(_self.copyWith(
piecesRead: null == piecesRead ? _self.piecesRead : piecesRead // ignore: cast_nullable_to_non_nullable
as int,readingTimeSeconds: null == readingTimeSeconds ? _self.readingTimeSeconds : readingTimeSeconds // ignore: cast_nullable_to_non_nullable
as int,completedReads: null == completedReads ? _self.completedReads : completedReads // ignore: cast_nullable_to_non_nullable
as int,currentStreak: null == currentStreak ? _self.currentStreak : currentStreak // ignore: cast_nullable_to_non_nullable
as int,longestStreak: null == longestStreak ? _self.longestStreak : longestStreak // ignore: cast_nullable_to_non_nullable
as int,favoriteGenres: null == favoriteGenres ? _self.favoriteGenres : favoriteGenres // ignore: cast_nullable_to_non_nullable
as List<RankedItem>,favoriteLanguages: null == favoriteLanguages ? _self.favoriteLanguages : favoriteLanguages // ignore: cast_nullable_to_non_nullable
as List<RankedItem>,
  ));
}

}


/// Adds pattern-matching-related methods to [ReaderAnalytics].
extension ReaderAnalyticsPatterns on ReaderAnalytics {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReaderAnalytics value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReaderAnalytics() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReaderAnalytics value)  $default,){
final _that = this;
switch (_that) {
case _ReaderAnalytics():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReaderAnalytics value)?  $default,){
final _that = this;
switch (_that) {
case _ReaderAnalytics() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int piecesRead,  int readingTimeSeconds,  int completedReads,  int currentStreak,  int longestStreak,  List<RankedItem> favoriteGenres,  List<RankedItem> favoriteLanguages)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReaderAnalytics() when $default != null:
return $default(_that.piecesRead,_that.readingTimeSeconds,_that.completedReads,_that.currentStreak,_that.longestStreak,_that.favoriteGenres,_that.favoriteLanguages);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int piecesRead,  int readingTimeSeconds,  int completedReads,  int currentStreak,  int longestStreak,  List<RankedItem> favoriteGenres,  List<RankedItem> favoriteLanguages)  $default,) {final _that = this;
switch (_that) {
case _ReaderAnalytics():
return $default(_that.piecesRead,_that.readingTimeSeconds,_that.completedReads,_that.currentStreak,_that.longestStreak,_that.favoriteGenres,_that.favoriteLanguages);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int piecesRead,  int readingTimeSeconds,  int completedReads,  int currentStreak,  int longestStreak,  List<RankedItem> favoriteGenres,  List<RankedItem> favoriteLanguages)?  $default,) {final _that = this;
switch (_that) {
case _ReaderAnalytics() when $default != null:
return $default(_that.piecesRead,_that.readingTimeSeconds,_that.completedReads,_that.currentStreak,_that.longestStreak,_that.favoriteGenres,_that.favoriteLanguages);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReaderAnalytics implements ReaderAnalytics {
  const _ReaderAnalytics({this.piecesRead = 0, this.readingTimeSeconds = 0, this.completedReads = 0, this.currentStreak = 0, this.longestStreak = 0, final  List<RankedItem> favoriteGenres = const <RankedItem>[], final  List<RankedItem> favoriteLanguages = const <RankedItem>[]}): _favoriteGenres = favoriteGenres,_favoriteLanguages = favoriteLanguages;
  factory _ReaderAnalytics.fromJson(Map<String, dynamic> json) => _$ReaderAnalyticsFromJson(json);

@override@JsonKey() final  int piecesRead;
@override@JsonKey() final  int readingTimeSeconds;
@override@JsonKey() final  int completedReads;
@override@JsonKey() final  int currentStreak;
@override@JsonKey() final  int longestStreak;
 final  List<RankedItem> _favoriteGenres;
@override@JsonKey() List<RankedItem> get favoriteGenres {
  if (_favoriteGenres is EqualUnmodifiableListView) return _favoriteGenres;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_favoriteGenres);
}

 final  List<RankedItem> _favoriteLanguages;
@override@JsonKey() List<RankedItem> get favoriteLanguages {
  if (_favoriteLanguages is EqualUnmodifiableListView) return _favoriteLanguages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_favoriteLanguages);
}


/// Create a copy of ReaderAnalytics
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReaderAnalyticsCopyWith<_ReaderAnalytics> get copyWith => __$ReaderAnalyticsCopyWithImpl<_ReaderAnalytics>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReaderAnalyticsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReaderAnalytics&&(identical(other.piecesRead, piecesRead) || other.piecesRead == piecesRead)&&(identical(other.readingTimeSeconds, readingTimeSeconds) || other.readingTimeSeconds == readingTimeSeconds)&&(identical(other.completedReads, completedReads) || other.completedReads == completedReads)&&(identical(other.currentStreak, currentStreak) || other.currentStreak == currentStreak)&&(identical(other.longestStreak, longestStreak) || other.longestStreak == longestStreak)&&const DeepCollectionEquality().equals(other._favoriteGenres, _favoriteGenres)&&const DeepCollectionEquality().equals(other._favoriteLanguages, _favoriteLanguages));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,piecesRead,readingTimeSeconds,completedReads,currentStreak,longestStreak,const DeepCollectionEquality().hash(_favoriteGenres),const DeepCollectionEquality().hash(_favoriteLanguages));

@override
String toString() {
  return 'ReaderAnalytics(piecesRead: $piecesRead, readingTimeSeconds: $readingTimeSeconds, completedReads: $completedReads, currentStreak: $currentStreak, longestStreak: $longestStreak, favoriteGenres: $favoriteGenres, favoriteLanguages: $favoriteLanguages)';
}


}

/// @nodoc
abstract mixin class _$ReaderAnalyticsCopyWith<$Res> implements $ReaderAnalyticsCopyWith<$Res> {
  factory _$ReaderAnalyticsCopyWith(_ReaderAnalytics value, $Res Function(_ReaderAnalytics) _then) = __$ReaderAnalyticsCopyWithImpl;
@override @useResult
$Res call({
 int piecesRead, int readingTimeSeconds, int completedReads, int currentStreak, int longestStreak, List<RankedItem> favoriteGenres, List<RankedItem> favoriteLanguages
});




}
/// @nodoc
class __$ReaderAnalyticsCopyWithImpl<$Res>
    implements _$ReaderAnalyticsCopyWith<$Res> {
  __$ReaderAnalyticsCopyWithImpl(this._self, this._then);

  final _ReaderAnalytics _self;
  final $Res Function(_ReaderAnalytics) _then;

/// Create a copy of ReaderAnalytics
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? piecesRead = null,Object? readingTimeSeconds = null,Object? completedReads = null,Object? currentStreak = null,Object? longestStreak = null,Object? favoriteGenres = null,Object? favoriteLanguages = null,}) {
  return _then(_ReaderAnalytics(
piecesRead: null == piecesRead ? _self.piecesRead : piecesRead // ignore: cast_nullable_to_non_nullable
as int,readingTimeSeconds: null == readingTimeSeconds ? _self.readingTimeSeconds : readingTimeSeconds // ignore: cast_nullable_to_non_nullable
as int,completedReads: null == completedReads ? _self.completedReads : completedReads // ignore: cast_nullable_to_non_nullable
as int,currentStreak: null == currentStreak ? _self.currentStreak : currentStreak // ignore: cast_nullable_to_non_nullable
as int,longestStreak: null == longestStreak ? _self.longestStreak : longestStreak // ignore: cast_nullable_to_non_nullable
as int,favoriteGenres: null == favoriteGenres ? _self._favoriteGenres : favoriteGenres // ignore: cast_nullable_to_non_nullable
as List<RankedItem>,favoriteLanguages: null == favoriteLanguages ? _self._favoriteLanguages : favoriteLanguages // ignore: cast_nullable_to_non_nullable
as List<RankedItem>,
  ));
}


}

// dart format on

// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'growth_series.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$GrowthPoint {

 String get periodStart; Map<String, num> get metrics;
/// Create a copy of GrowthPoint
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GrowthPointCopyWith<GrowthPoint> get copyWith => _$GrowthPointCopyWithImpl<GrowthPoint>(this as GrowthPoint, _$identity);

  /// Serializes this GrowthPoint to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GrowthPoint&&(identical(other.periodStart, periodStart) || other.periodStart == periodStart)&&const DeepCollectionEquality().equals(other.metrics, metrics));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,periodStart,const DeepCollectionEquality().hash(metrics));

@override
String toString() {
  return 'GrowthPoint(periodStart: $periodStart, metrics: $metrics)';
}


}

/// @nodoc
abstract mixin class $GrowthPointCopyWith<$Res>  {
  factory $GrowthPointCopyWith(GrowthPoint value, $Res Function(GrowthPoint) _then) = _$GrowthPointCopyWithImpl;
@useResult
$Res call({
 String periodStart, Map<String, num> metrics
});




}
/// @nodoc
class _$GrowthPointCopyWithImpl<$Res>
    implements $GrowthPointCopyWith<$Res> {
  _$GrowthPointCopyWithImpl(this._self, this._then);

  final GrowthPoint _self;
  final $Res Function(GrowthPoint) _then;

/// Create a copy of GrowthPoint
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? periodStart = null,Object? metrics = null,}) {
  return _then(_self.copyWith(
periodStart: null == periodStart ? _self.periodStart : periodStart // ignore: cast_nullable_to_non_nullable
as String,metrics: null == metrics ? _self.metrics : metrics // ignore: cast_nullable_to_non_nullable
as Map<String, num>,
  ));
}

}


/// Adds pattern-matching-related methods to [GrowthPoint].
extension GrowthPointPatterns on GrowthPoint {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GrowthPoint value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GrowthPoint() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GrowthPoint value)  $default,){
final _that = this;
switch (_that) {
case _GrowthPoint():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GrowthPoint value)?  $default,){
final _that = this;
switch (_that) {
case _GrowthPoint() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String periodStart,  Map<String, num> metrics)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GrowthPoint() when $default != null:
return $default(_that.periodStart,_that.metrics);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String periodStart,  Map<String, num> metrics)  $default,) {final _that = this;
switch (_that) {
case _GrowthPoint():
return $default(_that.periodStart,_that.metrics);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String periodStart,  Map<String, num> metrics)?  $default,) {final _that = this;
switch (_that) {
case _GrowthPoint() when $default != null:
return $default(_that.periodStart,_that.metrics);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GrowthPoint extends GrowthPoint {
  const _GrowthPoint({this.periodStart = '', final  Map<String, num> metrics = const <String, num>{}}): _metrics = metrics,super._();
  factory _GrowthPoint.fromJson(Map<String, dynamic> json) => _$GrowthPointFromJson(json);

@override@JsonKey() final  String periodStart;
 final  Map<String, num> _metrics;
@override@JsonKey() Map<String, num> get metrics {
  if (_metrics is EqualUnmodifiableMapView) return _metrics;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_metrics);
}


/// Create a copy of GrowthPoint
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GrowthPointCopyWith<_GrowthPoint> get copyWith => __$GrowthPointCopyWithImpl<_GrowthPoint>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GrowthPointToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GrowthPoint&&(identical(other.periodStart, periodStart) || other.periodStart == periodStart)&&const DeepCollectionEquality().equals(other._metrics, _metrics));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,periodStart,const DeepCollectionEquality().hash(_metrics));

@override
String toString() {
  return 'GrowthPoint(periodStart: $periodStart, metrics: $metrics)';
}


}

/// @nodoc
abstract mixin class _$GrowthPointCopyWith<$Res> implements $GrowthPointCopyWith<$Res> {
  factory _$GrowthPointCopyWith(_GrowthPoint value, $Res Function(_GrowthPoint) _then) = __$GrowthPointCopyWithImpl;
@override @useResult
$Res call({
 String periodStart, Map<String, num> metrics
});




}
/// @nodoc
class __$GrowthPointCopyWithImpl<$Res>
    implements _$GrowthPointCopyWith<$Res> {
  __$GrowthPointCopyWithImpl(this._self, this._then);

  final _GrowthPoint _self;
  final $Res Function(_GrowthPoint) _then;

/// Create a copy of GrowthPoint
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? periodStart = null,Object? metrics = null,}) {
  return _then(_GrowthPoint(
periodStart: null == periodStart ? _self.periodStart : periodStart // ignore: cast_nullable_to_non_nullable
as String,metrics: null == metrics ? _self._metrics : metrics // ignore: cast_nullable_to_non_nullable
as Map<String, num>,
  ));
}


}


/// @nodoc
mixin _$GrowthSeries {

 String get period; List<GrowthPoint> get points;
/// Create a copy of GrowthSeries
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GrowthSeriesCopyWith<GrowthSeries> get copyWith => _$GrowthSeriesCopyWithImpl<GrowthSeries>(this as GrowthSeries, _$identity);

  /// Serializes this GrowthSeries to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GrowthSeries&&(identical(other.period, period) || other.period == period)&&const DeepCollectionEquality().equals(other.points, points));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,period,const DeepCollectionEquality().hash(points));

@override
String toString() {
  return 'GrowthSeries(period: $period, points: $points)';
}


}

/// @nodoc
abstract mixin class $GrowthSeriesCopyWith<$Res>  {
  factory $GrowthSeriesCopyWith(GrowthSeries value, $Res Function(GrowthSeries) _then) = _$GrowthSeriesCopyWithImpl;
@useResult
$Res call({
 String period, List<GrowthPoint> points
});




}
/// @nodoc
class _$GrowthSeriesCopyWithImpl<$Res>
    implements $GrowthSeriesCopyWith<$Res> {
  _$GrowthSeriesCopyWithImpl(this._self, this._then);

  final GrowthSeries _self;
  final $Res Function(GrowthSeries) _then;

/// Create a copy of GrowthSeries
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? period = null,Object? points = null,}) {
  return _then(_self.copyWith(
period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as String,points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as List<GrowthPoint>,
  ));
}

}


/// Adds pattern-matching-related methods to [GrowthSeries].
extension GrowthSeriesPatterns on GrowthSeries {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GrowthSeries value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GrowthSeries() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GrowthSeries value)  $default,){
final _that = this;
switch (_that) {
case _GrowthSeries():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GrowthSeries value)?  $default,){
final _that = this;
switch (_that) {
case _GrowthSeries() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String period,  List<GrowthPoint> points)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GrowthSeries() when $default != null:
return $default(_that.period,_that.points);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String period,  List<GrowthPoint> points)  $default,) {final _that = this;
switch (_that) {
case _GrowthSeries():
return $default(_that.period,_that.points);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String period,  List<GrowthPoint> points)?  $default,) {final _that = this;
switch (_that) {
case _GrowthSeries() when $default != null:
return $default(_that.period,_that.points);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _GrowthSeries extends GrowthSeries {
  const _GrowthSeries({this.period = 'daily', final  List<GrowthPoint> points = const <GrowthPoint>[]}): _points = points,super._();
  factory _GrowthSeries.fromJson(Map<String, dynamic> json) => _$GrowthSeriesFromJson(json);

@override@JsonKey() final  String period;
 final  List<GrowthPoint> _points;
@override@JsonKey() List<GrowthPoint> get points {
  if (_points is EqualUnmodifiableListView) return _points;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_points);
}


/// Create a copy of GrowthSeries
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GrowthSeriesCopyWith<_GrowthSeries> get copyWith => __$GrowthSeriesCopyWithImpl<_GrowthSeries>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$GrowthSeriesToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GrowthSeries&&(identical(other.period, period) || other.period == period)&&const DeepCollectionEquality().equals(other._points, _points));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,period,const DeepCollectionEquality().hash(_points));

@override
String toString() {
  return 'GrowthSeries(period: $period, points: $points)';
}


}

/// @nodoc
abstract mixin class _$GrowthSeriesCopyWith<$Res> implements $GrowthSeriesCopyWith<$Res> {
  factory _$GrowthSeriesCopyWith(_GrowthSeries value, $Res Function(_GrowthSeries) _then) = __$GrowthSeriesCopyWithImpl;
@override @useResult
$Res call({
 String period, List<GrowthPoint> points
});




}
/// @nodoc
class __$GrowthSeriesCopyWithImpl<$Res>
    implements _$GrowthSeriesCopyWith<$Res> {
  __$GrowthSeriesCopyWithImpl(this._self, this._then);

  final _GrowthSeries _self;
  final $Res Function(_GrowthSeries) _then;

/// Create a copy of GrowthSeries
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? period = null,Object? points = null,}) {
  return _then(_GrowthSeries(
period: null == period ? _self.period : period // ignore: cast_nullable_to_non_nullable
as String,points: null == points ? _self._points : points // ignore: cast_nullable_to_non_nullable
as List<GrowthPoint>,
  ));
}


}

// dart format on

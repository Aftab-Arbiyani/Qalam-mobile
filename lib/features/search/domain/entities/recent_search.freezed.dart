// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recent_search.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RecentSearch {

 String get query; SearchType get searchType; DateTime get searchedAt; String? get serverId;
/// Create a copy of RecentSearch
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecentSearchCopyWith<RecentSearch> get copyWith => _$RecentSearchCopyWithImpl<RecentSearch>(this as RecentSearch, _$identity);

  /// Serializes this RecentSearch to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecentSearch&&(identical(other.query, query) || other.query == query)&&(identical(other.searchType, searchType) || other.searchType == searchType)&&(identical(other.searchedAt, searchedAt) || other.searchedAt == searchedAt)&&(identical(other.serverId, serverId) || other.serverId == serverId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,query,searchType,searchedAt,serverId);

@override
String toString() {
  return 'RecentSearch(query: $query, searchType: $searchType, searchedAt: $searchedAt, serverId: $serverId)';
}


}

/// @nodoc
abstract mixin class $RecentSearchCopyWith<$Res>  {
  factory $RecentSearchCopyWith(RecentSearch value, $Res Function(RecentSearch) _then) = _$RecentSearchCopyWithImpl;
@useResult
$Res call({
 String query, SearchType searchType, DateTime searchedAt, String? serverId
});




}
/// @nodoc
class _$RecentSearchCopyWithImpl<$Res>
    implements $RecentSearchCopyWith<$Res> {
  _$RecentSearchCopyWithImpl(this._self, this._then);

  final RecentSearch _self;
  final $Res Function(RecentSearch) _then;

/// Create a copy of RecentSearch
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? query = null,Object? searchType = null,Object? searchedAt = null,Object? serverId = freezed,}) {
  return _then(_self.copyWith(
query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,searchType: null == searchType ? _self.searchType : searchType // ignore: cast_nullable_to_non_nullable
as SearchType,searchedAt: null == searchedAt ? _self.searchedAt : searchedAt // ignore: cast_nullable_to_non_nullable
as DateTime,serverId: freezed == serverId ? _self.serverId : serverId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [RecentSearch].
extension RecentSearchPatterns on RecentSearch {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecentSearch value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecentSearch() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecentSearch value)  $default,){
final _that = this;
switch (_that) {
case _RecentSearch():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecentSearch value)?  $default,){
final _that = this;
switch (_that) {
case _RecentSearch() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String query,  SearchType searchType,  DateTime searchedAt,  String? serverId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecentSearch() when $default != null:
return $default(_that.query,_that.searchType,_that.searchedAt,_that.serverId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String query,  SearchType searchType,  DateTime searchedAt,  String? serverId)  $default,) {final _that = this;
switch (_that) {
case _RecentSearch():
return $default(_that.query,_that.searchType,_that.searchedAt,_that.serverId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String query,  SearchType searchType,  DateTime searchedAt,  String? serverId)?  $default,) {final _that = this;
switch (_that) {
case _RecentSearch() when $default != null:
return $default(_that.query,_that.searchType,_that.searchedAt,_that.serverId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RecentSearch extends RecentSearch {
  const _RecentSearch({required this.query, this.searchType = SearchType.all, required this.searchedAt, this.serverId}): super._();
  factory _RecentSearch.fromJson(Map<String, dynamic> json) => _$RecentSearchFromJson(json);

@override final  String query;
@override@JsonKey() final  SearchType searchType;
@override final  DateTime searchedAt;
@override final  String? serverId;

/// Create a copy of RecentSearch
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecentSearchCopyWith<_RecentSearch> get copyWith => __$RecentSearchCopyWithImpl<_RecentSearch>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RecentSearchToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecentSearch&&(identical(other.query, query) || other.query == query)&&(identical(other.searchType, searchType) || other.searchType == searchType)&&(identical(other.searchedAt, searchedAt) || other.searchedAt == searchedAt)&&(identical(other.serverId, serverId) || other.serverId == serverId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,query,searchType,searchedAt,serverId);

@override
String toString() {
  return 'RecentSearch(query: $query, searchType: $searchType, searchedAt: $searchedAt, serverId: $serverId)';
}


}

/// @nodoc
abstract mixin class _$RecentSearchCopyWith<$Res> implements $RecentSearchCopyWith<$Res> {
  factory _$RecentSearchCopyWith(_RecentSearch value, $Res Function(_RecentSearch) _then) = __$RecentSearchCopyWithImpl;
@override @useResult
$Res call({
 String query, SearchType searchType, DateTime searchedAt, String? serverId
});




}
/// @nodoc
class __$RecentSearchCopyWithImpl<$Res>
    implements _$RecentSearchCopyWith<$Res> {
  __$RecentSearchCopyWithImpl(this._self, this._then);

  final _RecentSearch _self;
  final $Res Function(_RecentSearch) _then;

/// Create a copy of RecentSearch
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? query = null,Object? searchType = null,Object? searchedAt = null,Object? serverId = freezed,}) {
  return _then(_RecentSearch(
query: null == query ? _self.query : query // ignore: cast_nullable_to_non_nullable
as String,searchType: null == searchType ? _self.searchType : searchType // ignore: cast_nullable_to_non_nullable
as SearchType,searchedAt: null == searchedAt ? _self.searchedAt : searchedAt // ignore: cast_nullable_to_non_nullable
as DateTime,serverId: freezed == serverId ? _self.serverId : serverId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on

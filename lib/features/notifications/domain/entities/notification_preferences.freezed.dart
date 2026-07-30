// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_preferences.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$NotificationPreferences {

 bool get follow; bool get comment; bool get reply; bool get reaction; bool get mention; bool get response; bool get system;
/// Create a copy of NotificationPreferences
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationPreferencesCopyWith<NotificationPreferences> get copyWith => _$NotificationPreferencesCopyWithImpl<NotificationPreferences>(this as NotificationPreferences, _$identity);

  /// Serializes this NotificationPreferences to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationPreferences&&(identical(other.follow, follow) || other.follow == follow)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.reply, reply) || other.reply == reply)&&(identical(other.reaction, reaction) || other.reaction == reaction)&&(identical(other.mention, mention) || other.mention == mention)&&(identical(other.response, response) || other.response == response)&&(identical(other.system, system) || other.system == system));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,follow,comment,reply,reaction,mention,response,system);

@override
String toString() {
  return 'NotificationPreferences(follow: $follow, comment: $comment, reply: $reply, reaction: $reaction, mention: $mention, response: $response, system: $system)';
}


}

/// @nodoc
abstract mixin class $NotificationPreferencesCopyWith<$Res>  {
  factory $NotificationPreferencesCopyWith(NotificationPreferences value, $Res Function(NotificationPreferences) _then) = _$NotificationPreferencesCopyWithImpl;
@useResult
$Res call({
 bool follow, bool comment, bool reply, bool reaction, bool mention, bool response, bool system
});




}
/// @nodoc
class _$NotificationPreferencesCopyWithImpl<$Res>
    implements $NotificationPreferencesCopyWith<$Res> {
  _$NotificationPreferencesCopyWithImpl(this._self, this._then);

  final NotificationPreferences _self;
  final $Res Function(NotificationPreferences) _then;

/// Create a copy of NotificationPreferences
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? follow = null,Object? comment = null,Object? reply = null,Object? reaction = null,Object? mention = null,Object? response = null,Object? system = null,}) {
  return _then(_self.copyWith(
follow: null == follow ? _self.follow : follow // ignore: cast_nullable_to_non_nullable
as bool,comment: null == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as bool,reply: null == reply ? _self.reply : reply // ignore: cast_nullable_to_non_nullable
as bool,reaction: null == reaction ? _self.reaction : reaction // ignore: cast_nullable_to_non_nullable
as bool,mention: null == mention ? _self.mention : mention // ignore: cast_nullable_to_non_nullable
as bool,response: null == response ? _self.response : response // ignore: cast_nullable_to_non_nullable
as bool,system: null == system ? _self.system : system // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [NotificationPreferences].
extension NotificationPreferencesPatterns on NotificationPreferences {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NotificationPreferences value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NotificationPreferences() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NotificationPreferences value)  $default,){
final _that = this;
switch (_that) {
case _NotificationPreferences():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NotificationPreferences value)?  $default,){
final _that = this;
switch (_that) {
case _NotificationPreferences() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool follow,  bool comment,  bool reply,  bool reaction,  bool mention,  bool response,  bool system)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotificationPreferences() when $default != null:
return $default(_that.follow,_that.comment,_that.reply,_that.reaction,_that.mention,_that.response,_that.system);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool follow,  bool comment,  bool reply,  bool reaction,  bool mention,  bool response,  bool system)  $default,) {final _that = this;
switch (_that) {
case _NotificationPreferences():
return $default(_that.follow,_that.comment,_that.reply,_that.reaction,_that.mention,_that.response,_that.system);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool follow,  bool comment,  bool reply,  bool reaction,  bool mention,  bool response,  bool system)?  $default,) {final _that = this;
switch (_that) {
case _NotificationPreferences() when $default != null:
return $default(_that.follow,_that.comment,_that.reply,_that.reaction,_that.mention,_that.response,_that.system);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NotificationPreferences extends NotificationPreferences {
  const _NotificationPreferences({this.follow = true, this.comment = true, this.reply = true, this.reaction = true, this.mention = true, this.response = true, this.system = true}): super._();
  factory _NotificationPreferences.fromJson(Map<String, dynamic> json) => _$NotificationPreferencesFromJson(json);

@override@JsonKey() final  bool follow;
@override@JsonKey() final  bool comment;
@override@JsonKey() final  bool reply;
@override@JsonKey() final  bool reaction;
@override@JsonKey() final  bool mention;
@override@JsonKey() final  bool response;
@override@JsonKey() final  bool system;

/// Create a copy of NotificationPreferences
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotificationPreferencesCopyWith<_NotificationPreferences> get copyWith => __$NotificationPreferencesCopyWithImpl<_NotificationPreferences>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NotificationPreferencesToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotificationPreferences&&(identical(other.follow, follow) || other.follow == follow)&&(identical(other.comment, comment) || other.comment == comment)&&(identical(other.reply, reply) || other.reply == reply)&&(identical(other.reaction, reaction) || other.reaction == reaction)&&(identical(other.mention, mention) || other.mention == mention)&&(identical(other.response, response) || other.response == response)&&(identical(other.system, system) || other.system == system));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,follow,comment,reply,reaction,mention,response,system);

@override
String toString() {
  return 'NotificationPreferences(follow: $follow, comment: $comment, reply: $reply, reaction: $reaction, mention: $mention, response: $response, system: $system)';
}


}

/// @nodoc
abstract mixin class _$NotificationPreferencesCopyWith<$Res> implements $NotificationPreferencesCopyWith<$Res> {
  factory _$NotificationPreferencesCopyWith(_NotificationPreferences value, $Res Function(_NotificationPreferences) _then) = __$NotificationPreferencesCopyWithImpl;
@override @useResult
$Res call({
 bool follow, bool comment, bool reply, bool reaction, bool mention, bool response, bool system
});




}
/// @nodoc
class __$NotificationPreferencesCopyWithImpl<$Res>
    implements _$NotificationPreferencesCopyWith<$Res> {
  __$NotificationPreferencesCopyWithImpl(this._self, this._then);

  final _NotificationPreferences _self;
  final $Res Function(_NotificationPreferences) _then;

/// Create a copy of NotificationPreferences
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? follow = null,Object? comment = null,Object? reply = null,Object? reaction = null,Object? mention = null,Object? response = null,Object? system = null,}) {
  return _then(_NotificationPreferences(
follow: null == follow ? _self.follow : follow // ignore: cast_nullable_to_non_nullable
as bool,comment: null == comment ? _self.comment : comment // ignore: cast_nullable_to_non_nullable
as bool,reply: null == reply ? _self.reply : reply // ignore: cast_nullable_to_non_nullable
as bool,reaction: null == reaction ? _self.reaction : reaction // ignore: cast_nullable_to_non_nullable
as bool,mention: null == mention ? _self.mention : mention // ignore: cast_nullable_to_non_nullable
as bool,response: null == response ? _self.response : response // ignore: cast_nullable_to_non_nullable
as bool,system: null == system ? _self.system : system // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on

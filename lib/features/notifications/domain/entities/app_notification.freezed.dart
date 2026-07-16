// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_notification.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AppNotification {

 String get id; NotificationType get type; NotificationStatus get status; Author? get actor; NotificationEntityType get entityType; String? get entityId; NotificationPayload get payload; DateTime? get readAt; DateTime? get archivedAt; DateTime get createdAt;
/// Create a copy of AppNotification
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppNotificationCopyWith<AppNotification> get copyWith => _$AppNotificationCopyWithImpl<AppNotification>(this as AppNotification, _$identity);

  /// Serializes this AppNotification to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppNotification&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.status, status) || other.status == status)&&(identical(other.actor, actor) || other.actor == actor)&&(identical(other.entityType, entityType) || other.entityType == entityType)&&(identical(other.entityId, entityId) || other.entityId == entityId)&&(identical(other.payload, payload) || other.payload == payload)&&(identical(other.readAt, readAt) || other.readAt == readAt)&&(identical(other.archivedAt, archivedAt) || other.archivedAt == archivedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,status,actor,entityType,entityId,payload,readAt,archivedAt,createdAt);

@override
String toString() {
  return 'AppNotification(id: $id, type: $type, status: $status, actor: $actor, entityType: $entityType, entityId: $entityId, payload: $payload, readAt: $readAt, archivedAt: $archivedAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $AppNotificationCopyWith<$Res>  {
  factory $AppNotificationCopyWith(AppNotification value, $Res Function(AppNotification) _then) = _$AppNotificationCopyWithImpl;
@useResult
$Res call({
 String id, NotificationType type, NotificationStatus status, Author? actor, NotificationEntityType entityType, String? entityId, NotificationPayload payload, DateTime? readAt, DateTime? archivedAt, DateTime createdAt
});


$AuthorCopyWith<$Res>? get actor;$NotificationPayloadCopyWith<$Res> get payload;

}
/// @nodoc
class _$AppNotificationCopyWithImpl<$Res>
    implements $AppNotificationCopyWith<$Res> {
  _$AppNotificationCopyWithImpl(this._self, this._then);

  final AppNotification _self;
  final $Res Function(AppNotification) _then;

/// Create a copy of AppNotification
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? status = null,Object? actor = freezed,Object? entityType = null,Object? entityId = freezed,Object? payload = null,Object? readAt = freezed,Object? archivedAt = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as NotificationType,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as NotificationStatus,actor: freezed == actor ? _self.actor : actor // ignore: cast_nullable_to_non_nullable
as Author?,entityType: null == entityType ? _self.entityType : entityType // ignore: cast_nullable_to_non_nullable
as NotificationEntityType,entityId: freezed == entityId ? _self.entityId : entityId // ignore: cast_nullable_to_non_nullable
as String?,payload: null == payload ? _self.payload : payload // ignore: cast_nullable_to_non_nullable
as NotificationPayload,readAt: freezed == readAt ? _self.readAt : readAt // ignore: cast_nullable_to_non_nullable
as DateTime?,archivedAt: freezed == archivedAt ? _self.archivedAt : archivedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}
/// Create a copy of AppNotification
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AuthorCopyWith<$Res>? get actor {
    if (_self.actor == null) {
    return null;
  }

  return $AuthorCopyWith<$Res>(_self.actor!, (value) {
    return _then(_self.copyWith(actor: value));
  });
}/// Create a copy of AppNotification
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NotificationPayloadCopyWith<$Res> get payload {
  
  return $NotificationPayloadCopyWith<$Res>(_self.payload, (value) {
    return _then(_self.copyWith(payload: value));
  });
}
}


/// Adds pattern-matching-related methods to [AppNotification].
extension AppNotificationPatterns on AppNotification {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppNotification value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppNotification() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppNotification value)  $default,){
final _that = this;
switch (_that) {
case _AppNotification():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppNotification value)?  $default,){
final _that = this;
switch (_that) {
case _AppNotification() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  NotificationType type,  NotificationStatus status,  Author? actor,  NotificationEntityType entityType,  String? entityId,  NotificationPayload payload,  DateTime? readAt,  DateTime? archivedAt,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppNotification() when $default != null:
return $default(_that.id,_that.type,_that.status,_that.actor,_that.entityType,_that.entityId,_that.payload,_that.readAt,_that.archivedAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  NotificationType type,  NotificationStatus status,  Author? actor,  NotificationEntityType entityType,  String? entityId,  NotificationPayload payload,  DateTime? readAt,  DateTime? archivedAt,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _AppNotification():
return $default(_that.id,_that.type,_that.status,_that.actor,_that.entityType,_that.entityId,_that.payload,_that.readAt,_that.archivedAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  NotificationType type,  NotificationStatus status,  Author? actor,  NotificationEntityType entityType,  String? entityId,  NotificationPayload payload,  DateTime? readAt,  DateTime? archivedAt,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _AppNotification() when $default != null:
return $default(_that.id,_that.type,_that.status,_that.actor,_that.entityType,_that.entityId,_that.payload,_that.readAt,_that.archivedAt,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AppNotification extends AppNotification {
  const _AppNotification({required this.id, this.type = NotificationType.unknown, this.status = NotificationStatus.unread, this.actor, this.entityType = NotificationEntityType.unknown, this.entityId, this.payload = const NotificationPayload(), this.readAt, this.archivedAt, required this.createdAt}): super._();
  factory _AppNotification.fromJson(Map<String, dynamic> json) => _$AppNotificationFromJson(json);

@override final  String id;
@override@JsonKey() final  NotificationType type;
@override@JsonKey() final  NotificationStatus status;
@override final  Author? actor;
@override@JsonKey() final  NotificationEntityType entityType;
@override final  String? entityId;
@override@JsonKey() final  NotificationPayload payload;
@override final  DateTime? readAt;
@override final  DateTime? archivedAt;
@override final  DateTime createdAt;

/// Create a copy of AppNotification
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppNotificationCopyWith<_AppNotification> get copyWith => __$AppNotificationCopyWithImpl<_AppNotification>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AppNotificationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppNotification&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.status, status) || other.status == status)&&(identical(other.actor, actor) || other.actor == actor)&&(identical(other.entityType, entityType) || other.entityType == entityType)&&(identical(other.entityId, entityId) || other.entityId == entityId)&&(identical(other.payload, payload) || other.payload == payload)&&(identical(other.readAt, readAt) || other.readAt == readAt)&&(identical(other.archivedAt, archivedAt) || other.archivedAt == archivedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,status,actor,entityType,entityId,payload,readAt,archivedAt,createdAt);

@override
String toString() {
  return 'AppNotification(id: $id, type: $type, status: $status, actor: $actor, entityType: $entityType, entityId: $entityId, payload: $payload, readAt: $readAt, archivedAt: $archivedAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$AppNotificationCopyWith<$Res> implements $AppNotificationCopyWith<$Res> {
  factory _$AppNotificationCopyWith(_AppNotification value, $Res Function(_AppNotification) _then) = __$AppNotificationCopyWithImpl;
@override @useResult
$Res call({
 String id, NotificationType type, NotificationStatus status, Author? actor, NotificationEntityType entityType, String? entityId, NotificationPayload payload, DateTime? readAt, DateTime? archivedAt, DateTime createdAt
});


@override $AuthorCopyWith<$Res>? get actor;@override $NotificationPayloadCopyWith<$Res> get payload;

}
/// @nodoc
class __$AppNotificationCopyWithImpl<$Res>
    implements _$AppNotificationCopyWith<$Res> {
  __$AppNotificationCopyWithImpl(this._self, this._then);

  final _AppNotification _self;
  final $Res Function(_AppNotification) _then;

/// Create a copy of AppNotification
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? status = null,Object? actor = freezed,Object? entityType = null,Object? entityId = freezed,Object? payload = null,Object? readAt = freezed,Object? archivedAt = freezed,Object? createdAt = null,}) {
  return _then(_AppNotification(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as NotificationType,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as NotificationStatus,actor: freezed == actor ? _self.actor : actor // ignore: cast_nullable_to_non_nullable
as Author?,entityType: null == entityType ? _self.entityType : entityType // ignore: cast_nullable_to_non_nullable
as NotificationEntityType,entityId: freezed == entityId ? _self.entityId : entityId // ignore: cast_nullable_to_non_nullable
as String?,payload: null == payload ? _self.payload : payload // ignore: cast_nullable_to_non_nullable
as NotificationPayload,readAt: freezed == readAt ? _self.readAt : readAt // ignore: cast_nullable_to_non_nullable
as DateTime?,archivedAt: freezed == archivedAt ? _self.archivedAt : archivedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

/// Create a copy of AppNotification
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AuthorCopyWith<$Res>? get actor {
    if (_self.actor == null) {
    return null;
  }

  return $AuthorCopyWith<$Res>(_self.actor!, (value) {
    return _then(_self.copyWith(actor: value));
  });
}/// Create a copy of AppNotification
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$NotificationPayloadCopyWith<$Res> get payload {
  
  return $NotificationPayloadCopyWith<$Res>(_self.payload, (value) {
    return _then(_self.copyWith(payload: value));
  });
}
}


/// @nodoc
mixin _$NotificationPayload {

/// Target piece — `data.piece.slug` is the deep-link key when the subject is
/// a piece or a comment (a comment's `entityId` is the comment id, not the
/// piece, so the slug is how the tap reaches the piece — docs/40 §12.3).
 String? get pieceSlug; String? get pieceTitle;/// A response notification's authored response-piece id (`data.responsePieceId`).
 String? get responsePieceId;/// Comment context (`data.comment.id` / `.excerpt`, excerpt ≤140 chars).
 String? get commentId; String? get commentExcerpt;/// System-announcement content (admin-authored `data.title`/`.message`/`.link`).
 String? get systemTitle; String? get systemMessage; String? get systemLink;
/// Create a copy of NotificationPayload
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationPayloadCopyWith<NotificationPayload> get copyWith => _$NotificationPayloadCopyWithImpl<NotificationPayload>(this as NotificationPayload, _$identity);

  /// Serializes this NotificationPayload to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationPayload&&(identical(other.pieceSlug, pieceSlug) || other.pieceSlug == pieceSlug)&&(identical(other.pieceTitle, pieceTitle) || other.pieceTitle == pieceTitle)&&(identical(other.responsePieceId, responsePieceId) || other.responsePieceId == responsePieceId)&&(identical(other.commentId, commentId) || other.commentId == commentId)&&(identical(other.commentExcerpt, commentExcerpt) || other.commentExcerpt == commentExcerpt)&&(identical(other.systemTitle, systemTitle) || other.systemTitle == systemTitle)&&(identical(other.systemMessage, systemMessage) || other.systemMessage == systemMessage)&&(identical(other.systemLink, systemLink) || other.systemLink == systemLink));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,pieceSlug,pieceTitle,responsePieceId,commentId,commentExcerpt,systemTitle,systemMessage,systemLink);

@override
String toString() {
  return 'NotificationPayload(pieceSlug: $pieceSlug, pieceTitle: $pieceTitle, responsePieceId: $responsePieceId, commentId: $commentId, commentExcerpt: $commentExcerpt, systemTitle: $systemTitle, systemMessage: $systemMessage, systemLink: $systemLink)';
}


}

/// @nodoc
abstract mixin class $NotificationPayloadCopyWith<$Res>  {
  factory $NotificationPayloadCopyWith(NotificationPayload value, $Res Function(NotificationPayload) _then) = _$NotificationPayloadCopyWithImpl;
@useResult
$Res call({
 String? pieceSlug, String? pieceTitle, String? responsePieceId, String? commentId, String? commentExcerpt, String? systemTitle, String? systemMessage, String? systemLink
});




}
/// @nodoc
class _$NotificationPayloadCopyWithImpl<$Res>
    implements $NotificationPayloadCopyWith<$Res> {
  _$NotificationPayloadCopyWithImpl(this._self, this._then);

  final NotificationPayload _self;
  final $Res Function(NotificationPayload) _then;

/// Create a copy of NotificationPayload
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? pieceSlug = freezed,Object? pieceTitle = freezed,Object? responsePieceId = freezed,Object? commentId = freezed,Object? commentExcerpt = freezed,Object? systemTitle = freezed,Object? systemMessage = freezed,Object? systemLink = freezed,}) {
  return _then(_self.copyWith(
pieceSlug: freezed == pieceSlug ? _self.pieceSlug : pieceSlug // ignore: cast_nullable_to_non_nullable
as String?,pieceTitle: freezed == pieceTitle ? _self.pieceTitle : pieceTitle // ignore: cast_nullable_to_non_nullable
as String?,responsePieceId: freezed == responsePieceId ? _self.responsePieceId : responsePieceId // ignore: cast_nullable_to_non_nullable
as String?,commentId: freezed == commentId ? _self.commentId : commentId // ignore: cast_nullable_to_non_nullable
as String?,commentExcerpt: freezed == commentExcerpt ? _self.commentExcerpt : commentExcerpt // ignore: cast_nullable_to_non_nullable
as String?,systemTitle: freezed == systemTitle ? _self.systemTitle : systemTitle // ignore: cast_nullable_to_non_nullable
as String?,systemMessage: freezed == systemMessage ? _self.systemMessage : systemMessage // ignore: cast_nullable_to_non_nullable
as String?,systemLink: freezed == systemLink ? _self.systemLink : systemLink // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [NotificationPayload].
extension NotificationPayloadPatterns on NotificationPayload {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NotificationPayload value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NotificationPayload() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NotificationPayload value)  $default,){
final _that = this;
switch (_that) {
case _NotificationPayload():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NotificationPayload value)?  $default,){
final _that = this;
switch (_that) {
case _NotificationPayload() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? pieceSlug,  String? pieceTitle,  String? responsePieceId,  String? commentId,  String? commentExcerpt,  String? systemTitle,  String? systemMessage,  String? systemLink)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotificationPayload() when $default != null:
return $default(_that.pieceSlug,_that.pieceTitle,_that.responsePieceId,_that.commentId,_that.commentExcerpt,_that.systemTitle,_that.systemMessage,_that.systemLink);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? pieceSlug,  String? pieceTitle,  String? responsePieceId,  String? commentId,  String? commentExcerpt,  String? systemTitle,  String? systemMessage,  String? systemLink)  $default,) {final _that = this;
switch (_that) {
case _NotificationPayload():
return $default(_that.pieceSlug,_that.pieceTitle,_that.responsePieceId,_that.commentId,_that.commentExcerpt,_that.systemTitle,_that.systemMessage,_that.systemLink);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? pieceSlug,  String? pieceTitle,  String? responsePieceId,  String? commentId,  String? commentExcerpt,  String? systemTitle,  String? systemMessage,  String? systemLink)?  $default,) {final _that = this;
switch (_that) {
case _NotificationPayload() when $default != null:
return $default(_that.pieceSlug,_that.pieceTitle,_that.responsePieceId,_that.commentId,_that.commentExcerpt,_that.systemTitle,_that.systemMessage,_that.systemLink);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NotificationPayload extends NotificationPayload {
  const _NotificationPayload({this.pieceSlug, this.pieceTitle, this.responsePieceId, this.commentId, this.commentExcerpt, this.systemTitle, this.systemMessage, this.systemLink}): super._();
  factory _NotificationPayload.fromJson(Map<String, dynamic> json) => _$NotificationPayloadFromJson(json);

/// Target piece — `data.piece.slug` is the deep-link key when the subject is
/// a piece or a comment (a comment's `entityId` is the comment id, not the
/// piece, so the slug is how the tap reaches the piece — docs/40 §12.3).
@override final  String? pieceSlug;
@override final  String? pieceTitle;
/// A response notification's authored response-piece id (`data.responsePieceId`).
@override final  String? responsePieceId;
/// Comment context (`data.comment.id` / `.excerpt`, excerpt ≤140 chars).
@override final  String? commentId;
@override final  String? commentExcerpt;
/// System-announcement content (admin-authored `data.title`/`.message`/`.link`).
@override final  String? systemTitle;
@override final  String? systemMessage;
@override final  String? systemLink;

/// Create a copy of NotificationPayload
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotificationPayloadCopyWith<_NotificationPayload> get copyWith => __$NotificationPayloadCopyWithImpl<_NotificationPayload>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NotificationPayloadToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotificationPayload&&(identical(other.pieceSlug, pieceSlug) || other.pieceSlug == pieceSlug)&&(identical(other.pieceTitle, pieceTitle) || other.pieceTitle == pieceTitle)&&(identical(other.responsePieceId, responsePieceId) || other.responsePieceId == responsePieceId)&&(identical(other.commentId, commentId) || other.commentId == commentId)&&(identical(other.commentExcerpt, commentExcerpt) || other.commentExcerpt == commentExcerpt)&&(identical(other.systemTitle, systemTitle) || other.systemTitle == systemTitle)&&(identical(other.systemMessage, systemMessage) || other.systemMessage == systemMessage)&&(identical(other.systemLink, systemLink) || other.systemLink == systemLink));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,pieceSlug,pieceTitle,responsePieceId,commentId,commentExcerpt,systemTitle,systemMessage,systemLink);

@override
String toString() {
  return 'NotificationPayload(pieceSlug: $pieceSlug, pieceTitle: $pieceTitle, responsePieceId: $responsePieceId, commentId: $commentId, commentExcerpt: $commentExcerpt, systemTitle: $systemTitle, systemMessage: $systemMessage, systemLink: $systemLink)';
}


}

/// @nodoc
abstract mixin class _$NotificationPayloadCopyWith<$Res> implements $NotificationPayloadCopyWith<$Res> {
  factory _$NotificationPayloadCopyWith(_NotificationPayload value, $Res Function(_NotificationPayload) _then) = __$NotificationPayloadCopyWithImpl;
@override @useResult
$Res call({
 String? pieceSlug, String? pieceTitle, String? responsePieceId, String? commentId, String? commentExcerpt, String? systemTitle, String? systemMessage, String? systemLink
});




}
/// @nodoc
class __$NotificationPayloadCopyWithImpl<$Res>
    implements _$NotificationPayloadCopyWith<$Res> {
  __$NotificationPayloadCopyWithImpl(this._self, this._then);

  final _NotificationPayload _self;
  final $Res Function(_NotificationPayload) _then;

/// Create a copy of NotificationPayload
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? pieceSlug = freezed,Object? pieceTitle = freezed,Object? responsePieceId = freezed,Object? commentId = freezed,Object? commentExcerpt = freezed,Object? systemTitle = freezed,Object? systemMessage = freezed,Object? systemLink = freezed,}) {
  return _then(_NotificationPayload(
pieceSlug: freezed == pieceSlug ? _self.pieceSlug : pieceSlug // ignore: cast_nullable_to_non_nullable
as String?,pieceTitle: freezed == pieceTitle ? _self.pieceTitle : pieceTitle // ignore: cast_nullable_to_non_nullable
as String?,responsePieceId: freezed == responsePieceId ? _self.responsePieceId : responsePieceId // ignore: cast_nullable_to_non_nullable
as String?,commentId: freezed == commentId ? _self.commentId : commentId // ignore: cast_nullable_to_non_nullable
as String?,commentExcerpt: freezed == commentExcerpt ? _self.commentExcerpt : commentExcerpt // ignore: cast_nullable_to_non_nullable
as String?,systemTitle: freezed == systemTitle ? _self.systemTitle : systemTitle // ignore: cast_nullable_to_non_nullable
as String?,systemMessage: freezed == systemMessage ? _self.systemMessage : systemMessage // ignore: cast_nullable_to_non_nullable
as String?,systemLink: freezed == systemLink ? _self.systemLink : systemLink // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on

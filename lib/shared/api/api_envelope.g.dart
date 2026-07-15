// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'api_envelope.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ApiErrorPayload _$ApiErrorPayloadFromJson(Map<String, dynamic> json) =>
    _ApiErrorPayload(
      code: json['code'] as String,
      message: json['message'] as String? ?? '',
      details: json['details'] as List<dynamic>? ?? const <Object?>[],
      requestId: json['requestId'] as String?,
    );

Map<String, dynamic> _$ApiErrorPayloadToJson(_ApiErrorPayload instance) =>
    <String, dynamic>{
      'code': instance.code,
      'message': instance.message,
      'details': instance.details,
      'requestId': instance.requestId,
    };

_FieldError _$FieldErrorFromJson(Map<String, dynamic> json) => _FieldError(
  field: json['field'] as String,
  rule: json['rule'] as String? ?? '',
  message: json['message'] as String? ?? '',
);

Map<String, dynamic> _$FieldErrorToJson(_FieldError instance) =>
    <String, dynamic>{
      'field': instance.field,
      'rule': instance.rule,
      'message': instance.message,
    };

_CursorMeta _$CursorMetaFromJson(Map<String, dynamic> json) => _CursorMeta(
  nextCursor: json['nextCursor'] as String?,
  hasMore: json['hasMore'] as bool? ?? false,
  limit: (json['limit'] as num?)?.toInt() ?? 20,
);

Map<String, dynamic> _$CursorMetaToJson(_CursorMeta instance) =>
    <String, dynamic>{
      'nextCursor': instance.nextCursor,
      'hasMore': instance.hasMore,
      'limit': instance.limit,
    };

_OffsetMeta _$OffsetMetaFromJson(Map<String, dynamic> json) => _OffsetMeta(
  page: (json['page'] as num?)?.toInt() ?? 1,
  limit: (json['limit'] as num?)?.toInt() ?? 20,
  total: (json['total'] as num?)?.toInt() ?? 0,
  totalPages: (json['totalPages'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$OffsetMetaToJson(_OffsetMeta instance) =>
    <String, dynamic>{
      'page': instance.page,
      'limit': instance.limit,
      'total': instance.total,
      'totalPages': instance.totalPages,
    };

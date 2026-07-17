// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'growth_series.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GrowthPoint _$GrowthPointFromJson(Map<String, dynamic> json) => _GrowthPoint(
  periodStart: json['periodStart'] as String? ?? '',
  metrics:
      (json['metrics'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, e as num),
      ) ??
      const <String, num>{},
);

Map<String, dynamic> _$GrowthPointToJson(_GrowthPoint instance) =>
    <String, dynamic>{
      'periodStart': instance.periodStart,
      'metrics': instance.metrics,
    };

_GrowthSeries _$GrowthSeriesFromJson(Map<String, dynamic> json) =>
    _GrowthSeries(
      period: json['period'] as String? ?? 'daily',
      points:
          (json['points'] as List<dynamic>?)
              ?.map((e) => GrowthPoint.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <GrowthPoint>[],
    );

Map<String, dynamic> _$GrowthSeriesToJson(_GrowthSeries instance) =>
    <String, dynamic>{
      'period': instance.period,
      'points': instance.points.map((e) => e.toJson()).toList(),
    };

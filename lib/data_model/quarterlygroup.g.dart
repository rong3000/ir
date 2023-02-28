// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quarterlygroup.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuarterlyGroup _$QuarterlyGroupFromJson(Map<String, dynamic> json) {
  return QuarterlyGroup()
    ..id = json['id'] as int
    ..groupName = json['groupName'] as String
    ..groupDescription = json['groupDescription'] as String
    ..startDatetime = json['startDatetime'] == null
        ? null
        : DateTime.parse(json['startDatetime'] as String)
    ..endDatetime = json['endDatetime'] == null
        ? null
        : DateTime.parse(json['endDatetime'] as String);
}

Map<String, dynamic> _$QuarterlyGroupToJson(QuarterlyGroup instance) =>
    <String, dynamic>{
      'id': instance.id,
      'groupName': instance.groupName,
      'groupDescription': instance.groupDescription,
      'startDatetime': instance.startDatetime?.toIso8601String(),
      'endDatetime': instance.endDatetime?.toIso8601String()
    };

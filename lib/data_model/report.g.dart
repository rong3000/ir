// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Report _$ReportFromJson(Map<String, dynamic> json) {
  return Report()
    ..id = json['id'] as int
    ..userId = json['userId'] as int
    ..statusId = json['statusId'] as int
    ..createDateTime = json['createDateTime'] == null
        ? null
        : DateTime.parse(json['createDateTime'] as String)
    ..updateDateTime = json['updateDateTime'] == null
        ? null
        : DateTime.parse(json['updateDateTime'] as String)
    ..reportName = json['reportName'] as String
    ..description = json['description'] as String
    ..receiptIds = (json['receiptIds'] as List)?.map((e) => e as int)?.toList();
}

Map<String, dynamic> _$ReportToJson(Report instance) => <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'statusId': instance.statusId,
      'createDateTime': instance.createDateTime?.toIso8601String(),
      'updateDateTime': instance.updateDateTime?.toIso8601String(),
      'reportName': instance.reportName,
      'description': instance.description,
      'receiptIds': instance.receiptIds
    };

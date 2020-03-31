// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'archivedreceiptdatarange.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ArchivedReceiptDataRange _$ArchivedReceiptDataRangeFromJson(
    Map<String, dynamic> json) {
  return ArchivedReceiptDataRange()
    ..data = (json['data'] as Map<String, dynamic>)?.map(
      (k, e) => MapEntry(k, (e as List)?.map((e) => e as int)?.toList()),
    )
    ..recordCount = json['recordCount'] as int;
}

Map<String, dynamic> _$ArchivedReceiptDataRangeToJson(
        ArchivedReceiptDataRange instance) =>
    <String, dynamic>{
      'data': instance.data,
      'recordCount': instance.recordCount
    };

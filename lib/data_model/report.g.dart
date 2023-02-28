// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReportReceipt _$ReportReceiptFromJson(Map<String, dynamic> json) {
  return ReportReceipt(receiptId: json['receiptId'] as int);
}

Map<String, dynamic> _$ReportReceiptToJson(ReportReceipt instance) =>
    <String, dynamic>{'receiptId': instance.receiptId};

Report _$ReportFromJson(Map<String, dynamic> json) {
  return Report()
    ..id = json['id'] as int
    ..reportTypeId = json['reportTypeId'] as int
    ..statusId = json['statusId'] as int
    ..createDateTime = json['createDateTime'] == null
        ? null
        : DateTime.parse(json['createDateTime'] as String)
    ..updateDateTime = json['updateDateTime'] == null
        ? null
        : DateTime.parse(json['updateDateTime'] as String)
    ..reportName = json['reportName'] as String
    ..description = json['description'] as String
    ..receipts = (json['receipts'] as List)
        ?.map((e) => e == null
            ? null
            : ReportReceipt.fromJson(e as Map<String, dynamic>))
        ?.toList()
    ..totalAmount = (json['totalAmount'] as num)?.toDouble()
    ..taxAmount = (json['taxAmount'] as num)?.toDouble()
    ..currencyCode = json['currencyCode'] as String
    ..taxReturnGroupId = json['taxReturnGroupId'] as int
    ..quarterlyGroupId = json['quarterlyGroupId'] as int
    ..workRelatedTotalAmount =
        (json['workRelatedTotalAmount'] as num)?.toDouble()
    ..workRelatedTaxAmount = (json['workRelatedTaxAmount'] as num)?.toDouble();
}

Map<String, dynamic> _$ReportToJson(Report instance) => <String, dynamic>{
      'id': instance.id,
      'reportTypeId': instance.reportTypeId,
      'statusId': instance.statusId,
      'createDateTime': instance.createDateTime?.toIso8601String(),
      'updateDateTime': instance.updateDateTime?.toIso8601String(),
      'reportName': instance.reportName,
      'description': instance.description,
      'receipts': instance.receipts,
      'totalAmount': instance.totalAmount,
      'taxAmount': instance.taxAmount,
      'currencyCode': instance.currencyCode,
      'taxReturnGroupId': instance.taxReturnGroupId,
      'quarterlyGroupId': instance.quarterlyGroupId,
      'workRelatedTotalAmount': instance.workRelatedTotalAmount,
      'workRelatedTaxAmount': instance.workRelatedTaxAmount
    };

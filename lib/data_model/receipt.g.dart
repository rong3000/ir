// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'receipt.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReceiptListItem _$ReceiptListItemFromJson(Map<String, dynamic> json) {
  return ReceiptListItem()
    ..id = json['id'] as int
    ..statusId = json['statusId'] as int
    ..categoryId = json['categoryId'] as int
    ..receiptTypeId = json['receiptTypeId'] as int
    ..uploadDatetime = json['uploadDatetime'] == null
        ? null
        : DateTime.parse(json['uploadDatetime'] as String)
    ..receiptDatetime = json['receiptDatetime'] == null
        ? null
        : DateTime.parse(json['receiptDatetime'] as String)
    ..totalAmount = (json['totalAmount'] as num)?.toDouble()
    ..companyName = json['companyName'] as String
    ..imagePath = json['imagePath'] as String
    ..productName = json['productName'] as String
    ..currencyCode = json['currencyCode'] as String
    ..notes = json['notes'] as String
    ..taxInclusive = json['taxInclusive'] as bool
    ..taxAmount = (json['taxAmount'] as num)?.toDouble()
    ..warrantyPeriod = (json['warrantyPeriod'] as num)?.toDouble()
    ..decodeStatus = json['decodeStatus'] as int
    ..altTotalAmount = (json['altTotalAmount'] as num)?.toDouble()
    ..altCurrencyCode = json['altCurrencyCode'] as String
    ..percentageOnWork = (json['percentageOnWork'] as num)?.toDouble()
    ..vendorId = json['vendorId'] as int;
}

Map<String, dynamic> _$ReceiptListItemToJson(ReceiptListItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'statusId': instance.statusId,
      'categoryId': instance.categoryId,
      'receiptTypeId': instance.receiptTypeId,
      'uploadDatetime': instance.uploadDatetime?.toIso8601String(),
      'receiptDatetime': instance.receiptDatetime?.toIso8601String(),
      'totalAmount': instance.totalAmount,
      'companyName': instance.companyName,
      'imagePath': instance.imagePath,
      'productName': instance.productName,
      'currencyCode': instance.currencyCode,
      'notes': instance.notes,
      'taxInclusive': instance.taxInclusive,
      'taxAmount': instance.taxAmount,
      'warrantyPeriod': instance.warrantyPeriod,
      'decodeStatus': instance.decodeStatus,
      'altTotalAmount': instance.altTotalAmount,
      'altCurrencyCode': instance.altCurrencyCode,
      'percentageOnWork': instance.percentageOnWork,
      'vendorId': instance.vendorId
    };

Receipt _$ReceiptFromJson(Map<String, dynamic> json) {
  return Receipt()
    ..id = json['id'] as int
    ..statusId = json['statusId'] as int
    ..categoryId = json['categoryId'] as int
    ..receiptTypeId = json['receiptTypeId'] as int
    ..uploadDatetime = json['uploadDatetime'] == null
        ? null
        : DateTime.parse(json['uploadDatetime'] as String)
    ..receiptDatetime = json['receiptDatetime'] == null
        ? null
        : DateTime.parse(json['receiptDatetime'] as String)
    ..totalAmount = (json['totalAmount'] as num)?.toDouble()
    ..companyName = json['companyName'] as String
    ..productName = json['productName'] as String
    ..currencyCode = json['currencyCode'] as String
    ..notes = json['notes'] as String
    ..taxInclusive = json['taxInclusive'] as bool
    ..taxAmount = (json['taxAmount'] as num)?.toDouble()
    ..warrantyPeriod = (json['warrantyPeriod'] as num)?.toDouble()
    ..altTotalAmount = (json['altTotalAmount'] as num)?.toDouble()
    ..altCurrencyCode = json['altCurrencyCode'] as String
    ..percentageOnWork = (json['percentageOnWork'] as num)?.toDouble()
    ..vendorId = json['vendorId'] as int
    ..decodeStatus = json['decodeStatus'] as int
    ..imagePath = json['imagePath'] as String
    ..extractedContent = json['extractedContent'] as String
    ..decodedContent = json['decodedContent'] as String
    ..submittedContent = json['submittedContent'] as String
    ..statusName = json['statusName'] as String
    ..image = json['image'] as String
    ..imageFileExtension = json['imageFileExtension'] as String
    ..statusUpdateDatetime = json['statusUpdateDatetime'] == null
        ? null
        : DateTime.parse(json['statusUpdateDatetime'] as String)
    ..productIds = (json['productIds'] as List)?.map((e) => e as int)?.toList();
}

Map<String, dynamic> _$ReceiptToJson(Receipt instance) => <String, dynamic>{
      'id': instance.id,
      'statusId': instance.statusId,
      'categoryId': instance.categoryId,
      'receiptTypeId': instance.receiptTypeId,
      'uploadDatetime': instance.uploadDatetime?.toIso8601String(),
      'receiptDatetime': instance.receiptDatetime?.toIso8601String(),
      'totalAmount': instance.totalAmount,
      'companyName': instance.companyName,
      'productName': instance.productName,
      'currencyCode': instance.currencyCode,
      'notes': instance.notes,
      'taxInclusive': instance.taxInclusive,
      'taxAmount': instance.taxAmount,
      'warrantyPeriod': instance.warrantyPeriod,
      'altTotalAmount': instance.altTotalAmount,
      'altCurrencyCode': instance.altCurrencyCode,
      'percentageOnWork': instance.percentageOnWork,
      'vendorId': instance.vendorId,
      'decodeStatus': instance.decodeStatus,
      'imagePath': instance.imagePath,
      'extractedContent': instance.extractedContent,
      'decodedContent': instance.decodedContent,
      'submittedContent': instance.submittedContent,
      'statusName': instance.statusName,
      'image': instance.image,
      'imageFileExtension': instance.imageFileExtension,
      'statusUpdateDatetime': instance.statusUpdateDatetime?.toIso8601String(),
      'productIds': instance.productIds
    };

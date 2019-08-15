// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'receipt.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReceiptListItem _$ReceiptListItemFromJson(Map<String, dynamic> json) {
  return ReceiptListItem()
    ..id = json['id'] as int
    ..userId = json['userId'] as int
    ..statusId = json['statusId'] as int
    ..categoryId = json['categoryId'] as int
    ..receiptTypeId = json['receiptTypeId'] as int
    ..uploadDatetime = json['uploadDatetime'] == null
        ? null
        : DateTime.parse(json['uploadDatetime'] as String)
    ..receiptDatatime = json['receiptDatatime'] == null
        ? null
        : DateTime.parse(json['receiptDatatime'] as String)
    ..totalAmount = (json['totalAmount'] as num)?.toDouble()
    ..companyName = json['companyName'] as String;
}

Map<String, dynamic> _$ReceiptListItemToJson(ReceiptListItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'statusId': instance.statusId,
      'categoryId': instance.categoryId,
      'receiptTypeId': instance.receiptTypeId,
      'uploadDatetime': instance.uploadDatetime?.toIso8601String(),
      'receiptDatatime': instance.receiptDatatime?.toIso8601String(),
      'totalAmount': instance.totalAmount,
      'companyName': instance.companyName
    };

Receipt _$ReceiptFromJson(Map<String, dynamic> json) {
  return Receipt()
    ..id = json['id'] as int
    ..userId = json['userId'] as int
    ..statusId = json['statusId'] as int
    ..categoryId = json['categoryId'] as int
    ..receiptTypeId = json['receiptTypeId'] as int
    ..uploadDatetime = json['uploadDatetime'] == null
        ? null
        : DateTime.parse(json['uploadDatetime'] as String)
    ..receiptDatatime = json['receiptDatatime'] == null
        ? null
        : DateTime.parse(json['receiptDatatime'] as String)
    ..totalAmount = (json['totalAmount'] as num)?.toDouble()
    ..companyName = json['companyName'] as String
    ..decodeStatus = json['decodeStatus'] as int
    ..imagePath = json['imagePath'] as String
    ..extractedContent = json['extractedContent'] as String
    ..decodedContent = json['decodedContent'] as String
    ..submittedContent = json['submittedContent'] as String
    ..statusName = json['statusName'] as String
    ..image = json['image'] as String
    ..imageCropLeft = (json['imageCropLeft'] as num)?.toDouble()
    ..imageCropTop = (json['imageCropTop'] as num)?.toDouble()
    ..imageCropWidth = (json['imageCropWidth'] as num)?.toDouble()
    ..imageCropHeight = (json['imageCropHeight'] as num)?.toDouble()
    ..statusUpdateDatetime = json['statusUpdateDatetime'] == null
        ? null
        : DateTime.parse(json['statusUpdateDatetime'] as String);
}

Map<String, dynamic> _$ReceiptToJson(Receipt instance) => <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'statusId': instance.statusId,
      'categoryId': instance.categoryId,
      'receiptTypeId': instance.receiptTypeId,
      'uploadDatetime': instance.uploadDatetime?.toIso8601String(),
      'receiptDatatime': instance.receiptDatatime?.toIso8601String(),
      'totalAmount': instance.totalAmount,
      'companyName': instance.companyName,
      'decodeStatus': instance.decodeStatus,
      'imagePath': instance.imagePath,
      'extractedContent': instance.extractedContent,
      'decodedContent': instance.decodedContent,
      'submittedContent': instance.submittedContent,
      'statusName': instance.statusName,
      'image': instance.image,
      'imageCropLeft': instance.imageCropLeft,
      'imageCropTop': instance.imageCropTop,
      'imageCropWidth': instance.imageCropWidth,
      'imageCropHeight': instance.imageCropHeight,
      'statusUpdateDatetime': instance.statusUpdateDatetime?.toIso8601String()
    };
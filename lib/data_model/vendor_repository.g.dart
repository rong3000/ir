// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vendor_repository.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Vendor _$VendorFromJson(Map<String, dynamic> json) {
  return Vendor()
    ..id = json['id'] as int
    ..userId = json['userId'] as int
    ..name = json['name'] as String
    ..vendorTypeId = json['vendorTypeId'] as int
    ..statusId = json['statusId'] as int
    ..contactName = json['contactName'] as String
    ..email = json['email'] as String
    ..phone = json['phone'] as String
    ..mobilePhone = json['mobilePhone'] as String
    ..fax = json['fax'] as String;
}

Map<String, dynamic> _$VendorToJson(Vendor instance) => <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'name': instance.name,
      'vendorTypeId': instance.vendorTypeId,
      'statusId': instance.statusId,
      'contactName': instance.contactName,
      'email': instance.email,
      'phone': instance.phone,
      'mobilePhone': instance.mobilePhone,
      'fax': instance.fax
    };

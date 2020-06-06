// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_repository.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Product _$ProductFromJson(Map<String, dynamic> json) {
  return Product()
    ..id = json['id'] as int
    ..userId = json['userId'] as int
    ..name = json['name'] as String
    ..productTypeId = json['productTypeId'] as int
    ..price = (json['price'] as num)?.toDouble()
    ..statusId = json['statusId'] as int
    ..description = json['description'] as String
    ..isTaxable = json['isTaxable'] as bool
    ..isTaxIncludedInPrice = json['isTaxIncludedInPrice'] as bool;
}

Map<String, dynamic> _$ProductToJson(Product instance) => <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'name': instance.name,
      'productTypeId': instance.productTypeId,
      'price': instance.price,
      'statusId': instance.statusId,
      'description': instance.description,
      'isTaxable': instance.isTaxable,
      'isTaxIncludedInPrice': instance.isTaxIncludedInPrice
    };

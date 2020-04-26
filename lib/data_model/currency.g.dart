// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'currency.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Currency _$CurrencyFromJson(Map<String, dynamic> json) {
  return Currency(
      id: json['id'] as int,
      code: json['code'] as String,
      name: json['name'] as String,
      symbol: json['symbol'] as String,
      country: json['country'] as String);
}

Map<String, dynamic> _$CurrencyToJson(Currency instance) => <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'name': instance.name,
      'symbol': instance.symbol,
      'country': instance.country
    };

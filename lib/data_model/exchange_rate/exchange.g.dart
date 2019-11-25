// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exchange.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Exchange _$ExchangeFromJson(Map<String, dynamic> json) {
  return Exchange(
      rates: json['rates'] == null
          ? null
          : Rate.fromJson(json['rates'] as Map<String, dynamic>),
      base: json['base'] as String,
      date: json['date'] as String);
}

Map<String, dynamic> _$ExchangeToJson(Exchange instance) => <String, dynamic>{
      'rates': instance.rates?.toJson(),
      'base': instance.base,
      'date': instance.date
    };

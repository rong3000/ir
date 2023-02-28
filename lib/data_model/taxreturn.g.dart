// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'taxreturn.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaxReturn _$TaxReturnFromJson(Map<String, dynamic> json) {
  return TaxReturn()
    ..year = json['year'] as int
    ..description = json['description'] as String
    ..receiptGroups = (json['receiptGroups'] as List)
        ?.map((e) =>
            e == null ? null : Report.fromJson(e as Map<String, dynamic>))
        ?.toList();
}

Map<String, dynamic> _$TaxReturnToJson(TaxReturn instance) => <String, dynamic>{
      'year': instance.year,
      'description': instance.description,
      'receiptGroups': instance.receiptGroups
    };

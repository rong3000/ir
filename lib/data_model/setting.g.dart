// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'setting.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Setting _$SettingFromJson(Map<String, dynamic> json) {
  return Setting()
    ..id = json['id'] as int
    ..userId = json['userId'] as int
    ..key = json['key'] as String
    ..value = json['value'] as String;
}

Map<String, dynamic> _$SettingToJson(Setting instance) => <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'key': instance.key,
      'value': instance.value
    };

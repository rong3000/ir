// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'newstext.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NewsText _$NewsTextFromJson(Map<String, dynamic> json) {
  return NewsText()
    ..title = json['title'] as String
    ..content = json['content'] as String
    ..localeCode = json['localeCode'] as String;
}

Map<String, dynamic> _$NewsTextToJson(NewsText instance) => <String, dynamic>{
      'title': instance.title,
      'content': instance.content,
      'localeCode': instance.localeCode
    };

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'newsitem.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NewsItem _$NewsItemFromJson(Map<String, dynamic> json) {
  return NewsItem()
    ..id = json['id'] as int
    ..expiryDate = json['expiryDate'] == null
        ? null
        : DateTime.parse(json['expiryDate'] as String)
    ..touchAction = json['touchAction'] as String
    ..imageUrl = json['imageUrl'] as String
    ..text = json['text'] == null
        ? null
        : NewsText.fromJson(json['text'] as Map<String, dynamic>);
}

Map<String, dynamic> _$NewsItemToJson(NewsItem instance) => <String, dynamic>{
      'id': instance.id,
      'expiryDate': instance.expiryDate?.toIso8601String(),
      'touchAction': instance.touchAction,
      'imageUrl': instance.imageUrl,
      'text': instance.text
    };

import 'package:json_annotation/json_annotation.dart';

part 'newstext.g.dart';

@JsonSerializable()
class NewsText {
  String title;
  String content;
  String localeCode;

  NewsText();

  factory NewsText.fromJson(Map<String, dynamic> json) =>
      _$NewsTextFromJson(json);

  Map<String, dynamic> toJson() => _$NewsTextToJson(this);
}



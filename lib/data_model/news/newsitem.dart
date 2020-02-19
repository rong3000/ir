import 'package:intelligent_receipt/data_model/news/newstext.dart';
import 'package:json_annotation/json_annotation.dart';

part 'newsitem.g.dart';

/// An annotation for the code generator to know that this class needs the
/// JSON serialization logic to be generated.
@JsonSerializable()

// Used for receipt list
class NewsItem {
  int id;

  DateTime expiryDate;
  String touchAction;
  String imageUrl;
  NewsText text;
  NewsItem();

  factory NewsItem.fromJson(Map<String, dynamic> json) =>
      _$NewsItemFromJson(json);

  Map<String, dynamic> toJson() => _$NewsItemToJson(this);
}

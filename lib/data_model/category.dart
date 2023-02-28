import 'package:json_annotation/json_annotation.dart';

part 'category.g.dart';

/// An annotation for the code generator to know that this class needs the
/// JSON serialization logic to be generated.
@JsonSerializable()

// Used for receipt list
class Category {
  int id;
  String categoryName;

  Category();

  factory Category.fromJason(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);
  Map<String, dynamic> toJson() => _$CategoryToJson(this);

}

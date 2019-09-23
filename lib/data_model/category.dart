import 'package:flutter/material.dart' as prefix0;
import 'package:json_annotation/json_annotation.dart';

import 'enums.dart';

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

  //Dev only ATM
  Category.fromParams(int id, String name)
      : id = id,
        categoryName = name;
}

// DEv placeholder till server side is up
var categoryList = [
  Category.fromParams(1, 'Material'),
  Category.fromParams(2, 'Travel'),
  Category.fromParams(3, 'Undecided'),
];

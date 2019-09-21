import 'package:json_annotation/json_annotation.dart';

part 'currency.g.dart';

/// An annotation for the code generator to know that this class needs the
/// JSON serialization logic to be generated.
@JsonSerializable()

// Used for receipt list
class Currency {
  int id;
  String code;
  String name;
  String symbol;
  String country;

  Currency();

  factory Currency.fromJason(Map<String, dynamic> json) => _$CurrencyFromJson(json);
  Map<String, dynamic> toJson() => _$CurrencyToJson(this);
}

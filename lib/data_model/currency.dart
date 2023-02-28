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

  Currency({this.id = 0, this.code = "",this.name = "", this.symbol = "", this.country = ""});

  factory Currency.fromJason(Map<String, dynamic> json) => _$CurrencyFromJson(json);
  Map<String, dynamic> toJson() => _$CurrencyToJson(this);
}

Currency CURRENCY_AUS = Currency(id: 1, code: "AUD", name: "Australian Dollars", symbol: "\$", country: "Australia");

import 'rate.dart';
import 'package:json_annotation/json_annotation.dart';
part 'exchange.g.dart';

@JsonSerializable(explicitToJson: true)
class Exchange {
  Rate rates;
  String base;
  String date;

  Exchange({this.rates, this.base, this.date});

  factory Exchange.fromJson(Map<String, dynamic> json) => _$ExchangeFromJson(json);

  Map<String, dynamic> toJson() => _$ExchangeToJson(this);
}
import 'package:json_annotation/json_annotation.dart';
import 'report.dart';

part 'taxreturn.g.dart';

/// An annotation for the code generator to know that this class needs the
/// JSON serialization logic to be generated.
@JsonSerializable()
class TaxReturn {
  int year;
  String description;
  List<Report> receiptGroups;

  TaxReturn();

  factory TaxReturn.fromJason(Map<String, dynamic> json) => _$TaxReturnFromJson(json);
  Map<String, dynamic> toJson() => _$TaxReturnToJson(this);
}


import 'package:json_annotation/json_annotation.dart';

part 'archivedreceiptdatarange.g.dart';

@JsonSerializable()
class ArchivedReceiptDataRange {
  Map<String, List<int>> data;
  int recordCount;

  ArchivedReceiptDataRange();
  
  factory ArchivedReceiptDataRange.fromJson(Map<String, dynamic> json) =>
      _$ArchivedReceiptDataRangeFromJson(json);

  Map<String, dynamic> toJson() => _$ArchivedReceiptDataRangeToJson(this);
}

import 'package:json_annotation/json_annotation.dart';
import 'report.dart';

part 'taxreturn.g.dart';

/// An annotation for the code generator to know that this class needs the
/// JSON serialization logic to be generated.
@JsonSerializable()
class TaxReturn {
  int year;
  String description;
  DateTime startDatetime = null;
  DateTime endDatetime = null;
  List<Report> receiptGroups;

  TaxReturn();

  // xxx This is a temporary change, will put the start and end end date time into DB later
  DateTime getStartDateTime() {
    if (startDatetime == null) {
      return DateTime.parse((year-1).toString() + "-07-01 00:00:00");
    }
    return startDatetime;
  }

  DateTime getEndDatetime() {
    if (endDatetime == null) {
      return DateTime.parse(year.toString() + "-06-30 23:59:59");
    }
    return endDatetime;
  }

  Report getReportByTaxReturnGroupId(int taxReturnGroupId) {
    Report report = null;
    for (int i = 0; i < receiptGroups.length; i++) {
      if (receiptGroups[i].taxReturnGroupId == taxReturnGroupId) {
        report = receiptGroups[i];
        break;
      }
    }
    return report;
  }

  factory TaxReturn.fromJson(Map<String, dynamic> json) => _$TaxReturnFromJson(json);
  Map<String, dynamic> toJson() => _$TaxReturnToJson(this);
}

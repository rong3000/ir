import 'package:json_annotation/json_annotation.dart';
import 'receipt_repository.dart';

part 'report.g.dart';

/// An annotation for the code generator to know that this class needs the
/// JSON serialization logic to be generated.
@JsonSerializable()

// Used for receipt list
class Report {
  int id;
  int userId;
  int statusId;
  DateTime createDateTime;
  DateTime updateDateTime;
  String reportName;
  String description;
  List<int> receiptIds;

  Report();

  factory Report.fromJason(Map<String, dynamic> json) => _$ReportFromJson(json);
  Map<String, dynamic> toJson() => _$ReportToJson(this);

  double getTotalAmount(ReceiptRepository receiptRepository) {
    double totalAmount = 0;
    for (var i = 0; i < receiptIds.length; i++) {
      ReceiptListItem receiptListItem = receiptRepository.getReceiptItem(receiptIds[i]);
      totalAmount += receiptListItem?.totalAmount;
    }
    return totalAmount;
  }

  List<ReceiptListItem> getReceiptList(ReceiptRepository receiptRepository) {
    List<ReceiptListItem> receiptList = new List<ReceiptListItem>();
    for (var i = 0; i < receiptIds.length; i++) {
      ReceiptListItem receiptListItem = receiptRepository.getReceiptItem(receiptIds[i]);
      if (receiptListItem != null) {
        receiptList.add(receiptListItem);
      }
    }
    return receiptList;
  }
}

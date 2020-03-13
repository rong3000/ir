import 'package:json_annotation/json_annotation.dart';
import 'receipt_repository.dart';

part 'report.g.dart';

/// An annotation for the code generator to know that this class needs the
/// JSON serialization logic to be generated.
@JsonSerializable()
class ReportReceipt {
  int receiptId;
  int percentageOnWork;

  ReportReceipt({int receiptId : 0, int percentageOnWork: 100}) {
    this.receiptId = receiptId;
    this.percentageOnWork = percentageOnWork;
  }

  factory ReportReceipt.fromJson(Map<String, dynamic> json) => _$ReportReceiptFromJson(json);
  Map<String, dynamic> toJson() => _$ReportReceiptToJson(this);
}

// Used for receipt list
@JsonSerializable()
class Report {
  int id;
  int statusId;
  DateTime createDateTime;
  DateTime updateDateTime;
  String reportName;
  String description;
  List<ReportReceipt> receipts;
  double totalAmount;
  String currencyCode;
  int taxReturnGroupId;

  Report();

  factory Report.fromJson(Map<String, dynamic> json) => _$ReportFromJson(json);
  Map<String, dynamic> toJson() => _$ReportToJson(this);

  double getTotalAmount(ReceiptRepository receiptRepository) {
    double totalAmount = 0;
    for (var i = 0; i < receipts.length; i++) {
      ReceiptListItem receiptListItem = receiptRepository.getReceiptItem(receipts[i].receiptId);
      totalAmount += (receiptListItem != null) ? receiptListItem.totalAmount : 0;
    }
    return totalAmount;
  }

  List<ReceiptListItem> getReceiptList(ReceiptRepository receiptRepository) {
    List<ReceiptListItem> receiptList = new List<ReceiptListItem>();
    for (var i = 0; i < receipts.length; i++) {
      ReceiptListItem receiptListItem = receiptRepository.getReceiptItem(receipts[i].receiptId);
      if (receiptListItem != null) {
        receiptList.add(receiptListItem);
      }
    }
    return receiptList;
  }

  int getValidReceiptCount(ReceiptRepository receiptRepository) {
    int count = 0;
    for (var i = 0; i < receipts.length; i++) {
      ReceiptListItem receiptListItem = receiptRepository.getReceiptItem(receipts[i].receiptId);
      if (receiptListItem != null) {
        count++;
      }
    }
    return count;
  }
}

import 'package:intelligent_receipt/data_model/quarterlygroup.dart';
import 'package:intelligent_receipt/user_repository.dart';
import 'package:json_annotation/json_annotation.dart';
import 'receipt_repository.dart';

part 'report.g.dart';

/// An annotation for the code generator to know that this class needs the
/// JSON serialization logic to be generated.
@JsonSerializable()
class ReportReceipt {
  int receiptId;

  ReportReceipt({int receiptId : 0}) {
    this.receiptId = receiptId;
  }

  factory ReportReceipt.fromJson(Map<String, dynamic> json) => _$ReportReceiptFromJson(json);
  Map<String, dynamic> toJson() => _$ReportReceiptToJson(this);
}

// Used for receipt list
@JsonSerializable()
class Report {
  int id = 0;
  int statusId;
  DateTime createDateTime;
  DateTime updateDateTime;
  String reportName = "";
  String description = "";
  List<ReportReceipt> receipts;
  double totalAmount;
  double taxAmount;
  String currencyCode = "";
  int taxReturnGroupId = 0;
  int quarterlyGroupId = 0;
  double workRelatedTotalAmount = 0;
  double workRelatedTaxAmount = 0;

  Report();

  bool isNormalReport() {
    return (taxReturnGroupId == 0) && (quarterlyGroupId == 0);
  }

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

  void rePopulateReceipsForQuarterlyGroup(UserRepository userRepository, int quarterlyGroupId) {
    // get quarterly group
    receipts.clear();
    QuarterlyGroup quarterlyGroup = userRepository.quarterlyGroupRepository.getQuarterGroupById(quarterlyGroupId);
    if (quarterlyGroup != null) {
      List<ReceiptListItem> receiptItems = userRepository.receiptRepository.getReceiptItemsBetweenDateRange(quarterlyGroup.startDatetime, quarterlyGroup.endDatetime);
      for (int i = 0; i < receiptItems.length; i++) {
        receipts.add(new ReportReceipt(receiptId: receiptItems[i].id));
      }
    }
  }
}

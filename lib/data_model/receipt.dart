import 'package:json_annotation/json_annotation.dart';

part 'receipt.g.dart';

/// An annotation for the code generator to know that this class needs the
/// JSON serialization logic to be generated.
@JsonSerializable()

// Used for receipt list
class ReceiptListItem {
  int id;
  int statusId;
  int categoryId;
  int receiptTypeId;
  DateTime uploadDatetime;
  DateTime receiptDatetime;
  double totalAmount;
  String companyName;
  String imagePath;
  String productName;
  String currencyCode;
  String notes; 
  bool taxInclusive;
  double taxAmount;
  double warrantyPeriod;
  int decodeStatus;
  double altTotalAmount;
  String altCurrencyCode;
  double percentageOnWork = 100;
  int vendorId;

  ReceiptListItem() {
    id = 0;
    receiptDatetime = DateTime.now();
    receiptTypeId = 0;
    productName = "";
    taxInclusive = true;
    totalAmount = 0;
    taxAmount = 0;
    companyName = "";
    warrantyPeriod = 0;
    notes = "";
    categoryId = 1;
    altTotalAmount = 0;
    vendorId = 0;
  }

  factory ReceiptListItem.fromJason(Map<String, dynamic> json) => _$ReceiptListItemFromJson(json);
  Map<String, dynamic> toJson() => _$ReceiptListItemToJson(this);
}

@JsonSerializable()
class Receipt extends ReceiptListItem {
  int decodeStatus;
  String imagePath;
  String extractedContent;
  String decodedContent;
  String submittedContent;
  String statusName;
  String image;
  String imageFileExtension;
  DateTime statusUpdateDatetime;
  List<int> productIds;

  Receipt() : super();

  factory Receipt.fromJason(Map<String, dynamic> json) => _$ReceiptFromJson(json);
  Map<String, dynamic> toJson() => _$ReceiptToJson(this);
}
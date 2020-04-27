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
  int percentageOnWork = 100;

  ReceiptListItem();

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

  Receipt() : super();

  factory Receipt.fromJason(Map<String, dynamic> json) => _$ReceiptFromJson(json);
  Map<String, dynamic> toJson() => _$ReceiptToJson(this);
}
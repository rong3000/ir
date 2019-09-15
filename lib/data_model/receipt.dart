import 'package:intelligent_receipt/data_model/report_repository.dart';
import 'package:json_annotation/json_annotation.dart';

part 'receipt.g.dart';

/// An annotation for the code generator to know that this class needs the
/// JSON serialization logic to be generated.
@JsonSerializable()

// Used for receipt list
class ReceiptListItem {
  int id;
  int userId;
  int statusId;
  int categoryId;
  int receiptTypeId;
  DateTime uploadDatetime;
  DateTime receiptDatetime;
  double totalAmount;
  String companyName;
  String imagePath;
  String productName; // Not yet in DB
  String currencyCode; //not yet in DB
  String notes; //not yet in DB

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
  double imageCropLeft;
  double imageCropTop;
  double imageCropWidth;
  double imageCropHeight;
  DateTime statusUpdateDatetime;

  Receipt() : super();

  factory Receipt.fromJason(Map<String, dynamic> json) => _$ReceiptFromJson(json);
  Map<String, dynamic> toJson() => _$ReceiptToJson(this);
}
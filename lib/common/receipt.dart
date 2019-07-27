
// Used for receipt list
class ReceiptListItem {
  int id;
  int statusId;
  int categoryId;
  DateTime uploadDatetime;
  DateTime receiptDatatime;
  double totalAmount;
  String companyName;

  ReceiptListItem();

  ReceiptListItem.fromJason(Map json)
      : id = json['id'],
        statusId = json['id'],
        uploadDatetime = DateTime.parse(json['uploadDatetime']),
        receiptDatatime = DateTime.parse(json['receiptDatatime']),
        totalAmount = json['totalAmount'],
        companyName = json['companyName'],
        categoryId = json['categoryId'];
}

class Receipt extends ReceiptListItem {
  bool hasWarranty = false;

  Receipt() : super();

  Receipt.fromJason(Map json)
      : hasWarranty = json['hasWarranty'],
        super.fromJason(json);
}
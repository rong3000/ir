
// Used for receipt list
class ReceiptCommon {
  int id;
  DateTime summittedTime;
  double amount;
  String company;
  int categoryId;

  ReceiptCommon();

  ReceiptCommon.fromJason(Map json)
      : id = json['id'],
        summittedTime = json['summittedTime'],
        amount = json['amount'],
        company = json['company'],
        categoryId = json['categoryId'];
}

class Receipt extends ReceiptCommon {
  bool hasWarranty = false;

  Receipt() : super();

  Receipt.fromJason(Map json)
      : hasWarranty = json['hasWarranty'],
        super.fromJason(json);
}
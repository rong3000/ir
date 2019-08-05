enum ReceeiptStatusType
{
  Unknown,
  Uploaded,
  Assigned,
  Decoded,
  Reviewed,
  Deleted
}

enum DecodeStatusType
{
  Unknown,
  Success,
  ExtractTextFailed,
  UnrecognizedFormat
}

// Used for receipt list
class ReceiptListItem {
  int id;
  int userId;
  int statusId;
  int categoryId;
  int receiptTypeId;
  DateTime uploadDatetime;
  DateTime receiptDatatime;
  double totalAmount;
  String companyName;

  ReceiptListItem();

  ReceiptListItem.fromJason(Map json)
      : id = json['id'],
        userId = json['userId'],
        receiptTypeId = json['receiptTypeId'],
        uploadDatetime = json['uploadDatetime'] != null ? DateTime.parse(json['uploadDatetime']) : null,
        receiptDatatime = json['receiptDatatime'] != null ? DateTime.parse(json['receiptDatatime']) : null,
        totalAmount = json['totalAmount'],
        companyName = json['companyName'],
        categoryId = json['categoryId'],
        statusId = json['statusId'];
}

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

  Receipt.fromJason(Map json)
      : decodeStatus = json['decodeStatus'],
        imagePath = json['imagePath'],
        extractedContent = json['extractedContent'],
        decodedContent = json['decodedContent'],
        submittedContent = json['submittedContent'],
        statusName = json['statusName'],
        image = json['image'],
        imageCropLeft = json['imageCropLeft'],
        imageCropTop = json['imageCropTop'],
        imageCropWidth = json['imageCropWidth'],
        imageCropHeight = json['imageCropHeight'],
        statusUpdateDatetime = DateTime.parse(json['statusUpdateDatetime']),
        super.fromJason(json);
}
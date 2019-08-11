import 'enums.dart';

class DataResult
{
  bool success = false;
  int messageCode;
  String message;
  dynamic obj;

  DataResult(this.success, this.message);

  DataResult.success(dynamic newObj) {
    success = true;
    obj = newObj;
  }

  DataResult.fail({int msgCode: MessageCode.UNKNOWN, String msg : ""}) {
    success = false;
    messageCode = msgCode;
    message = msg;
  }

  DataResult.fromJason(Map json)
      : success = json['isSuccess'],
        messageCode = json['messageCode'],
        message = json['message'],
        obj = json['obj'];

}
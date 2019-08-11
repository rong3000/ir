import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path/path.dart';
import 'package:async/async.dart';
import 'dart:io';
import 'data_result.dart';
import 'message_code.dart';
export 'data_result.dart';

class Urls {
  static String ServiceBaseUrl = "http://10.1.1.218:3001/";

  // Receipt related APIs
  static String GetReceipts = ServiceBaseUrl + "Receipt/GetReceipts/";
  static String GetReceipt = ServiceBaseUrl + "Receipt/GetReceiptByReceiptId/";
  static String UpdateReceipt = ServiceBaseUrl + "Receipt/UpdateReceipt";
  static String UploadReceiptImages = ServiceBaseUrl + "Receipt/UploadReceiptImages/1/";
  static String DeleteReceipts = ServiceBaseUrl + "Receipt/DeleteReceipts";

  // Category related APIs
  static String GetCategories = ServiceBaseUrl + "Settings/GetCategories/";
  static String AddCategory = ServiceBaseUrl + "Settings/AddCategory/";
  static String UpdateCategory = ServiceBaseUrl + "Settings/UpdateCategory/";
  static String DeleteCategory = ServiceBaseUrl + "Settings/DeleteCategory/";
}

const int default_timeout = 2000; // millisecons

/// Url: webservice URL
/// token: token string
/// body: the body Json string, which will be sent to the host
Future<DataResult> webservicePost(String url, String token, String body, {int timeout: default_timeout}) async
{
  final headers = {
//    "Authorization": "Bearer " + token,
    "accept": "application/json",
    "Content-type": "application/json",
  };

  try {
    http.Response  response = await http.post(url, headers: headers, body: body).timeout(Duration(milliseconds: timeout));
    if (response.statusCode == 200) {
      return DataResult.fromJason(json.decode(response.body));
    } else {
      // Log an error
      return DataResult.fail(msgCode: response.statusCode, msg: "HTTP response code: " + response.statusCode.toString());
    }
  } on TimeoutException catch (_) {
    return DataResult.fail(msgCode: MessageCode.TIMEOUT, msg: "Time out!");
  } catch (e) {
    // Log an error
    return DataResult.fail(msgCode: MessageCode.UNKNOWN, msg: e.toString());
  }
}

/// Url: webservice URL
/// token: token string
/// body: the body Json string, which will be sent to the host
Future<DataResult> webservicePut(String url, String token, String body, {int timeout: default_timeout}) async
{
  final headers = {
    "Authorization": "Bearer " + token,
    "accept": "application/json",
    "Content-type": "application/json",
  };

  try {
    http.Response  response = await http.put(url, headers: headers, body: body).timeout(Duration(milliseconds: timeout));
    if (response.statusCode == 200) {
      return DataResult.fromJason(json.decode(response.body));
    } else {
      // Log an error
      return DataResult.fail(msgCode: response.statusCode, msg: "HTTP response code: " + response.statusCode.toString());
    }
  } on TimeoutException catch (_) {
    return DataResult.fail(msgCode: MessageCode.TIMEOUT, msg: "Time out!");
  } catch (e) {
    // Log an error
    return DataResult.fail(msgCode: MessageCode.UNKNOWN, msg: e.toString());
  }
}

/// Url: webservice URL
/// token: token string
/// body: the body Json string, which will be sent to the host
Future<DataResult> webserviceGet(String url, String token, {int timeout: default_timeout}) async
{
  final headers = {
    //"Authorization": "Bearer " + token,
    "accept": "application/json",
    "Content-type": "application/json",
  };

  try {
    http.Response  response = await http.get(url, headers: headers).timeout(Duration(milliseconds: timeout));
    if (response.statusCode == 200) {
      return DataResult.fromJason(json.decode(response.body));
    } else {
      // Log an error
      return DataResult.fail(msgCode: response.statusCode, msg: "HTTP response code: " + response.statusCode.toString());
    }
  } on TimeoutException catch (_) {
    return DataResult.fail(msgCode: MessageCode.TIMEOUT, msg: "Time out!");
  } catch (e) {
    // Log an error
    return DataResult.fail(msgCode: MessageCode.UNKNOWN, msg: e.toString());
  }
}

Future<DataResult> uploadFile(String url, String token, File imageFile, {int timeout: default_timeout}) async {
  try {
    var stream = new http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
    var length = await imageFile.length();

    var uri = Uri.parse(url);

    var request = new http.MultipartRequest("POST", uri);
    var multipartFile = new http.MultipartFile('file', stream, length,
        filename: basename(imageFile.path));
    //contentType: new MediaType('image', 'png'));

    request.files.add(multipartFile);
    var response = await request.send().timeout(Duration(milliseconds: timeout));
    print(response.statusCode);
    if (response.statusCode == 200) {
      return DataResult.fromJason(json.decode(await response.stream.bytesToString()));
    } else {
      // Log an error
      return DataResult.fail(msgCode: response.statusCode, msg: "HTTP response code: " + response.statusCode.toString());
    }
  } on TimeoutException catch (_) {
    return DataResult.fail(msgCode: MessageCode.TIMEOUT, msg: "Time out!");
  } catch (e) {
    // Log an error
    return DataResult.fail(msgCode: MessageCode.UNKNOWN, msg: e.toString());
  }
}

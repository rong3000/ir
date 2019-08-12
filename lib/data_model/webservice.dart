import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:path/path.dart';
import 'package:async/async.dart';
import 'dart:io';

class Urls {
  static String ServiceBaseUrl = "http://35.244.127.111";

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

class WebServiceResult
{
  bool success = false;
  int messageCode;
  String message;
  Object jasonObj;

  WebServiceResult(this.success, this.message);

  WebServiceResult.fromJason(Map json)
      : success = json['isSuccess'],
        messageCode = json['messageCode'],
        message = json['message'],
        jasonObj = json['obj'];

}

/// Url: webservice URL
/// token: token string
/// body: the body Json string, which will be sent to the host
Future<WebServiceResult> webservicePost(String url, String token, String body) async
{
  final headers = {
//    "Authorization": "Bearer " + token,
    "accept": "application/json",
    "Content-type": "application/json",
  };

  try {
    http.Response  response = await http.post(url, headers: headers, body: body);
    if (response.statusCode == 200) {
      return WebServiceResult.fromJason(json.decode(response.body));
    } else {
      // Log an error
      return WebServiceResult(false, response.statusCode.toString());
    }
  } catch (e) {
    // Log an error
    return WebServiceResult(false, e.toString());
  }
}

/// Url: webservice URL
/// token: token string
/// body: the body Json string, which will be sent to the host
Future<WebServiceResult> webservicePut(String url, String token, String body) async
{
  final headers = {
    "Authorization": "Bearer " + token,
    "accept": "application/json",
    "Content-type": "application/json",
  };

  try {
    http.Response  response = await http.put(url, headers: headers, body: body);
    if (response.statusCode == 200) {
      return WebServiceResult.fromJason(json.decode(response.body));
    } else {
      // Log an error
      return WebServiceResult(false, response.statusCode.toString());
    }
  } catch (e) {
    // Log an error
    return WebServiceResult(false, e.toString());
  }
}

/// Url: webservice URL
/// token: token string
/// body: the body Json string, which will be sent to the host
Future<WebServiceResult> webserviceGet(String url, String token) async
{
  final headers = {
    //"Authorization": "Bearer " + token,
    "accept": "application/json",
    "Content-type": "application/json",
  };

  try {
    http.Response  response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      return WebServiceResult.fromJason(json.decode(response.body));
    } else {
      // Log an error
      return WebServiceResult(false, response.statusCode.toString());
    }
  } catch (e) {
    // Log an error
    return WebServiceResult(false, e.toString());
  }
}

Future<WebServiceResult> uploadFile(String url, String token, File imageFile) async {
  try {
    var stream = new http.ByteStream(DelegatingStream.typed(imageFile.openRead()));
    var length = await imageFile.length();

    var uri = Uri.parse(url);

    var request = new http.MultipartRequest("POST", uri);
    var multipartFile = new http.MultipartFile('file', stream, length,
        filename: basename(imageFile.path));
    //contentType: new MediaType('image', 'png'));

    request.files.add(multipartFile);
    var response = await request.send();
    print(response.statusCode);
    if (response.statusCode == 200) {
      return WebServiceResult.fromJason(json.decode(await response.stream.bytesToString()));
    } else {
      // Log an error
      return WebServiceResult(false, response.statusCode.toString());
    }
  } catch (e) {
    // Log an error
    return WebServiceResult(false, e.toString());
  }
}

import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Urls {
  static String ServiceBaseUrl = "http://10.1.1.218:3001/";

  // Receipt related APIs
  static String GetReceipts = ServiceBaseUrl + "Receipt/GetReceipts/";
  static String GetReceipt = ServiceBaseUrl + "Receipt/GetReceiptByReceiptId/";
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

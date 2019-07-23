import 'dart:async';
import 'package:http/http.dart' as http;

class Urls {
  static String ServiceBaseUrl = "http://localhost:3001/";

  // Receipt related APIs
  static String GetReceipts = ServiceBaseUrl + "ReceiptTab/GetReceiptsByCompanyId/";
}


class WebServiceResult
{
  bool success = false;
  String response;
  WebServiceResult(this.success, this.response);
}

/// Url: webservice URL
/// token: token string
/// body: the body Json string, which will be sent to the host
Future<WebServiceResult> webservicePost(String url, String token, String body) async
{
  final headers = {
    "Authorization": "Bearer " + token,
    "accept": "application/json",
    "Content-type": "application/json",
  };

  try {
    http.Response  response = await http.post(url, headers: headers, body: body);
    if (response.statusCode == 200) {
      return WebServiceResult(true, response.body);
    } else {
      // Log an error
      return WebServiceResult(false, response.body);
    }
  } catch (e) {
    // Log an error
    return WebServiceResult(false, "");
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
      return WebServiceResult(true, response.body);
    } else {
      // Log an error
      return WebServiceResult(false, response.body);
    }
  } catch (e) {
    // Log an error
    return WebServiceResult(false, "");
  }
}

/// Url: webservice URL
/// token: token string
/// body: the body Json string, which will be sent to the host
Future<WebServiceResult> webserviceGet(String url, String token) async
{
  final headers = {
    "Authorization": "Bearer " + token,
    "accept": "application/json",
    "Content-type": "application/json",
  };

  try {
    http.Response  response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      return WebServiceResult(true, response.body);
    } else {
      // Log an error
      return WebServiceResult(false, response.body);
    }
  } catch (e) {
    // Log an error
    return WebServiceResult(false, "");
  }
}

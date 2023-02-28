import 'package:intelligent_receipt/data_model/exchange_rate/exchange.dart';
import 'package:intelligent_receipt/data_model/webservice.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'dart:convert';
import 'package:synchronized/synchronized.dart';
import 'package:http/http.dart' as http;

class ExchangeRateRepository {
  bool _dataFetched = false;
  Lock _lock = new Lock();

  Future<Exchange> getExchangeRate(DateTime receiptDatetime, String baseCurrencyCode) async {
    final response =
        await http.get(Urls.GetExchangeRate + DateFormat().add_yMd().format(receiptDatetime.toLocal()).toString() + "?base=" + baseCurrencyCode);
    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON.
      return Exchange.fromJson(json.decode(response.body));
    } else {
      // If that response was not OK, throw an error.
      throw Exception('Failed to load post');
    }
  }

}

import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intelligent_receipt/data_model/action_with_lable.dart';
import 'package:intelligent_receipt/data_model/data_result.dart';
import 'package:intelligent_receipt/data_model/enums.dart';
import 'package:intelligent_receipt/data_model/exchange_rate/exchange.dart';
import 'package:intelligent_receipt/data_model/exchange_rate/rate.dart';
import 'package:intelligent_receipt/data_model/receipt.dart';
import 'package:intelligent_receipt/data_model/report.dart';
import 'package:intelligent_receipt/data_model/setting_repository.dart';
import 'package:intelligent_receipt/receipt/receipt_card/receipt_card.dart';
import 'package:intelligent_receipt/receipt/receipt_list/receipt_list.dart';
import 'package:intelligent_receipt/report/add_receipts_screen/add_receipts_screen.dart';
import 'package:intelligent_receipt/user_repository.dart';
import 'package:intl/intl.dart';

import 'report_button.dart';
import 'package:http/http.dart' as http;
import 'package:intelligent_receipt/data_model/webservice.dart';

class AddReportScreen extends StatefulWidget {
  final String title;
  final UserRepository _userRepository;
  AddReportScreen(
      {Key key, @required UserRepository userRepository, this.title})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(key: key) {}

  @override
  _AddReportScreenState createState() => new _AddReportScreenState();
}

class _AddReportScreenState extends State<AddReportScreen> {
  UserRepository get _userRepository => widget._userRepository;
  TextEditingController editingController = TextEditingController();
  List<Currency> duplicateItems;
  Currency selectedCurrency;
  bool show;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  double _tempAmount;

  bool get isPopulated => _emailController.text.isNotEmpty;

  bool isLoginButtonEnabled() {
    return isPopulated;
  }

  var items = List<Currency>();
  String _totalAmount;
  Currency _currency = new Currency();

  @override
  void initState() {
    duplicateItems = _userRepository.settingRepository.getCurrencies();
    items.addAll(duplicateItems);
    super.initState();
  }

  void filterSearchResults(String query) {
    List<Currency> dummySearchList = List<Currency>();
    dummySearchList.addAll(duplicateItems);
    if (query.isNotEmpty) {
      List<Currency> dummyListData = List<Currency>();
      dummySearchList.forEach((item) {
        if (item.name.toLowerCase().contains(query.toLowerCase())) {
          dummyListData.add(item);
        }
      });
      setState(() {
        items.clear();
        items.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        items.clear();
        items.addAll(duplicateItems);
      });
    }
  }

  Future<void> _setAsDefaultCurrency(int currencyId) async {
    DataResult dataResult =
        await _userRepository.settingRepository.setDefaultCurrency(currencyId);
    setState(() {
      selectedCurrency = _userRepository.settingRepository.getDefaultCurrency();
    });
    Navigator.pop(context);
  }

  void removeAction(int inputId) {
    int toBeRemoved;
    int amountToBeRemoved;
    for (int i = 0;
        i < _userRepository.receiptRepository.cachedReceiptItems.length;
        i++) {
      if (_userRepository.receiptRepository.cachedReceiptItems[i].id ==
          inputId) {
        toBeRemoved = i;
      }
    }

    for (int i = 0;
    i < _userRepository.receiptRepository.cachedReceiptItemsAmount.length;
    i++) {
      if (_userRepository.receiptRepository.cachedReceiptItemsAmount[i].id ==
          inputId) {
        amountToBeRemoved = i;
      }
    }

    _userRepository.receiptRepository.candidateReceiptItems
        .add(_userRepository.receiptRepository.cachedReceiptItems[toBeRemoved]);
    _userRepository.receiptRepository.cachedReceiptItems.removeAt(toBeRemoved);
    _userRepository.receiptRepository.cachedReceiptItemsAmount.removeAt(amountToBeRemoved);
    setState(() {});
  }

  Future<Exchange> fetchExchange() async {
    final response =
        await http.get('https://api.exchangeratesapi.io/2019-11-10?base=AUD');

    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON.
      return Exchange.fromJson(json.decode(response.body));
    } else {
      // If that response was not OK, throw an error.
      throw Exception('Failed to load post');
    }
  }

  Future<Exchange> getExchangeRateFromServer(DateTime receiptDatetime, String baseCurrencyCode) async {
    final response =
    await http.get(Urls.GetExchangeRate + DateFormat("yyyy-MM-dd").format(receiptDatetime.toLocal()).toString() + "?base=" + baseCurrencyCode);
    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON.
      return Exchange.fromJson(json.decode(response.body));
    } else {
      // If that response was not OK, throw an error.
      throw Exception('Failed to load exchange rate from server');
    }
  }

  Future<void> calculateExchange(double amount, DateTime receiptDatetime, String baseCurrencyCode, String targetCurrencyCode) async {
    Exchange exchange = await getExchangeRateFromServer(receiptDatetime, baseCurrencyCode);
    _tempAmount += (amount / exchange.rates.getRate(targetCurrencyCode));
    _totalAmount =
        _tempAmount
            .toStringAsFixed(
            2);
  }

  @override
  Widget build(BuildContext context) {
//    duplicateItems = _userRepository.settingRepository.getCurrencies();

    List<ActionWithLabel> actions = [];
    ActionWithLabel d = new ActionWithLabel();
    d.action = removeAction;
    d.label = 'Remove';
    actions.add(d);
    _tempAmount = 0;
    for (var i = 0;
    i <
        _userRepository
            .receiptRepository
            .cachedReceiptItemsAmount
            .length;
    i++) {
      _tempAmount += (_userRepository
          .receiptRepository
          .cachedReceiptItemsAmount[i]?.amount);

    }
    _totalAmount =
        _tempAmount
            .toStringAsFixed(
            2);
    return new Scaffold(
      appBar: new AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 3,
              child: Form(
                child: ListView(
                  children: <Widget>[
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        icon: Icon(Icons.title),
                        labelText: 'Receipt Group Name',
                      ),
                      autovalidate: true,
                      autocorrect: false,
//                    validator: (_) {
//                      return !state.isEmailValid ? 'Invalid Email' : null;
//                    },
                    ),
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        icon: Icon(Icons.description),
                        labelText: 'Description',
                      ),
//                      obscureText: true,
                      autovalidate: true,
                      autocorrect: false,
//                    validator: (_) {
//                      return !state.isPasswordValid ? 'Invalid Password' : null;
//                    },
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 1),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
//                          Text(
//                              "Total: ${_currency.code} ${_currency.symbol} ${_totalAmount}"
//                          ),

                          Text(
                              "${_totalAmount}"
                          ),
                          ReportButton(
                            onPressed: _onAddReceipts,
                            buttonName: 'Add Receipts',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
                flex: 4,
                child: ListView.builder(
                    itemCount: _userRepository
                        .receiptRepository.cachedReceiptItems.length,
                    itemBuilder: (context, index) {
                      return ReceiptCard(
                        receiptItem: _userRepository
                            .receiptRepository.cachedReceiptItems[index],
                        actions: actions,
                      );
                    })
//              ReceiptList(
//                  userRepository: _userRepository,
//                  receiptStatusType: ReceiptStatusType.Reviewed),
                ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    ReportButton(
                      onPressed: isLoginButtonEnabled() ? _onReportSaved : null,
//                      _onReportSaved,
                      buttonName: 'Save Group',
                    ),
//                    ReportButton(
//                      onPressed:
//                      isLoginButtonEnabled() ? _onReportSubmitted : null,
//                      buttonName: 'Save & Submit Report',
//                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> addReport(Report report) async {
    await _userRepository.reportRepository.addReport(report);
//    await _userRepository.reportRepository.updateReport(report, true);
    setState(() {});
  }

  void _onReportSaved() {
    Report newReport = new Report();
    newReport.id = 0;
    newReport.userId = _userRepository.userId;
    newReport.statusId = 1;
    newReport.createDateTime = DateTime.now();
    newReport.updateDateTime = DateTime.now();
    newReport.reportName = _emailController.text;
    newReport.description = _passwordController.text;
    newReport.receiptIds = [];
    for (int i = 0;
        i < _userRepository.receiptRepository.cachedReceiptItems.length;
        i++) {
      newReport.receiptIds
          .add(_userRepository.receiptRepository.cachedReceiptItems[i].id);
    }
    addReport(newReport);
    print(
        'Save ${_emailController.text} ${_passwordController.text} ${_userRepository.receiptRepository.cachedReceiptItems}');
    Navigator.pop(context);
  }

  void _onReportSubmitted() {
    Report newReport = new Report();
    newReport.id = 0;
    newReport.userId = _userRepository.userId;
    newReport.statusId = 2;
    newReport.createDateTime = DateTime.now();
    newReport.updateDateTime = DateTime.now();
    newReport.reportName = _emailController.text;
    newReport.description = _passwordController.text;
    newReport.receiptIds = [];
    for (int i = 0;
        i < _userRepository.receiptRepository.cachedReceiptItems.length;
        i++) {
      newReport.receiptIds
          .add(_userRepository.receiptRepository.cachedReceiptItems[i].id);
    }
    addReport(newReport);
    print(
        'Submit ${_emailController.text} ${_passwordController.text} ${_userRepository.receiptRepository.cachedReceiptItems}');
    Navigator.pop(context);
  }

  void _onAddReceipts() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) {
        return AddReceiptsScreen(
          userRepository: _userRepository,
          title: 'Add Receipts',
        );
      }),
    );
  }
}

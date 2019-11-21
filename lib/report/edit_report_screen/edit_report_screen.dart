import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intelligent_receipt/data_model/action_with_lable.dart';
import 'package:intelligent_receipt/data_model/data_result.dart';
import 'package:intelligent_receipt/data_model/enums.dart';
import 'package:intelligent_receipt/data_model/exchange_rate/exchange.dart';
import 'package:intelligent_receipt/data_model/receipt.dart';
import 'package:intelligent_receipt/data_model/receipt_repository.dart';
import 'package:intelligent_receipt/data_model/report.dart';
import 'package:intelligent_receipt/data_model/setting_repository.dart';
import 'package:intelligent_receipt/receipt/receipt_card/receipt_card.dart';
import 'package:intelligent_receipt/receipt/receipt_list/receipt_list.dart';
import 'package:intelligent_receipt/report/add_receipts_screen/add_receipts_screen.dart';
import 'package:intelligent_receipt/report/add_report_screen/report_button.dart';
import 'package:intelligent_receipt/user_repository.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import 'package:intelligent_receipt/data_model/webservice.dart';

class EditReportScreen extends StatefulWidget {
  final String title;
  final UserRepository _userRepository;
  final int _reportId;
  EditReportScreen(
      {Key key,
      @required UserRepository userRepository,
      this.title,
      int reportId})
      : assert(userRepository != null),
        _userRepository = userRepository,
        _reportId = reportId,
        super(key: key) {}

  @override
  _EditReportScreenState createState() => new _EditReportScreenState();
}

class _EditReportScreenState extends State<EditReportScreen> {
  UserRepository get _userRepository => widget._userRepository;
  TextEditingController editingController = TextEditingController();
  List<Currency> duplicateItems;
  Currency selectedCurrency;
  bool show;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool get isPopulated => _emailController.text.isNotEmpty;
  double _tempAmount;

  bool isLoginButtonEnabled() {
    return isPopulated;
  }

  var items = List<Currency>();
  String _reportName;
  String _reportDescription;
  Report _report;
  List<ReceiptListItem> _receiptList;
  String _totalAmount;
  Currency baseCurrency;

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

  Future<void> calculateExchange() async {
    await _userRepository.settingRepository.getSettingsFromServer();
    baseCurrency = _userRepository.settingRepository.getDefaultCurrency();
    for (int i = 0; i < _userRepository.receiptRepository.cachedReceiptItems.length; i++ ) {
      if (_userRepository.receiptRepository.cachedReceiptItems[i].currencyCode == baseCurrency.code)
      {
        amountPair cachedReceiptItemsAmount2 = new amountPair();
        cachedReceiptItemsAmount2.amount = _userRepository.receiptRepository.cachedReceiptItems[i].totalAmount;
        cachedReceiptItemsAmount2.id = _userRepository.receiptRepository.cachedReceiptItems[i].id;
        _userRepository.receiptRepository.cachedReceiptItemsAmount.add(cachedReceiptItemsAmount2);
        print('id ${_userRepository.receiptRepository.cachedReceiptItems[i].id} add to group and ${cachedReceiptItemsAmount2}');
      }
      if (_userRepository.receiptRepository.cachedReceiptItems[i].currencyCode != baseCurrency.code) {
        amountPair cachedReceiptItemsAmount1 = new amountPair();

        Exchange exchange = await getExchangeRateFromServer(
            _userRepository.receiptRepository
                .cachedReceiptItems[i]
                .receiptDatetime, baseCurrency.code);
        cachedReceiptItemsAmount1.amount = _userRepository.receiptRepository
            .cachedReceiptItems[i]
            .totalAmount /
            exchange.rates.getRate(_userRepository.receiptRepository
                .cachedReceiptItems[i]
                .currencyCode);
        cachedReceiptItemsAmount1.id = _userRepository.receiptRepository.cachedReceiptItems[i].id;
        _userRepository.receiptRepository.cachedReceiptItemsAmount.add(
            cachedReceiptItemsAmount1);
      }}
    setState(() {

    });
  }

  @override
  void initState() {
    duplicateItems = _userRepository.settingRepository.getCurrencies();
    items.addAll(duplicateItems);
    super.initState();
    _reportName =
        _userRepository.reportRepository.getReport(widget._reportId).reportName;
    _reportDescription = _userRepository.reportRepository
        .getReport(widget._reportId)
        .description;
    _emailController.text = _reportName;
    _passwordController.text = _reportDescription;
//    _receiptList = _userRepository.reportRepository.getReport(widget._reportId).getReceiptList(_userRepository.receiptRepository);
//    _totalAmount = _userRepository.reportRepository.getReport(widget._reportId).getTotalAmount(_userRepository.receiptRepository);
    _report = _userRepository.reportRepository.getReport(widget._reportId);
    _receiptList = _report.getReceiptList(_userRepository.receiptRepository);
//    _totalAmount = _report
//        .getTotalAmount(_userRepository.receiptRepository)
//        .toStringAsFixed(2);
    print('${_report} ${_receiptList} ${_totalAmount}');
    _userRepository.receiptRepository.cachedReceiptItems = _receiptList;

    calculateExchange();

    List<int> _receiptIds = [];


    //get rid of duplicated items and set candidate
//    var _receiptsInReportSet = new Set();
//    var _candidateReceiptsSet = new Set();
//
//    for (var i = 0; i < _userRepository.reportRepository.reports.length; i++ ) {
//      _receiptsInReportSet.addAll(_userRepository.reportRepository.reports[i].receiptIds);
//    }
//
//    _candidateReceiptsSet.addAll(_userRepository.receiptRepository.candidateReceiptItems);
//
//    _userRepository.receiptRepository.candidateReceiptItems = _candidateReceiptsSet.difference(_receiptsInReportSet).toList();

//    for (var i = 0; i< _userRepository.receiptRepository.candidateReceiptItems.length; i++){
//      if (_receiptIds.contains(_userRepository.receiptRepository.candidateReceiptItems[i].id)) {
//      _userRepository.receiptRepository.candidateReceiptItems.removeAt(i);
//      }
//    }
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

  @override
  Widget build(BuildContext context) {
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
//                      initialValue: _reportName,
                      controller: _emailController,
                      decoration: InputDecoration(
                        icon: Icon(Icons.title),
                        labelText: 'Group Name',
                      ),
                      autovalidate: true,
                      autocorrect: false,
//                    validator: (_) {
//                      return !state.isEmailValid ? 'Invalid Email' : null;
//                    },
                    ),
                    TextFormField(
//                      initialValue: _userRepository.reportRepository.getReport(widget._reportId).description,
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
                      buttonName: 'Save group',
                    ),
                    ReportButton(
                      onPressed:
                          isLoginButtonEnabled() ? _onReportSubmitted : null,
                      buttonName: 'Archive group',
                    ),
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

  Future<void> saveReport(Report report) async {
    await _userRepository.reportRepository.updateReport(report, true);
//    await _userRepository.reportRepository.updateReport(report, true);
    setState(() {});
  }

//  void _onReportSaved() {
//    Report newReport = new Report();
//    newReport.id = 0;
//    newReport.userId = _userRepository.userId;
//    newReport.statusId = 1;
//    newReport.createDateTime = DateTime.now();
//    newReport.updateDateTime = DateTime.now();
//    newReport.reportName = _emailController.text;
//    newReport.description = _passwordController.text;
//    newReport.receiptIds = [];
//    for (int i = 0; i < _userRepository.receiptRepository.cachedReceiptItems.length; i++) {
//      newReport.receiptIds.add(_userRepository.receiptRepository.cachedReceiptItems[i].id);
//    }
//    addReport(newReport);
//    print('Save ${_emailController.text} ${_passwordController.text} ${_userRepository.receiptRepository.cachedReceiptItems}');
//    Navigator.pop(context);
//  }
  void _onReportSaved() {
    _report.updateDateTime = DateTime.now();
    _report.reportName = _emailController.text;
    _report.description = _passwordController.text;
    _report.receiptIds = [];
    for (int i = 0;
        i < _userRepository.receiptRepository.cachedReceiptItems.length;
        i++) {
      _report.receiptIds
          .add(_userRepository.receiptRepository.cachedReceiptItems[i].id);
    }
    saveReport(_report);
    print(
        'Save ${_emailController.text} ${_passwordController.text} ${_userRepository.receiptRepository.cachedReceiptItems}');
    Navigator.pop(context);
  }

  void _onReportSubmitted() {
    _report.statusId = 2;
    _onReportSaved();
  }

//  void _onReportSubmitted() {
//    Report newReport = new Report();
//    newReport.id = 0;
//    newReport.userId = _userRepository.userId;
//    newReport.statusId = 2;
//    newReport.createDateTime = DateTime.now();
//    newReport.updateDateTime = DateTime.now();
//    newReport.reportName = _emailController.text;
//    newReport.description = _passwordController.text;
//    newReport.receiptIds = [];
//    for (int i = 0; i < _userRepository.receiptRepository.cachedReceiptItems.length; i++) {
//      newReport.receiptIds.add(_userRepository.receiptRepository.cachedReceiptItems[i].id);
//    }
//    addReport(newReport);
//    print('Submit ${_emailController.text} ${_passwordController.text} ${_userRepository.receiptRepository.cachedReceiptItems}');
//    Navigator.pop(context);
//  }

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

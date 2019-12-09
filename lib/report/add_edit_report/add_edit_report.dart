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
import 'package:intelligent_receipt/report/add_receipts_screen/add_receipts_screen.dart';
import 'package:intelligent_receipt/report/add_edit_report/report_button.dart';
import 'package:intelligent_receipt/user_repository.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:intelligent_receipt/data_model/webservice.dart';

class AddEditReport extends StatefulWidget {
  final String title;
  final UserRepository _userRepository;
  final int _reportId;
  AddEditReport(
      {Key key,
        @required UserRepository userRepository,
        this.title,
        int reportId : 0})
      : assert(userRepository != null),
        _userRepository = userRepository,
        _reportId = reportId,
        super(key: key) {}

  @override
  _AddEditReportState createState() => new _AddEditReportState();
}

class _AddEditReportState extends State<AddEditReport> {
  UserRepository get _userRepository => widget._userRepository;
  final TextEditingController _reportNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  bool get isPopulated => _reportNameController.text.isNotEmpty;

  Report _report = null;
  List<ReceiptListItem> _receiptList;
  String _totalAmount;
  Currency baseCurrency;

  @override
  void initState() {
    if (isNewReport()) {
      _report = new Report();
      _report.reportName = "";
      _report.description = "";
    } else {
      _report = _userRepository.reportRepository.getReport(widget._reportId);
    }

    _reportNameController.text = (_report != null) ? _report.reportName : "";
    _descriptionController.text = (_report != null) ? _report.description : "";
    _receiptList = (!isNewReport()) ? _report.getReceiptList(_userRepository.receiptRepository) : new List<ReceiptListItem>();

    super.initState();
  }

  bool isLoginButtonEnabled() {
    return isPopulated;
  }

  bool isNewReport() {
    return (widget._reportId == 0);
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

  Future<void> calculateExchange() async {
    // xxx to be done
//    await _userRepository.settingRepository.getSettingsFromServer();
//    baseCurrency = _userRepository.settingRepository.getDefaultCurrency();
//    for (int i = 0; i < _userRepository.receiptRepository.cachedReceiptItems.length; i++ ) {
//      if (_userRepository.receiptRepository.cachedReceiptItems[i].currencyCode == baseCurrency.code)
//      {
//        amountPair cachedReceiptItemsAmount2 = new amountPair();
//        cachedReceiptItemsAmount2.amount = _userRepository.receiptRepository.cachedReceiptItems[i].totalAmount;
//        cachedReceiptItemsAmount2.id = _userRepository.receiptRepository.cachedReceiptItems[i].id;
//        _userRepository.receiptRepository.cachedReceiptItemsAmount.add(cachedReceiptItemsAmount2);
//        print('id ${_userRepository.receiptRepository.cachedReceiptItems[i].id} add to group and ${cachedReceiptItemsAmount2}');
//      }
//      if (_userRepository.receiptRepository.cachedReceiptItems[i].currencyCode != baseCurrency.code) {
//        amountPair cachedReceiptItemsAmount1 = new amountPair();
//
//        Exchange exchange = await getExchangeRateFromServer(
//            _userRepository.receiptRepository
//                .cachedReceiptItems[i]
//                .receiptDatetime, baseCurrency.code);
//        cachedReceiptItemsAmount1.amount = _userRepository.receiptRepository
//            .cachedReceiptItems[i]
//            .totalAmount /
//            exchange.rates.getRate(_userRepository.receiptRepository
//                .cachedReceiptItems[i]
//                .currencyCode);
//        cachedReceiptItemsAmount1.id = _userRepository.receiptRepository.cachedReceiptItems[i].id;
//        _userRepository.receiptRepository.cachedReceiptItemsAmount.add(
//            cachedReceiptItemsAmount1);
//      }}
//    setState(() {
//
//    });
  }

  double _calculateTotal() {
    return 0; // xxx to be done
  }

  void removeAction(int inputId) {
    _receiptList.removeWhere((ReceiptListItem item){
      return item.id == inputId;
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    List<ActionWithLabel> actions = [];
    ActionWithLabel d = new ActionWithLabel();
    d.action = removeAction;
    d.label = 'Remove';
    actions.add(d);

    double tempAmount = _calculateTotal();
    _totalAmount = tempAmount.toStringAsFixed(2);

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
                      controller: _reportNameController,
                      decoration: InputDecoration(
                        icon: Icon(Icons.title),
                        labelText: 'Group Name',
                      ),
                      autovalidate: true,
                      autocorrect: false,
                    ),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        icon: Icon(Icons.description),
                        labelText: 'Description',
                      ),
                      autovalidate: true,
                      autocorrect: false,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 1),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Text(
                              "Total: ${baseCurrency != null ? baseCurrency.code: ''} ${baseCurrency != null ? baseCurrency.symbol: ''} ${_totalAmount}"
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
                    itemCount: _receiptList.length,
                    itemBuilder: (context, index) {
                      return ReceiptCard(
                        receiptItem: _receiptList[index],
                        actions: actions,
                      );
                    })
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
    _reportNameController.dispose();
    _descriptionController.dispose();
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

  Future<void> _onReportSaved() async {
    if (isNewReport()) {
      _report.id = 0;
      _report.statusId = 1;
      _report.createDateTime = DateTime.now();
    }
    _report.updateDateTime = DateTime.now();
    _report.reportName = _reportNameController.text;
    _report.description = _descriptionController.text;
    _report.receiptIds = [];
    for (int i = 0; i < _receiptList.length; i++) {
     _report.receiptIds.add(_receiptList[i].id);
    }

    DataResult dataResult = isNewReport() ? await _userRepository.reportRepository.addReport(_report) :  await _userRepository.reportRepository.updateReport(_report, true);
    if (dataResult.success) {
      Navigator.pop(context);
    } else {
      // Show message on snack bar
    }
  }

  void _onReportSubmitted() {
    _report.statusId = 2;
    _onReportSaved();
  }

  void _addToReceiptList(ReceiptListItem receiptItem) {
    _receiptList.add(receiptItem);
  }

  void _onAddReceipts() {
    // Get candidate item list
    List<ReceiptListItem> reviewedItems = _userRepository.receiptRepository.getReceiptItems(ReceiptStatusType.Reviewed);
    // Remove the items already included in the report's receipt list
    List<ReceiptListItem> candidateItems = reviewedItems.toSet().difference(_receiptList.toSet()).toList();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) {
        return AddReceiptsScreen(
          userRepository: _userRepository,
          candidateItems: candidateItems,
          addReceiptToGroupFunc: _addToReceiptList
        );
      }),
    );
  }
}

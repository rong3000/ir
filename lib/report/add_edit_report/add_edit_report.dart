// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart' show DragStartBehavior;
import 'package:intelligent_receipt/data_model/enums.dart';
import 'package:intelligent_receipt/data_model/receipt_repository.dart';
import 'package:intelligent_receipt/report/add_edit_report/report_button.dart';
import 'package:intelligent_receipt/report/add_receipts_screen/add_receipts_screen.dart';
import 'package:intelligent_receipt/user_repository.dart';
import 'package:intelligent_receipt/translations/global_translations.dart';

import 'dart:convert';

import 'package:intelligent_receipt/data_model/action_with_lable.dart';
import 'package:intelligent_receipt/data_model/data_result.dart';
import 'package:intelligent_receipt/data_model/exchange_rate/exchange.dart';
import 'package:intelligent_receipt/data_model/receipt.dart';
import 'package:intelligent_receipt/data_model/report.dart';
import 'package:intelligent_receipt/data_model/setting_repository.dart';
import 'package:intelligent_receipt/data_model/log_helper.dart';
import 'package:intelligent_receipt/receipt/receipt_card/receipt_card.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:intelligent_receipt/data_model/webservice.dart';
import 'package:intelligent_receipt/data_model/exception_handlers/unsupported_version.dart';
import 'package:intelligent_receipt/data_model/http_statuscode.dart';

class AddEditReport extends StatefulWidget {
  final String title;
  final UserRepository _userRepository;
  final Report _report;
  AddEditReport(
      {Key key,
        @required UserRepository userRepository,
        this.title,
        Report report
      })
      : assert(userRepository != null),
        _userRepository = userRepository,
        _report = report,
        super(key: key);

  static const String routeName = '/material/text-form-field';

  @override
  AddEditReportState createState() => AddEditReportState();
}

class AddEditReportState extends State<AddEditReport> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  UserRepository get _userRepository => widget._userRepository;
  Report get _report => widget._report;
  List<ReceiptListItem> _receiptList;
  double _totalAmount;
  Currency _reportCurrency;
  Currency _defaultCurrency;
  Future<double> _calcTotalAmountFuture;
  bool _receiptItemsChanged = false;
  bool _autovalidate = false;
  bool _formWasEdited = false;
  bool _formSubmitting = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _showInSnackBar(String value, {IconData icon: Icons.error, color: Colors.red}) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(value), Icon(icon)],
      ),
      backgroundColor: color,
    ));
  }

  String _validateGroupName(String value) {
    _formWasEdited = true;
    if (value.isEmpty)
      return allTranslations.text('app.add-edit-report-page.group-name-required');
    return null;
  }

  Future<bool> _warnUserAboutInvalidData() async {
    final FormState form = _formKey.currentState;
    if (form == null || !_formWasEdited || form.validate())
      return true;

    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(allTranslations.text('app.contact-screen.form-error')),
          content: Text(allTranslations.text('app.contact-screen.form-leaving')),
          actions: <Widget> [
            FlatButton(
              child: Text(allTranslations.text('words.ok')),
              onPressed: () { Navigator.of(context).pop(true); },
            ),
            FlatButton(
              child: Text(allTranslations.text('words.cancel')),
              onPressed: () { Navigator.of(context).pop(false); },
            ),
          ],
        );
      },
    ) ?? false;
  }

  @override
  void initState() {
    _totalAmount = (_report != null && _report.totalAmount != null) ? _report.totalAmount : 0;
    _reportCurrency = (_report != null) ? _userRepository.settingRepository.getCurrencyForCurrencyCode(_report.currencyCode) : null;
    _receiptList = _report.getReceiptList(_userRepository.receiptRepository);
    _defaultCurrency = _userRepository.settingRepository.getDefaultCurrency();
    _calcTotalAmountFuture = _calculateTotalAmount();
    super.initState();
  }

  bool isNewReport() {
    return (_report.id == 0);
  }

  Future<Exchange> getExchangeRateFromServer(DateTime receiptDatetime, String baseCurrencyCode) async {
    final response =
    await http.get(Urls.GetExchangeRate + DateFormat("yyyy-MM-dd").format(receiptDatetime.toLocal()).toString() + "?base=" + baseCurrencyCode);
    if (response.statusCode == 200) {
      // If server returns an OK response, parse the JSON.
      return Exchange.fromJson(json.decode(response.body));
    } else {
      // If that response was not OK, throw an error.
      LogHepper.warning("Failed to load exchange rate from server", saveToFile: true);
      return null;
    }
  }

  Future<double> _getAmountForGivenCurrency(ReceiptListItem receiptItem, Currency currency) async {
    if (currency == null) {
      return receiptItem.totalAmount;
    } else {
      if (receiptItem.currencyCode == currency.code) {
        return receiptItem.totalAmount;
      } else if (receiptItem.altCurrencyCode == currency.code) {
        return receiptItem.altTotalAmount;
      } else {
        // Get currency exchange rate from server
        Exchange exchange = await getExchangeRateFromServer(receiptItem.receiptDatetime, currency.code);
        if (exchange == null) {
          LogHepper.warning("Cannot get currency exchange for ${receiptItem.receiptDatetime} ${currency.code}", saveToFile: true);
          return receiptItem.totalAmount;
        } else {
          double rate = exchange.rates.getRate(receiptItem.currencyCode);
          if ((rate != null) && (rate > 0)) {
            double altTotalAmount = receiptItem.totalAmount / rate;
            // Save receipt's altTotalAmount
            receiptItem.altTotalAmount = altTotalAmount;
            receiptItem.altCurrencyCode = currency.code;
            _userRepository.receiptRepository.updateReceiptListItem(receiptItem);
            return altTotalAmount;
          } else {
            LogHepper.warning("No exchange rate for ${receiptItem.receiptDatetime} ${currency.code} ${receiptItem.currencyCode}", saveToFile: true);
            return receiptItem.totalAmount;
          }
        }
      }
    }
  }

  Future<double> _calculateTotalAmount() async {
    double totalAmount = 0;
    for (int i = 0; i < _receiptList.length; i++) {
      double itemAmount = await _getAmountForGivenCurrency(_receiptList[i], _defaultCurrency);
      totalAmount += itemAmount;
    }

    if (_totalAmount != totalAmount) {
      _totalAmount = totalAmount;
      _reportCurrency = _defaultCurrency;
      if (!_receiptItemsChanged && !isNewReport()) {
        // Save report's total amount and currency code automatically
        // the totalAmount changes may be caused by receipt items deleted or default currency change
        _report.totalAmount = _totalAmount;
        _report.currencyCode = _defaultCurrency.code;
        _userRepository.reportRepository.updateReport(_report, false);
      }
    }

    return totalAmount;
  }

  String _getTotalAmountText(double totalAmount) {
    final String total = allTranslations.text('app.add-edit-report-page.total-amount-prefix');
    return "$total: ${_reportCurrency != null ? _reportCurrency.code: ''} "
        "${_reportCurrency != null ? _reportCurrency.symbol: ''}"
        "${totalAmount?.toStringAsFixed(2)}";
  }


  @override
  Widget build(BuildContext context) {
    List<ActionWithLabel> actions = [];
    actions.add(ActionWithLabel()
      ..action = removeAction
      ..label = allTranslations.text('app.add-edit-report-page.remove-label')
    );

    void _handleSubmitted() {
      final FormState form = _formKey.currentState;
      if (!form.validate()) {
        _autovalidate = true; // Start validating on every change.
        _showInSnackBar(allTranslations.text('app.contact-screen.fix'));
      } else {
        form.save();
        _onReportSaved();
      }
    }

    List<Widget> _getAppBarButtons() {
      List<Widget> buttons = new List<Widget>();
      buttons.add(IconButton(
        icon: const Icon(Icons.done),
        onPressed: _formSubmitting ? null : _handleSubmitted,
      ));
      return buttons;
    }

    return Scaffold(
      drawerDragStartBehavior: DragStartBehavior.down,
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(widget.title),
        actions: _getAppBarButtons(),
      ),
      body: SafeArea(
        top: false,
        bottom: false,
        child: Form(
          key: _formKey,
          autovalidate: _autovalidate,
          onWillPop: _warnUserAboutInvalidData,
          child: Scrollbar(
            child: SingleChildScrollView(
              dragStartBehavior: DragStartBehavior.down,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const SizedBox(height: 6.0),
                  TextFormField(
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      filled: true,
                      icon: Icon(Icons.title),
                      labelText: allTranslations.text('app.add-edit-report-page.group-name-label') + '*',
                    ),
                    initialValue: (_report != null) ? _report.reportName : "",
                    validator: _validateGroupName,
                    readOnly: !_report.isNormalReport(),
                    onChanged: (String value) {
                      _report.reportName = value;
                    },
                  ) ,
                  const SizedBox(height: 6.0),
                  TextFormField(
                    decoration: InputDecoration(
                      border: UnderlineInputBorder(),
                      filled: true,
                      icon: Icon(Icons.description),
                      labelText: allTranslations.text('app.add-edit-report-page.description-label'),
                    ),

                    initialValue: (_report != null) ? _report.description : "",
                    onChanged: (String value) {
                      _report.description = value;
                    },
                  ),
                  const SizedBox(height: 6.0),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 1),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        FutureBuilder<double> (
                            future: _calcTotalAmountFuture,
                            builder:
                                (BuildContext context, AsyncSnapshot<double> snapshot) {
                              switch (snapshot.connectionState) {
                                case ConnectionState.none:
                                case ConnectionState.waiting:
                                case ConnectionState.active:
                                  return Text(_getTotalAmountText(_totalAmount));
                                case ConnectionState.done:
                                  return Text(_getTotalAmountText(snapshot.data));
                              }
                            }
                        ),
                        ReportButton(
                          onPressed: _onAddReceipts,
                          buttonName: allTranslations.text('app.add-edit-report-page.add-receipts-button-label'),
                        ),
                      ],
                    ),
                  ),
                  Text(allTranslations.text('app.contact-screen.form-indication'),
                    style: Theme.of(context).textTheme.caption,
                  ),
                  Container(
                    height:
                    MediaQuery.of(context).size.height - 300,
                      child: Scrollbar(
                        child: ListView.builder(
                            itemCount: _receiptList.length,
                            itemBuilder: (context, index) {
                              return ReceiptCard(
                                receiptItem: _receiptList[index],
                                actions: actions,
                              );
                            }),
                      )
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _onReportSaved() async {
    if (isNewReport()) {
      _report.id = 0;
      _report.statusId = 1;
      _report.createDateTime = DateTime.now();
    }
    _report.totalAmount = _totalAmount;
    _report.currencyCode = (_reportCurrency != null) ? _reportCurrency.code : "";
    _report.updateDateTime = DateTime.now();
    _report.receipts = [];
    for (int i = 0; i < _receiptList.length; i++) {
      _report.receipts.add(new ReportReceipt(receiptId: _receiptList[i].id));
    }

    DataResult dataResult = isNewReport() ? await _userRepository.reportRepository.addReport(_report) :  await _userRepository.reportRepository.updateReport(_report, true);
    if (dataResult.success) {
      Navigator.pop(context);
    } else if (dataResult.messageCode == HTTPStatusCode.UNSUPPORTED_VERSION) {
      showUnsupportedVersionAlert(context);
    } else {
      // Show message on snack bar
      _showInSnackBar("${dataResult.message}");
    }
  }

  void _onReportSubmitted() {
    _report.statusId = 2;
    _onReportSaved();
  }

  void _addToReceiptList(ReceiptListItem receiptItem) {
    _receiptList.add(receiptItem);
    _receiptItemsChanged = true;
    _calcTotalAmountFuture = _calculateTotalAmount();
  }

  void removeAction(int inputId) {
    _receiptList.removeWhere((ReceiptListItem item){
      return item.id == inputId;
    });
    _receiptItemsChanged = true;
    _calcTotalAmountFuture = _calculateTotalAmount();
    setState(() {});
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
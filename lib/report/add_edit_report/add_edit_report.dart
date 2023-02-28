// Copyright 2016 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart' show DragStartBehavior;
import 'package:intelligent_receipt/data_model/enums.dart';
import 'package:intelligent_receipt/data_model/receipt_repository.dart';
import 'package:intelligent_receipt/data_model/taxreturn.dart';
import 'package:intelligent_receipt/report/add_edit_report/report_button.dart';
import 'package:intelligent_receipt/report/add_receipts_screen/add_receipts_screen.dart';
import 'package:intelligent_receipt/report/export_report/export_report.dart';
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
import 'package:intelligent_receipt/helper_widgets/confirm-dialog.dart';
import "package:intelligent_receipt/data_model/quarterlygroup.dart";
import 'package:intelligent_receipt/receipt/add_edit_reciept_manual/add_edit_receipt_manual.dart';

class ReportTotals {
  double total = 0;
  double taxTotal = 0;
  double workRelatedTotal = 0;
  double workRelatedTaxTotal = 0;

  ReportTotals();

  factory ReportTotals.fromReceipt(ReceiptListItem receipt) {
    return receipt == null ? ReportTotals() :
     ReportTotals()
        ..total = receipt.totalAmount
        ..taxTotal = receipt.taxAmount
        ..workRelatedTotal = (receipt.totalAmount * receipt.percentageOnWork / 100)
        ..workRelatedTaxTotal = (receipt.taxAmount * receipt.percentageOnWork / 100);
  }

  factory ReportTotals.fromReport(Report report) {
    return report == null ? ReportTotals() :
    ReportTotals()
      ..total = (report.totalAmount == null) ? 0 : report.totalAmount
      ..taxTotal = (report.taxAmount == null) ? 0 : report.taxAmount
      ..workRelatedTotal = (report.workRelatedTotalAmount == null) ? 0 : report.workRelatedTotalAmount
      ..workRelatedTaxTotal = (report.workRelatedTaxAmount == null) ? 0 : report.workRelatedTaxAmount;
  }

  void adjustByAltAmount(double altTotalAmount) {
    taxTotal = (total == 0) ? taxTotal : (taxTotal / total) * altTotalAmount;
    workRelatedTotal = (total == 0) ? workRelatedTotal : (workRelatedTotal / total) * altTotalAmount;
    workRelatedTaxTotal = (total == 0) ? workRelatedTaxTotal : (workRelatedTaxTotal / total) * altTotalAmount;
    total = altTotalAmount;
  }

  void Add(ReportTotals reportTotals) {
    total += reportTotals.total;
    taxTotal += reportTotals.taxTotal;
    workRelatedTotal += reportTotals.workRelatedTotal;
    workRelatedTaxTotal += reportTotals.workRelatedTaxTotal;
  }

  bool isEqual(ReportTotals reportTotals) {
    return (total == reportTotals.total) && (taxTotal == reportTotals.taxTotal) &&
        (workRelatedTotal == reportTotals.workRelatedTotal) && (workRelatedTaxTotal == reportTotals.workRelatedTaxTotal);
  }
}

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
  ReportTotals _reportTotals;
  Currency _reportCurrency;
  Currency _defaultCurrency;
  Future<ReportTotals> _calcTotalAmountFuture;
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
    _reportTotals = ReportTotals.fromReport(_report);
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

  Future<ReportTotals> _getAmountForGivenCurrency(ReceiptListItem receiptItem, Currency currency) async {
    ReportTotals reportTotals = ReportTotals.fromReceipt(receiptItem);
    if (currency == null) {
      return reportTotals;
    } else {
      if (receiptItem.currencyCode == currency.code) {
        return reportTotals;
      } else if (receiptItem.altCurrencyCode == currency.code) {
        reportTotals.adjustByAltAmount(receiptItem.altTotalAmount);
        return reportTotals;
      } else {
        // Get currency exchange rate from server
        Exchange exchange = await getExchangeRateFromServer(receiptItem.receiptDatetime, currency.code);
        if (exchange == null) {
          LogHepper.warning("Cannot get currency exchange for ${receiptItem.receiptDatetime} ${currency.code}", saveToFile: true);
          return reportTotals;
        } else {
          double rate = exchange.rates.getRate(receiptItem.currencyCode);
          if ((rate != null) && (rate > 0)) {
            double altTotalAmount = receiptItem.totalAmount / rate;
            // Save receipt's altTotalAmount
            receiptItem.altTotalAmount = altTotalAmount;
            receiptItem.altCurrencyCode = currency.code;
            _userRepository.receiptRepository.updateReceiptListItem(receiptItem);
            reportTotals.adjustByAltAmount(receiptItem.altTotalAmount);
            return reportTotals;
          } else {
            LogHepper.warning("No exchange rate for ${receiptItem.receiptDatetime} ${currency.code} ${receiptItem.currencyCode}", saveToFile: true);
            return reportTotals;
          }
        }
      }
    }
  }

  Future<ReportTotals> _calculateTotalAmount() async {
    ReportTotals reportTotals = ReportTotals();
    for (int i = 0; i < _receiptList.length; i++) {
      ReportTotals itemTotals = await _getAmountForGivenCurrency(_receiptList[i], _defaultCurrency);
      reportTotals.Add(itemTotals);
    }

    if (!_reportTotals.isEqual(reportTotals)) {
      _reportTotals = reportTotals;
      _reportCurrency = _defaultCurrency;
      if (!_receiptItemsChanged && !isNewReport()) {
        // Save report's total amount and currency code automatically
        // the totalAmount changes may be caused by receipt items deleted or default currency change
        _report.totalAmount = _reportTotals.total;
        _report.taxAmount = _reportTotals.taxTotal;
        _report.workRelatedTotalAmount = _reportTotals.workRelatedTotal;
        _report.workRelatedTaxAmount = _reportTotals.workRelatedTaxTotal;
        _report.currencyCode = _defaultCurrency.code;
        _userRepository.reportRepository.updateReport(_report, false);
      }
    }

    return reportTotals;
  }

  String _getTotalAmountText(ReportTotals reportTotals) {
    String currencySymbol = _reportCurrency != null ? _reportCurrency.symbol: '';
    final String totalPrefix = allTranslations.text('app.add-edit-report-page.total-amount-prefix');
    final String taxAmountPrefix = allTranslations.text('app.add-edit-report-page.tax-amount-prefix');
    final String workRelatedTotalPrefix = allTranslations.text('app.add-edit-report-page.work-related-total-prefix');
    final String workRelatedTaxAmountPrefix = allTranslations.text('app.add-edit-report-page.work-related-tax-amount-prefix');
    final String currencyCodePrefix = allTranslations.text('app.add-edit-report-page.currency-code-prefix');
    return "$totalPrefix: $currencySymbol${reportTotals.total?.toStringAsFixed(2)}, "
           "$workRelatedTotalPrefix: $currencySymbol${reportTotals.workRelatedTotal?.toStringAsFixed(2)}\n"
           "$taxAmountPrefix: $currencySymbol${reportTotals.taxTotal?.toStringAsFixed(2)}, "
           "$workRelatedTaxAmountPrefix: $currencySymbol${reportTotals.workRelatedTaxTotal?.toStringAsFixed(2)}\n"
           "$currencyCodePrefix ${_reportCurrency != null ? _reportCurrency.code: 'AUD'}.";
  }


  @override
  Widget build(BuildContext context) {
    List<ActionWithLabel> actions = [];
    actions.add(ActionWithLabel()
      ..action = _reviewAction
      ..label = allTranslations.text('words.review')
    );
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
          icon: const Icon(Icons.email),
          onPressed:  () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) {
                return ExportReport(userRepository: _userRepository, report: _report);
              }),
            );
          }
      ));
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
                    FutureBuilder<ReportTotals> (
                        future: _calcTotalAmountFuture,
                        builder:
                            (BuildContext context, AsyncSnapshot<ReportTotals> snapshot) {
                          switch (snapshot.connectionState) {
                            case ConnectionState.none:
                            case ConnectionState.waiting:
                            case ConnectionState.active:
                              return Text(_getTotalAmountText(_reportTotals));
                            case ConnectionState.done:
                              return Text(_getTotalAmountText(snapshot.data));
                          }
                        }
                    ),
                  ],
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                //textDirection: TextDirection.rtl,
                children: <Widget>[
                  _report.quarterlyGroupId <= 0 ? Container() :
                  ReportButton(
                    onPressed: _onRepopulateQuarterReceipts,
                    buttonName: allTranslations.text('app.add-edit-report-page.re-populate-quarterly-receipts'),
                  ),
                  ReportButton(
                    onPressed: _onAddReceipts,
                    buttonName: allTranslations.text('app.add-edit-report-page.add-receipts-button-label'),
                  ),
                ],
              ),
              Text(allTranslations.text('app.contact-screen.form-indication'),
                style: Theme.of(context).textTheme.caption,
              ),
              Flexible(
                fit: FlexFit.tight,
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
    _report.totalAmount = _reportTotals.total;
    _report.taxAmount = _reportTotals.taxTotal;
    _report.workRelatedTotalAmount = _reportTotals.workRelatedTotal;
    _report.workRelatedTaxAmount = _reportTotals.workRelatedTaxTotal;
    _report.currencyCode = (_reportCurrency != null) ? _reportCurrency.code : "";
    _report.updateDateTime = DateTime.now();
    _report.receipts = [];
    for (int i = 0; i < _receiptList.length; i++) {
      _report.receipts.add(new ReportReceipt(receiptId: _receiptList[i].id));
    }

    DataResult dataResult = isNewReport() ? await _userRepository.reportRepository.addReport(_report) :  await _userRepository.reportRepository.updateReport(_report, true);
    if (dataResult.success) {
      Navigator.pop(context);
      if (_report.taxReturnGroupId != 0) {
        _userRepository.taxReturnRepository.updateReport(dataResult.obj);
      }
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

  Future<void> _reviewAction(int receiptId) async {
    // Try to get the receipt detailed information from server
    DataResult dataResult =
        await _userRepository.receiptRepository.getReceipt(receiptId);
    if (dataResult.success) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) {
          return AddEditReiptForm(dataResult.obj as Receipt);
        }),
      );
    } else {
      _showInSnackBar("${allTranslations.text("app.receipts-page.failed-review-receipt-message")} \n${dataResult.message}");
    }
  }

  Future<void>  _onRepopulateQuarterReceipts() async {
    bool shouldRepopulate = true;
    if (_receiptList.length > 0) {
      shouldRepopulate = await showDialog<bool>(
          context: context,
          builder: ConfirmDialog.builder(context,
              title: Text(allTranslations.text('app.add-edit-report-page.re-populate-quarterly-receipts')),
              content: Text(allTranslations.text('app.add-edit-report-page.re-populate-quarterly-receipts-description'))
          )
      );
    }

    if (shouldRepopulate) {
      setState(() {
        _receiptList.clear();
        QuarterlyGroup quarterlyGroup = _userRepository.quarterlyGroupRepository.getQuarterGroupById(_report.quarterlyGroupId);
        if (quarterlyGroup != null ){
          Set<ReceiptStatusType> statusTypes = new Set<ReceiptStatusType>();
          statusTypes.add(ReceiptStatusType.Reviewed);
          statusTypes.add(ReceiptStatusType.Archived);
          _receiptList = _userRepository.receiptRepository.getReceiptItemsBetweenDateRange(statusTypes, quarterlyGroup.startDatetime, quarterlyGroup.endDatetime);
        }
        _receiptItemsChanged = true;
        _calcTotalAmountFuture = _calculateTotalAmount();
      });
    }
  }

  void _onAddReceipts() {
    // Get candidate item list
    DateTime startDateTime = null;
    DateTime endDateTime = null;
    List<ReceiptListItem> receiptItems = new List<ReceiptListItem>();
    if (_report.quarterlyGroupId > 0) {
      QuarterlyGroup quarterlyGroup = _userRepository.quarterlyGroupRepository.getQuarterGroupById(_report.quarterlyGroupId);
      if (quarterlyGroup != null ){
        Set<ReceiptStatusType> statusTypes = new Set<ReceiptStatusType>();
        statusTypes.add(ReceiptStatusType.Reviewed);
        statusTypes.add(ReceiptStatusType.Archived);
        startDateTime = quarterlyGroup.startDatetime;
        endDateTime = quarterlyGroup.endDatetime;
        receiptItems = _userRepository.receiptRepository.getReceiptItemsBetweenDateRange(statusTypes, startDateTime, endDateTime);
      }
    } else if (_report.taxReturnGroupId > 0) {
      TaxReturn taxReturn = _userRepository.taxReturnRepository.getTaxReturnByTaxReturnGroupId(_report.taxReturnGroupId);
      if (taxReturn != null) {
        Set<ReceiptStatusType> statusTypes = new Set<ReceiptStatusType>();
        statusTypes.add(ReceiptStatusType.Reviewed);
        statusTypes.add(ReceiptStatusType.Archived);
        startDateTime = taxReturn.getStartDateTime();
        endDateTime = taxReturn.getEndDatetime();
        receiptItems = _userRepository.receiptRepository.getReceiptItemsBetweenDateRange(statusTypes, startDateTime, endDateTime);
      }
    } else {
      receiptItems = _userRepository.receiptRepository.getReceiptItems(ReceiptStatusType.Reviewed, SaleExpenseType.values[_report.reportTypeId]);
    }

    // Remove the items already included in the report's receipt list
    List<ReceiptListItem> candidateItems = receiptItems.toSet().difference(_receiptList.toSet()).toList();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) {
        return AddReceiptsScreen(
            userRepository: _userRepository,
            candidateItems: candidateItems,
            addReceiptToGroupFunc: _addToReceiptList,
            fromDate: startDateTime,
            toDate: endDateTime
        );
      }),
    );
  }
}
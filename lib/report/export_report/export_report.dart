import 'dart:io';

import 'package:basic_utils/basic_utils.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intelligent_receipt/user_repository.dart';
import 'package:intelligent_receipt/data_model/report.dart';
import 'package:intelligent_receipt/data_model/receipt.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:intelligent_receipt/translations/global_translations.dart';

class ExportReport extends StatefulWidget {
  final UserRepository _userRepository;
  final Report _report;
  static final TextEditingController _emailController = TextEditingController();

  ExportReport(
      {Key key, @required UserRepository userRepository, @required Report report})
      : assert(userRepository != null),
        _userRepository = userRepository,
        _report = report,
        super(key: key);

  @override
  _ExportReportState createState() => _ExportReportState();
}

class _ExportReportState extends State<ExportReport> {
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String _filePath;
  String _currentProcess;
  bool _isProcessing = false;
  String _accountingCompany = "Xero";
  String _emailSubject = "";
  String _emailContent = "";

  Future<String> get _localPath async {
    final directory = await getApplicationSupportDirectory();

    return directory.absolute.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    _filePath = '$path/' + widget._report.reportName + '.csv';
    return File(_filePath).create();
  }

  List<List<dynamic>> getCsv_Xero() {
    List<List<dynamic>> rows = List<List<dynamic>>();
    rows.add([
      "*ContactName",
      "EmailAddress",
      "POAddressLine1",
      "POAddressLine2",
      "POAddressLine3",
      "POAddressLine4",
      "POCity",
      "PORegion",
      "POPostalCode",
      "POCountry",
      "*InvoiceNumber",
      "*InvoiceDate",
      "*DueDate",
      "InventoryItemCode",
      "Description",
      "*Quantity",
      "*UnitAmount",
      "*AccountCode",
      "*TaxType",
      "TrackingName1",
      "TrackingOption1",
      "TrackingName2",
      "TrackingOption2",
      "Currency",
    ]);

    List<ReceiptListItem> receipts = widget._report.getReceiptList(widget._userRepository.receiptRepository);
    String invoicePrefix = (DateTime.now().millisecondsSinceEpoch / 1000).toInt().toString();

    for (int i = 0; i < receipts.length; i++) {
      ReceiptListItem receipt = receipts[i];
      List<dynamic> row = List<dynamic>();
      rows.add([
        receipt.companyName,
        "",
        "",
        "",
        "",
        "",
        "",
        "",
        "",
        "",
        invoicePrefix + " - " + (i+1).toString(),
        receipt.receiptDatetime.toString(),
        (receipt.paymentDueDate == null || receipt.paymentDueDate.isBefore(DateTime(1900))) ?
          receipt.receiptDatetime.toString() : receipt.paymentDueDate.toString(),
        "",
        receipt.productName ?? "",
        "1",
        receipt.totalAmount.toString(),
        receipt.categoryName,
        (receipt.taxAmount > 0) ? "10% GST" : "GST Free",
        "",
        "",
        "",
        "",
        ""
      ]);
      if (row.length > 0) {
        rows.add(row);
      }
    }

    return rows;
  }

  List<List<dynamic>> getCsv_QB() {
    List<List<dynamic>> rows = List<List<dynamic>>();
    rows.add([
      "*BillNo",
      "*Supplier",
      "*BillDate",
      "*DueDate",
      "Terms",
      "Location",
      "Memo",
      "*Account",
      "LineDescription",
      "*LineAmount",
      "*LineTaxCode",
      "LineTaxAmount",
    ]);

    List<ReceiptListItem> receipts = widget._report.getReceiptList(widget._userRepository.receiptRepository);
    String invoicePrefix = (DateTime.now().millisecondsSinceEpoch / 1000).toInt().toString();

    for (int i = 0; i < receipts.length; i++) {
      ReceiptListItem receipt = receipts[i];
      List<dynamic> row = List<dynamic>();
      rows.add([
        invoicePrefix + " - " + (i+1).toString(),
        receipt.companyName,
        receipt.receiptDatetime.toString(),
        (receipt.paymentDueDate == null || receipt.paymentDueDate.isBefore(DateTime(1900))) ?
          receipt.receiptDatetime.toString() : receipt.paymentDueDate.toString(),
        "",
        "",
        receipt.notes ?? "",
        receipt.categoryName,
        receipt.productName ?? "",
        receipt.totalAmount.toString(),
        (receipt.taxAmount > 0) ? "10% GST" : "GST Free",
        receipt.taxAmount.toString()
      ]);
      if (row.length > 0) {
        rows.add(row);
      }
    }

    return rows;
  }

  getCsv() async {
    setState(() {
      _currentProcess = allTranslations.text('app.export-report.generating-report');
      _isProcessing = true;
    });

    List<List<dynamic>> rows = new List<List<dynamic>>();
    if (_accountingCompany == "Xero") {
      rows = getCsv_Xero();
    } else if (_accountingCompany == "QuickBooks") {
      rows = getCsv_QB();
    }

    File f = await _localFile.whenComplete(() {
      setState(() {
        _currentProcess = allTranslations.text('app.export-report.writing-csv');
      });
    });

    String csv = const ListToCsvConverter().convert(rows);
    f.writeAsString(csv);
  }

  final String username = 'superior.tech.au@hotmail.com';
  final String password = 'Intelligentreceipt1';

  void _showInSnackBar(String value, {IconData icon: Icons.error, color: Colors.red}) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(value), Icon(icon)],
      ),
      backgroundColor: color,
    ));
  }

  sendMailAndAttachment() async {
    final smtpServer = hotmail(username, password);
    final message = Message()
      ..from = Address("superior.tech.au@hotmail.com", 'Intelligent Receipt')
      ..recipients.add(ExportReport._emailController.text)
      //..bccRecipients.addAll(['bruce.song.au@gmail.com'])
      ..subject = _emailSubject
      ..text = _emailContent //'${person.message} from ${person.email}';
      ..attachments.add(FileAttachment(File(_filePath)));

    try {
      setState(() {
        _currentProcess = allTranslations.text('app.export-report.sending-email');
      });

      final sendReport = await send(message, smtpServer);
      _showInSnackBar(allTranslations.text('app.export-report.email-sent'),
          color: Colors.blue, icon: Icons.info);
    } on MailerException catch (e) {
      for (var p in e.problems) {
        _showInSnackBar(allTranslations.text('app.export-report.email-sent-failed') + '\n' + '${p.code}: ${p.msg}',
            color: Colors.red, icon: Icons.error);
      }
    }

    File(_filePath).delete();
  }

  List<DropdownMenuItem<String>> _getAccountingCompanyList() {
    var list = List<DropdownMenuItem<String>>();
    list.add(DropdownMenuItem<String>(value: "Xero", child: Text("Xero")));
    list.add(DropdownMenuItem<String>(value: "QuickBooks", child: Text("QuickBooks")));
    return list;
  }

  Future<void> _generateCsvAndSendEmail() async {
    if (_formkey.currentState.validate()) {
      _formkey.currentState.save();
      try {
        final result = await InternetAddress.lookup('google.com');
        if (result.isNotEmpty &&
            result[0].rawAddress.isNotEmpty) {
          await getCsv().then((v) {
            sendMailAndAttachment().whenComplete(() {
              setState(() {
                _isProcessing = false;
              });
            });
          });
        }
      } on SocketException catch (_) {
        _showInSnackBar(allTranslations.text('app.export-report.connect-internet'),
            color: Colors.red, icon: Icons.error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(title: Text(allTranslations.text('app.export-report.export-report-title'))),
      body: ListView(
        padding: EdgeInsets.only(top: 20, right: 10, left: 10, bottom: 20),
        children: <Widget>[
          Text(allTranslations.text('app.export-report.export-report-description')),
          Form(
            key: _formkey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: DropdownButtonFormField<String>(
                    isDense: true,
                    decoration:
                    InputDecoration(labelText: allTranslations.text('app.export-report.select-company')),
                    items: _getAccountingCompanyList(),
                    value: _accountingCompany,
                    onSaved: (String value) {
                      _accountingCompany = value;
                    },
                    onChanged: (String newValue) {
                      setState(() {
                        _accountingCompany = newValue;
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 1.0),
                  child: TextFormField(
                    controller: ExportReport._emailController,
                    validator: (str) => (str.length == 0)
                        ? allTranslations.text('app.export-report.please-enter-email')
                        : (!EmailUtils.isEmail(str))
                        ? allTranslations.text('app.export-report.enter-valid-email')
                        : null,
                    decoration: InputDecoration(
                        labelText: allTranslations.text('app.export-report.enter-email'),
                        suffixIcon: Icon(Icons.email)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 1.0),
                  child: TextFormField(
                    initialValue: widget._report == null ? "" : widget._report.reportName,
                    validator: (str) =>
                      (str.length == 0) ? allTranslations.text('app.export-report.please-enter-subject') : null,
                    decoration: InputDecoration(
                        labelText: allTranslations.text('app.export-report.enter-subject'),
                        suffixIcon: Icon(Icons.text_fields)),
                    onSaved: (String value) {
                      _emailSubject = value;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 1.0),
                  child: TextFormField(
                    initialValue: "",
                    maxLines: 10,
                    decoration: InputDecoration(
                        labelText: allTranslations.text('app.export-report.enter-content'),
                        suffixIcon: Icon(Icons.text_fields)),
                    onSaved: (String value) {
                      _emailContent = value;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: RaisedButton(
                    color: Theme.of(context).accentColor,
                    child: Text(allTranslations.text('app.export-report.send-email')),
                    onPressed: (_isProcessing) ? null : _generateCsvAndSendEmail,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Visibility(
                    visible: (_isProcessing) ? true : false,
                    child: Row(
                      children: <Widget>[
                        SizedBox(
                            child: CircularProgressIndicator(),
                            height: 25,
                            width: 25),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text("$_currentProcess"),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
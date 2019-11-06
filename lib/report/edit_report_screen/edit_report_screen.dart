import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intelligent_receipt/data_model/action_with_lable.dart';
import 'package:intelligent_receipt/data_model/data_result.dart';
import 'package:intelligent_receipt/data_model/enums.dart';
import 'package:intelligent_receipt/data_model/receipt.dart';
import 'package:intelligent_receipt/data_model/report.dart';
import 'package:intelligent_receipt/data_model/setting_repository.dart';
import 'package:intelligent_receipt/receipt/receipt_card/receipt_card.dart';
import 'package:intelligent_receipt/receipt/receipt_list/receipt_list.dart';
import 'package:intelligent_receipt/report/add_receipts_screen/add_receipts_screen.dart';
import 'package:intelligent_receipt/report/add_report_screen/report_button.dart';
import 'package:intelligent_receipt/user_repository.dart';

class EditReportScreen extends StatefulWidget {
  final String title;
  final UserRepository _userRepository;
  final int _reportId;
  EditReportScreen(
      {Key key, @required UserRepository userRepository, this.title, int reportId})
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

  bool isLoginButtonEnabled() {
    return isPopulated;
  }

  var items = List<Currency>();
  String _reportName;
  String _reportDescription;
  Report _report;
  List<ReceiptListItem> _receiptList;
  String _totalAmount;
  Currency _currency;


  @override
  void initState() {
    duplicateItems = _userRepository.settingRepository.getCurrencies();
    items.addAll(duplicateItems);
    super.initState();
    _reportName = _userRepository.reportRepository.getReport(widget._reportId).reportName;
    _reportDescription = _userRepository.reportRepository.getReport(widget._reportId).description;
    _emailController.text = _reportName;
    _passwordController.text = _reportDescription;
//    _receiptList = _userRepository.reportRepository.getReport(widget._reportId).getReceiptList(_userRepository.receiptRepository);
//    _totalAmount = _userRepository.reportRepository.getReport(widget._reportId).getTotalAmount(_userRepository.receiptRepository);
    _report = _userRepository.reportRepository.getReport(widget._reportId);
    _receiptList = _report.getReceiptList(_userRepository.receiptRepository);
    _totalAmount = _report.getTotalAmount(_userRepository.receiptRepository).toStringAsFixed(2);
    print('${_report} ${_receiptList} ${_totalAmount}');
    _userRepository.receiptRepository.cachedReceiptItems = _receiptList;
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
    for (int i = 0; i < _userRepository.receiptRepository.cachedReceiptItems.length; i++) {
      if (_userRepository.receiptRepository.cachedReceiptItems[i].id == inputId) {
        toBeRemoved = i;
      }
    }
    _userRepository.receiptRepository.candidateReceiptItems.add(_userRepository.receiptRepository.cachedReceiptItems[toBeRemoved]);
    _userRepository.receiptRepository.cachedReceiptItems.removeAt(toBeRemoved);
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    List<ActionWithLabel> actions = [];
    ActionWithLabel d = new ActionWithLabel();
    d.action = removeAction;
    d.label = 'Remove';
    actions.add(d);
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
                          FutureBuilder<DataResult>(
                              future: _userRepository.settingRepository
                                  .getSettingsFromServer(),
                              builder: (BuildContext context,
                                  AsyncSnapshot<DataResult> snapshot) {
                                switch (snapshot.connectionState) {
                                  case ConnectionState.none:
                                    return new Text('Loading...');
                                  case ConnectionState.waiting:
                                    return new Center(
                                        child: new CircularProgressIndicator());
                                  case ConnectionState.active:
                                    return new Text('');
                                  case ConnectionState.done:
                                    {
                                      return FutureBuilder<DataResult>(
                                          future: _userRepository.settingRepository
                                              .getCurrenciesFromServer(),
                                          builder: (BuildContext context,
                                              AsyncSnapshot<DataResult> snapshot) {
                                            switch (snapshot.connectionState) {
                                              case ConnectionState.none:
                                                return new Text('Loading...');
                                              case ConnectionState.waiting:
                                                return new Center(
                                                    child: new CircularProgressIndicator());
                                              case ConnectionState.active:
                                                return new Text('');
                                              case ConnectionState.done:
                                                if (snapshot.hasError) {
                                                  return
//                                                    new Text(
//                                                    '${snapshot.error}',
//                                                    style: TextStyle(color: Colors.red),
//                                                  );
                                                    AutoSizeText(
                                                      '${snapshot.error}',
                                                      style: TextStyle(fontSize: 14),
                                                      minFontSize: 1,
                                                      maxLines: 3,
                                                      overflow: TextOverflow.ellipsis,
                                                    );
                                                } else {
                                                  _currency = _userRepository
                                                      .settingRepository
                                                      .getDefaultCurrency();
                                                  double _tempAmount = 0;
                                                  for (var i = 0; i < _userRepository.receiptRepository.cachedReceiptItems.length; i++) {
                                                    _tempAmount += _userRepository.receiptRepository.cachedReceiptItems[i]?.totalAmount;}
                                                  _totalAmount = _tempAmount.toStringAsFixed(2);
                                                  return (_currency != null) ? Expanded(
                                                    child: Text("Total: ${_currency.symbol} ${_totalAmount}"),
//                                        children: <Widget>[//
////                                          Text("${_currency.name} "),
////                                          Text("${_currency.symbol}"),
//                                        ],
                                                  ) : AutoSizeText(
                                                    'Network Error',
                                                    style: TextStyle(fontSize: 10),
                                                    minFontSize: 4,
                                                    maxLines: 3,
                                                    overflow: TextOverflow.ellipsis,
                                                  );
                                                }

                                            }
                                          });
                                    }
                                }
                              }),
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
                itemCount: _userRepository.receiptRepository.cachedReceiptItems.length,
                itemBuilder: (context, index) {
                  return ReceiptCard(
                    receiptItem: _userRepository.receiptRepository.cachedReceiptItems[index],
                    actions: actions,
                  );
                })
//              ReceiptList(
//                  userRepository: _userRepository,
//                  receiptStatusType: ReceiptStatusType.Reviewed),
            ),
            Expanded(
              flex: 1,
              child:
              Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    ReportButton(
                      onPressed:
                      isLoginButtonEnabled() ? _onReportSaved : null,
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

  Future<void> addReport(Report report) async{
    await _userRepository.reportRepository.addReport(report);
//    await _userRepository.reportRepository.updateReport(report, true);
    setState(() {

    });
  }

  Future<void> saveReport(Report report) async{
    await _userRepository.reportRepository.updateReport(report, true);
//    await _userRepository.reportRepository.updateReport(report, true);
    setState(() {

    });
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
    for (int i = 0; i < _userRepository.receiptRepository.cachedReceiptItems.length; i++) {
      _report.receiptIds.add(_userRepository.receiptRepository.cachedReceiptItems[i].id);
    }
    saveReport(_report);
    print('Save ${_emailController.text} ${_passwordController.text} ${_userRepository.receiptRepository.cachedReceiptItems}');
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

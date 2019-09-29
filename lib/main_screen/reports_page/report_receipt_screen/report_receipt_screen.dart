import 'package:flutter/material.dart';
import 'package:intelligent_receipt/data_model/data_result.dart';
import 'package:intelligent_receipt/data_model/enums.dart';
import 'package:intelligent_receipt/data_model/setting_repository.dart';
import 'package:intelligent_receipt/main_screen/reports_page/report_receipt_screen/report_button.dart';
import 'package:intelligent_receipt/receipt/receipt_list/receipt_list.dart';
import 'package:intelligent_receipt/user_repository.dart';

class ReportReceiptScreen extends StatefulWidget {
  final String title;
  final UserRepository _userRepository;
  ReportReceiptScreen(
      {Key key, @required UserRepository userRepository, this.title})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(key: key) {}

  @override
  _ReportReceiptScreenState createState() => new _ReportReceiptScreenState();
}

class _ReportReceiptScreenState extends State<ReportReceiptScreen> {
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

  @override
  Widget build(BuildContext context) {
//    duplicateItems = _userRepository.settingRepository.getCurrencies();
    return new Scaffold(
      appBar: new AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 2,
              child: Form(
                child: ListView(
                  children: <Widget>[
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        icon: Icon(Icons.title),
                        labelText: 'Report Name',
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
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: ReceiptList(
                  userRepository: _userRepository,
                  receiptStatusType: ReceiptStatusType.Reviewed),
            ),
            Expanded(
              flex: 1,
              child:
              Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Row(
//                        crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    ReportButton(
                      onPressed:
                      isLoginButtonEnabled() ? _onReportSaved : null,
                      buttonName: 'Save Report',
                    ),
                    ReportButton(
                      onPressed:
                      isLoginButtonEnabled() ? _onReportSubmitted : null,
                      buttonName: 'Submit Report',
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

  void _onReportSaved() {
    print('Save ${_emailController.text} ${_passwordController.text}');
  }

  void _onReportSubmitted() {
    print('Submit ${_emailController.text} ${_passwordController.text}');
  }
}

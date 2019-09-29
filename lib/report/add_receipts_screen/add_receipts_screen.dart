import 'package:flutter/material.dart';
import 'package:intelligent_receipt/data_model/data_result.dart';
import 'package:intelligent_receipt/data_model/enums.dart';
import 'package:intelligent_receipt/data_model/receipt.dart';
import 'package:intelligent_receipt/data_model/setting_repository.dart';
import 'package:intelligent_receipt/receipt/receipt_card/receipt_card.dart';
import 'package:intelligent_receipt/receipt/receipt_list/receipt_list.dart';
import 'package:intelligent_receipt/user_repository.dart';

class AddReceiptsScreen extends StatefulWidget {
  final String title;
  final UserRepository _userRepository;
  AddReceiptsScreen(
      {Key key, @required UserRepository userRepository, this.title})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(key: key) {}

  @override
  _AddReceiptsScreenState createState() => new _AddReceiptsScreenState();
}

class _AddReceiptsScreenState extends State<AddReceiptsScreen> {
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
  List<ReceiptListItem> cachedReceiptItems = new List<ReceiptListItem>();
  final List<ActionWithLable> actions = [];

  ReceiptStatusType _receiptStatusType = ReceiptStatusType.Reviewed;
  List<ReceiptListItem> candidateReceiptItems;

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
    for (var i = 0; i < cachedReceiptItems.length; i++) {
      if (cachedReceiptItems[i].id == inputId) {
        toBeRemoved = i;
      }
    }
    cachedReceiptItems.remove(cachedReceiptItems[toBeRemoved]);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
//    duplicateItems = _userRepository.settingRepository.getCurrencies();
    ActionWithLable d = new ActionWithLable();
    d.action = removeAction;
    d.lable = 'Remove';
    actions.add(d);
    return Scaffold(
        appBar: new AppBar(
          title: Text(widget.title),
        ),
        body: OrientationBuilder(builder: (context, orientation) {
          return Column(
            children: <Widget>[
              Flexible(
                flex: 2,
                fit: FlexFit.tight,
                child: FutureBuilder<DataResult>(
                    future: _userRepository.receiptRepository
                        .getReceiptsFromServer(),
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
                            return new Text(
                              '${snapshot.error}',
                              style: TextStyle(color: Colors.red),
                            );
                          } else {
                            if (snapshot.data.success) {
                              candidateReceiptItems =
                                  _userRepository.receiptRepository
                                      .getReceiptItems(
                                          ReceiptStatusType.Reviewed);
                              return ReceiptList(
                                userRepository: _userRepository,
                                receiptStatusType: _receiptStatusType,
                                receiptItems: candidateReceiptItems,
                              );
                            } else {
                              return Column(
                                children: <Widget>[
                                  Text(
                                      'Failed retrieving data, error code is ${snapshot.data.messageCode}'),
                                  Text(
                                      'Error message is ${snapshot.data.message}'),
                                ],
                              );
                            }
                          }
                          ;
                      }
                    }),
              ),
            ],
          );
        }));
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

  void _onAddReceipts() {
    print('add Receipts');
  }
}

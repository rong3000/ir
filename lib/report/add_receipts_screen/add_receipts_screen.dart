import 'package:flutter/material.dart';
import 'package:intelligent_receipt/data_model/action_with_lable.dart';
import 'package:intelligent_receipt/data_model/data_result.dart';
import 'package:intelligent_receipt/data_model/enums.dart';
import 'package:intelligent_receipt/data_model/exchange_rate/exchange.dart';
import 'package:intelligent_receipt/data_model/receipt.dart';
import 'package:intelligent_receipt/data_model/receipt_repository.dart';
import 'package:intelligent_receipt/data_model/setting_repository.dart';
import 'package:intelligent_receipt/data_model/webservice.dart';
import 'package:intelligent_receipt/receipt/receipt_card/receipt_card.dart';
import 'package:intelligent_receipt/receipt/receipt_list/receipt_list.dart';
import 'package:intelligent_receipt/user_repository.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';

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
  List<ReceiptListItem> candidateReceiptItems;
  Currency baseCurrency;


  bool get isPopulated => _emailController.text.isNotEmpty;

  bool isLoginButtonEnabled() {
    return isPopulated;
  }

  var items = List<Currency>();

  ReceiptStatusType _receiptStatusType = ReceiptStatusType.Reviewed;

  Future<void> getDataResultFromServer() async {
    print('4');
//    dataResult = await _userRepository.receiptRepository.getReceiptsFromServer(forceRefresh: true);
    await _userRepository.receiptRepository
        .getReceiptsFromServer(forceRefresh: true);
    print('5');
    setState(() {
      print('6');
    });
    print('7');
  }

  @override
  void initState() {
    getDataResultFromServer();
    duplicateItems = _userRepository.settingRepository.getCurrencies();
    items.addAll(duplicateItems);
    super.initState();
    candidateReceiptItems = _userRepository.receiptRepository.candidateReceiptItems;
//    getBaseCurrency();
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

//  void removeAction(int inputId) {
//    int toBeRemoved;
//    for (var i = 0; i < cachedReceiptItems.length; i++) {
//      if (cachedReceiptItems[i].id == inputId) {
//        toBeRemoved = i;
//      }
//    }
//    cachedReceiptItems.remove(cachedReceiptItems[toBeRemoved]);
//    setState(() {});
//  }

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

  Future<void> getBaseCurrency() async {
    await _userRepository.settingRepository.getSettingsFromServer();
    setState(() {
//      baseCurrency = _userRepository.settingRepository.getDefaultCurrency();
    });
  }

  Future<void> calculateExchange(int id) async {

    await _userRepository.settingRepository.getSettingsFromServer();
    baseCurrency = _userRepository.settingRepository.getDefaultCurrency();
    if (_userRepository.receiptRepository.getReceiptItem(id).currencyCode == baseCurrency.code)
    {
      amountPair cachedReceiptItemsAmount2 = new amountPair();
      cachedReceiptItemsAmount2.amount = _userRepository.receiptRepository.getReceiptItem(id).totalAmount;
      cachedReceiptItemsAmount2.id = id;
      _userRepository.receiptRepository.cachedReceiptItemsAmount.add(cachedReceiptItemsAmount2);
      print('id ${id} add to group and ${cachedReceiptItemsAmount2}');
    }
    if (_userRepository.receiptRepository.getReceiptItem(id).currencyCode != baseCurrency.code) {
      amountPair cachedReceiptItemsAmount1 = new amountPair();

      Exchange exchange = await getExchangeRateFromServer(
          _userRepository.receiptRepository
              .getReceiptItem(id)
              .receiptDatetime, baseCurrency.code);
      cachedReceiptItemsAmount1.amount = _userRepository.receiptRepository
          .getReceiptItem(id)
          .totalAmount /
          exchange.rates.getRate(_userRepository.receiptRepository
              .getReceiptItem(id)
              .currencyCode);

      cachedReceiptItemsAmount1.id = id;
      _userRepository.receiptRepository.cachedReceiptItemsAmount.add(
          cachedReceiptItemsAmount1);
    }
  }

  void addAction(int id) {
    _userRepository.receiptRepository.cachedReceiptItems.add(_userRepository.receiptRepository.getReceiptItem(id));
    calculateExchange(id);

    candidateReceiptItems = _userRepository.receiptRepository.removeCandidateItems(id);
        print('id ${id} add to group and ');
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
//    duplicateItems = _userRepository.settingRepository.getCurrencies();
    List<ActionWithLabel> actions = [];
    ActionWithLabel a = new ActionWithLabel();
    a.action = addAction;
    a.label = 'Add to Group';
    actions.add(a);
    return Scaffold(
      appBar: new AppBar(
        title: Text(widget.title),
      ),
      body: OrientationBuilder(builder: (context, orientation) {
        if (!_userRepository.receiptRepository.receipts.isNotEmpty) {
          print('8');
          return Text('Loading...');
        } else
          return Column(children: <Widget>[
            Flexible(
              flex: 2,
              fit: FlexFit.tight,
              child: ReceiptList(
                userRepository: _userRepository,
                receiptStatusType: _receiptStatusType,
                receiptItems: candidateReceiptItems,
                actions: actions,
              ),
            )
          ]);
      }),
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

  void _onAddReceipts() {
    print('add Receipts');
  }
}

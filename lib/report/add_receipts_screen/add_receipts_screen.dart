import 'package:flutter/material.dart';
import 'package:intelligent_receipt/data_model/action_with_lable.dart';
import 'package:intelligent_receipt/data_model/enums.dart';
import 'package:intelligent_receipt/data_model/receipt.dart';
import 'package:intelligent_receipt/data_model/receipt_repository.dart';
import 'package:intelligent_receipt/receipt/receipt_list/receipt_list.dart';
import 'package:intelligent_receipt/report/add_receipts_screen/receipt_search_delegate.dart';
import 'package:intelligent_receipt/translations/global_translations.dart';
import 'package:intelligent_receipt/user_repository.dart';

class AddReceiptsScreen extends StatefulWidget {
  final UserRepository _userRepository;
  final List<ReceiptListItem> _candidateItems;
  final void Function(ReceiptListItem) _addReceiptToGroupFunc;
  AddReceiptsScreen(
      {Key key, @required UserRepository userRepository, @required List<ReceiptListItem> candidateItems, @required void Function(ReceiptListItem) addReceiptToGroupFunc})
      : assert(userRepository != null),
        _userRepository = userRepository,
        _candidateItems = candidateItems,
        _addReceiptToGroupFunc = addReceiptToGroupFunc,
        super(key: key);

  @override
  _AddReceiptsScreenState createState() => new _AddReceiptsScreenState();
}

class _AddReceiptsScreenState extends State<AddReceiptsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  UserRepository get _userRepository => widget._userRepository;
  ReceiptStatusType _receiptStatusType = ReceiptStatusType.Reviewed;
  List<ReceiptListItem> get _candidateItems => widget._candidateItems;

  @override
  void initState() {
    super.initState();
  }

  void _showInSnackBar(String value, {IconData icon: Icons.error, color: Colors.red}) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(value), Icon(icon)],
      ),
      backgroundColor: color,
    ));
  }

  void addAction(int id) {
    Iterable<ReceiptListItem> iter = _candidateItems.where((element) {
      return (element.id == id);
    });

    if (iter.isNotEmpty) {
      ReceiptListItem item = iter.first;
      widget._addReceiptToGroupFunc(item);
      _candidateItems.remove(item);
      _showInSnackBar(allTranslations.text('app.add-receipts-screen.receipt-added-success'), color: Colors.blue, icon: Icons.info);
    } else {
      _showInSnackBar(allTranslations.text('app.add-receipts-screen.receipt-added-fail'));
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    List<ActionWithLabel> actions = [];
    actions.add(ActionWithLabel()
      ..action = addAction
      ..label = allTranslations.text('app.add-receipts-screen.add-to-group-label')
      );

    return Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: Text(allTranslations.text('app.add-receipts-screen.title')),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.search,
            ),
            onPressed: () {
              showSearch(context: context, delegate: ReceiptSearchDelegate(_userRepository, _receiptStatusType, _candidateItems, actions, widget._addReceiptToGroupFunc));
            },
          ),
        ],
      ),
      body: OrientationBuilder(builder: (context, orientation) {
        if (!_userRepository.receiptRepository.receipts.isNotEmpty) {
          return Text(allTranslations.text('app.common.loading-status'));
        } else
          return Column(children: <Widget>[
            Flexible(
              flex: 2,
              fit: FlexFit.tight,
              child: ReceiptList(
                userRepository: _userRepository,
                receiptStatusType: _receiptStatusType,
                receiptItems: _candidateItems,
                actions: actions,
              ),
            )
          ]);
      }),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

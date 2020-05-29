import 'package:flutter/material.dart';
import 'package:intelligent_receipt/data_model/enums.dart';
import 'package:intelligent_receipt/data_model/receipt.dart';
import 'package:intelligent_receipt/receipt/receipt_list/receipt_list.dart';
import 'package:intelligent_receipt/translations/global_translations.dart';
import 'package:intelligent_receipt/user_repository.dart';
import 'package:intelligent_receipt/data_model/action_with_lable.dart';

class ReceiptSearchDelegate extends SearchDelegate<String> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final UserRepository _userRepository;
  final ReceiptStatusType _receiptStatusType;
  final List<ReceiptListItem> _candidateItems;
  final List<ActionWithLabel> _actions;
  final void Function(ReceiptListItem) _addReceiptToGroupFunc;

  ReceiptSearchDelegate(
      UserRepository userRepository,
      ReceiptStatusType receiptStatusType,
      List<ReceiptListItem> candidateItems,
      List<ActionWithLabel> actions,
      void Function(ReceiptListItem) addReceiptToGroupFunc)
      : _userRepository = userRepository,
        _receiptStatusType = receiptStatusType,
        _candidateItems = candidateItems,
        _actions = actions,
        _addReceiptToGroupFunc = addReceiptToGroupFunc,
        super();

  @override
  ThemeData appBarTheme(BuildContext context) => Theme.of(context);

  @override
  List<Widget> buildActions(BuildContext context) {
    return <Widget>[
      if (this.query.isNotEmpty)
        IconButton(
          tooltip: 'Clear',
          icon: const Icon(Icons.clear),
          onPressed: () => this.query = '',
        )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      tooltip: 'Back',
      icon: Icon(Icons.arrow_back),
      onPressed: () => this.close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    showSuggestions(context);
    return Column(children: <Widget>[
      Flexible(
        flex: 2,
        fit: FlexFit.tight,
        child: ReceiptList(
          userRepository: _userRepository,
          receiptStatusType: _receiptStatusType,
          receiptItems: _candidateItems,
          actions: _actions,
        ),
      )
    ]);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    Iterable<ReceiptListItem> suggestions = _candidateItems;
    if (this.query.isNotEmpty) {
      suggestions = _candidateItems
          .where((receipt) =>
              (receipt.altTotalAmount.toString() ?? '')
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              (receipt.productName ?? '')
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              (receipt.companyName ?? '')
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              (receipt.notes ?? '').toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    return _buildSuggestionsList(suggestions, context);
  }

  void _showInSnackBar(String value,
      {IconData icon: Icons.error, color: Colors.red}) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(value), Icon(icon)],
      ),
      backgroundColor: color,
    ));
  }

  Widget _buildSuggestionsList(Iterable<ReceiptListItem> suggestions, BuildContext context) {
    void addAction(int id) {
      Iterable<ReceiptListItem> iter = _candidateItems.where((element) {
        return (element.id == id);
      });

      if (iter.isNotEmpty) {
        ReceiptListItem item = iter.first;
        _addReceiptToGroupFunc(item);
        _candidateItems.remove(item);
        showResults(context);
        _showInSnackBar(
            allTranslations
                .text('app.add-receipts-screen.receipt-added-success'),
            color: Colors.blue,
            icon: Icons.info);
      } else {
        _showInSnackBar(
            allTranslations.text('app.add-receipts-screen.receipt-added-fail'));
      }
    }

    List<ActionWithLabel> action_suggestion = [];
    action_suggestion.add(ActionWithLabel()
      ..action = addAction
      ..label =
          allTranslations.text('app.add-receipts-screen.add-to-group-label'));

    return Column(children: <Widget>[
      Flexible(
        flex: 2,
        fit: FlexFit.tight,
        child: ReceiptList(
          userRepository: _userRepository,
          receiptStatusType: _receiptStatusType,
          receiptItems: suggestions,
          actions: action_suggestion,
        ),
      )
    ]);
  }
}
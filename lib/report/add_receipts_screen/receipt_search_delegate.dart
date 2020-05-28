import 'package:flutter/material.dart';
import 'package:intelligent_receipt/data_model/enums.dart';
import 'package:intelligent_receipt/data_model/receipt.dart';
import 'package:intelligent_receipt/receipt/receipt_list/receipt_list.dart';
import 'package:intelligent_receipt/user_repository.dart';
import 'package:intelligent_receipt/data_model/action_with_lable.dart';

class ReceiptSearchDelegate extends SearchDelegate<String> {
  final UserRepository _userRepository;
  final ReceiptStatusType _receiptStatusType;
  final List<ReceiptListItem> _candidateItems;
  final List<ActionWithLabel> _actions;

  ReceiptSearchDelegate(UserRepository userRepository, ReceiptStatusType receiptStatusType, List<ReceiptListItem> candidateItems, List<ActionWithLabel> actions)
      : _userRepository = userRepository, _receiptStatusType = receiptStatusType, _candidateItems = candidateItems, _actions = actions,
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
    return Container();
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
    return _buildSuggestionsList(suggestions);
  }

  Widget _buildSuggestionsList(Iterable<ReceiptListItem> suggestions) {
    return Column(children: <Widget>[
      Flexible(
        flex: 2,
        fit: FlexFit.tight,
        child: ReceiptList(
          userRepository: _userRepository,
          receiptStatusType: _receiptStatusType,
          receiptItems: suggestions,
          actions: _actions,
        ),
      )
    ]);
  }
}

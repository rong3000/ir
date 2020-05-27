import 'package:flutter/material.dart';
import 'package:intelligent_receipt/data_model/receipt.dart';
import 'package:provider/provider.dart';

/// Delegate class to search pages in the list of
class ReceiptSearchDelegate extends SearchDelegate<String> {
  final List<ReceiptListItem> _candidateItems;

  ReceiptSearchDelegate(List<ReceiptListItem> candidateItems)
      : _candidateItems = candidateItems,
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
    // Since we never call showResults() we don't need to impl this function.
    return Container();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    Iterable<ReceiptListItem> suggestions = [];
    if (this.query.isNotEmpty) {
      Iterable<ReceiptListItem> suggestions = _candidateItems
          .where((receipt) =>
              (receipt.altTotalAmount.toString() ?? '')
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              (receipt.productName ?? '')
                  .toLowerCase()
                  .contains(query.toLowerCase()) ||
              (receipt.toString() ?? '')
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
    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (BuildContext context, int i) {
        final route = suggestions.elementAt(i);
        final routeGroup = kRouteNameToRouteGroup[route.routeName];
        return ListTile(
          leading: query.isEmpty ? Icon(Icons.history) : routeGroup.icon,
          title: SubstringHighlight(
            text: '${routeGroup.groupName}/${route.title}',
            term: query,
            textStyle: Theme.of(context)
                .textTheme
                .body1
                .copyWith(fontWeight: FontWeight.bold),
          ),
          subtitle: route.description == null
              ? null
              : SubstringHighlight(
                  text: route.description,
                  term: query,
                  textStyle: Theme.of(context).textTheme.body1,
                ),
          onTap: () {
            Provider.of<MyAppSettings>(context, listen: false)
                .addSearchHistory(route.routeName);
            Navigator.of(context).popAndPushNamed(route.routeName);
          },
          trailing: Icon(Icons.keyboard_arrow_right),
        );
      },
    );
  }
}

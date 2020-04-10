import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intelligent_receipt/data_model/action_with_lable.dart';
import 'package:intelligent_receipt/data_model/receipt.dart';
import './bloc/archived_receipts_bloc.dart';
import './bloc/archived_receipts_events.dart';
import './bloc/archived_receipts_state.dart';
import './loading_spinner.dart';
import 'package:intelligent_receipt/receipt/receipt_card/receipt_card.dart';
import 'package:intelligent_receipt/translations/global_translations.dart';

class ArchivedReceiptsListPage extends StatefulWidget {
  final String yearMonth;
  ArchivedReceiptsListPage(this.yearMonth);

  @override
  State<StatefulWidget> createState() {
    return _ArchivedReceiptsListSate();
  }
}

class _ArchivedReceiptsListSate extends State<ArchivedReceiptsListPage> {
  ArchivedReceiptsBloc _archivedReceiptsBloc;
  List<ReceiptListItem> _receipts = [];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _hasChanges = false;

  @override
  void initState() {
    _archivedReceiptsBloc = BlocProvider.of<ArchivedReceiptsBloc>(context);
    _archivedReceiptsBloc.dispatch(GetArchivedReceipts(widget.yearMonth));

    var state = _archivedReceiptsBloc.state;
    state.listen((state) {
      if (state is UnArchivedReceiptFailState) {
        _showInSnackBar(allTranslations
            .text('app.archived-receipts-screen.fail-un-archive'));
      }
    });
    super.initState();
  }

  unArchiveAction(int receiptId) {
    _hasChanges = true;
    _archivedReceiptsBloc.dispatch(UnArchivedReceipt(receiptId));
  }

  List<Widget> _buildReceiptCards() {
    var result = List<Widget>();
    for (var receipt in _receipts) {
      var action = ActionWithLabel();
      action.action = unArchiveAction;
      action.icon = Icons.unarchive;
      action.label =
          allTranslations.text('app.archived-receipts-screen.un-archive-label');
      result.add(ReceiptCard(receiptItem: receipt, actions: [action]));
    }
    return result;
  }

  void _showInSnackBar(String value,
      {IconData icon: Icons.error, color: Colors.red, duration: 2}) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(value), Icon(icon)],
      ),
      backgroundColor: color,
      duration: Duration(seconds: duration),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
          title:
              Text(allTranslations.text('app.archived-receipts-screen.title')),
          leading: GestureDetector(
              child: Icon(Icons.arrow_back),
              onTap: () {
                Navigator.of(context).pop(_hasChanges);
              })),
      body: BlocBuilder(
        bloc: _archivedReceiptsBloc,
        builder: (BuildContext context, ArchivedReceiptsState state) {
          if (state is GetArchivedReceiptsSuccessState) {
            _receipts = state.receipts;
            return ListView(children: _buildReceiptCards());
          } else if (state is GetArchivedReceiptsFailState) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Card(
                      child: Text(allTranslations
                          .text('app.archived-_receipt-screen.fail-load')),
                    ),
                  ],
                )
              ],
            );
          } else if (state is UnArchivedReceiptFailState) {
            return ListView(children: _buildReceiptCards());
          } else if (state is UnArchivedReceiptSuccessState) {
            _receipts.removeWhere((item) => item.id == state.receiptId);
            return ListView(children: _buildReceiptCards());
          } else {
            return ArchiveLoadingSpinner();
          }
        },
      ),
    );
  }
}

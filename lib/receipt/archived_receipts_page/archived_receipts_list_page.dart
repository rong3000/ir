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
import 'package:intelligent_receipt/receipt/add_edit_reciept_manual/add_edit_receipt_manual.dart';
import 'package:intelligent_receipt/data_model/receipt_repository.dart';
import 'package:intelligent_receipt/user_repository.dart';

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
  UserRepository _userRepository;

  @override
  void initState() {
    _userRepository = RepositoryProvider.of<UserRepository>(context);
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

  Future<void> reviewAction(int receiptId) async {
    // Try to get the receipt detailed information from server
    DataResult dataResult = await _userRepository.receiptRepository.getReceipt(receiptId);
    if (dataResult.success) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) {
          return AddEditReiptForm(dataResult.obj as Receipt, disableSave: true);
        }),
      );
    } else {
      _showInSnackBar("${allTranslations.text("app.receipts-page.failed-review-receipt-message")} \n${dataResult.message}");
    }
  }

  List<Widget> _buildReceiptCards() {
    var result = List<Widget>();
    for (var receipt in _receipts) {
      ActionWithLabel actionReview = new ActionWithLabel();
      actionReview.action = reviewAction;
      actionReview.label = allTranslations.text('words.review');
      actionReview.icon = Icons.edit;
      var archiveUnarchive = ActionWithLabel();
      archiveUnarchive.action = unArchiveAction;
      archiveUnarchive.icon = Icons.unarchive;
      archiveUnarchive.label = allTranslations.text('app.archived-receipts-screen.un-archive-label');

      result.add(ReceiptCard(receiptItem: receipt, actions: [actionReview, archiveUnarchive]));
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

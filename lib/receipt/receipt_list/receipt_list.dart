import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intelligent_receipt/data_model/enums.dart';
import 'package:intelligent_receipt/data_model/receipt_repository.dart';
import 'package:intelligent_receipt/user_repository.dart';

class ReceiptList extends StatefulWidget {
  final UserRepository _userRepository;
  final ReceiptStatusType _receiptStatusType;

  ReceiptList({
    Key key,
    @required UserRepository userRepository,
    @required ReceiptStatusType receiptStatusType,
  })  : assert(userRepository != null),
        _userRepository = userRepository,
        _receiptStatusType = receiptStatusType,
        super(key: key) {}

  @override
  ReceiptListState createState() => ReceiptListState();
}

class ReceiptListState extends State<ReceiptList> {
  final List<String> items = List<String>.generate(10000, (i) => "Item $i");
  ScrollController _scrollController = ScrollController();
  List<ReceiptListItem> receipts;
  List<ReceiptListItem> selectedReceipts;
  bool sort;
  int start = 0;
  int end;
  bool forceRefresh;
  int receiptItemCount;
  bool fromServer;
  int refreshCount = 0;
  int loadMoreCount = 0;
  OverlayEntry subMenuOverlayEntry;
  GlobalKey anchorKey = GlobalKey();
  double dx;
  double dy;
  double dx2;
  double dy2;

  UserRepository get _userRepository => widget._userRepository;
  get _receiptStatusType => widget._receiptStatusType;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: FutureBuilder<DataResult>(
            future: _userRepository.receiptRepository
                .getReceiptsFromServer(forceRefresh: forceRefresh),
            builder:
                (BuildContext context, AsyncSnapshot<DataResult> snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                  return new Text('Loading...');
                case ConnectionState.waiting:
                  return new Center(child: new CircularProgressIndicator());
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
                      receiptItemCount = _userRepository.receiptRepository
                          .getReceiptItemsCount(_receiptStatusType);
                      return ListView.builder(
                        itemCount: receiptItemCount,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text('${_userRepository
                                .receiptRepository.receipts[index].companyName}'),
                          );
                        },
                      );
                    } else {
                      return Column(
                        children: <Widget>[
                          Text(
                              'Failed retrieving data, error code is ${snapshot.data.messageCode}'),
                          Text('Error message is ${snapshot.data.message}'),
                        ],
                      );
                    }
                  }
                  ;
              }
            }),
      ),
    );
  }
}

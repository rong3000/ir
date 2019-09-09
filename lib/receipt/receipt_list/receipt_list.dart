import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intelligent_receipt/data_model/enums.dart';
import 'package:intelligent_receipt/data_model/receipt_repository.dart';
import 'package:intelligent_receipt/receipt/receipt_card/receipt_card.dart';
import 'package:intelligent_receipt/user_repository.dart';
import 'package:intl/intl.dart';

import '../../data_model/webservice.dart';

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
  bool ascending;
  int type;

  UserRepository get _userRepository => widget._userRepository;
  get _receiptStatusType => widget._receiptStatusType;

  @override
  void initState() {
    forceRefresh = true;
    ascending = false;
    type = 1;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle titleStyle =
        theme.textTheme.headline.copyWith(color: Colors.white);
    final TextStyle descriptionStyle = theme.textTheme.subhead;

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
                      return Scaffold(
//                        appBar: AppBar(title: SortingBar(userRepository: _userRepository),),
                        appBar: AppBar(
                          title: Container(
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  flex: 1,
                                  child: TextField(
//                                  controller: _controller,
                                    decoration: new InputDecoration(
                                      hintText: 'Start search',
                                      icon: Icon(Icons.search),
                                    ),
                                  ),
                                ),
                                RaisedButton(
                                  onPressed: () {
                                    setState(() {
                                      forceRefresh = false;
                                      ascending = !ascending;
                                      type =1;
                                      print("${ascending} ${forceRefresh}");
//            if (columnIndex == 0) {
//                                      if (ascending) {
//                                        _userRepository
//                                            .receiptRepository.receipts
//                                            .sort((a, b) => a.totalAmount
//                                                .compareTo(b.totalAmount));
//                                      } else {
//                                        _userRepository
//                                            .receiptRepository.receipts
//                                            .sort((a, b) => b.totalAmount
//                                                .compareTo(a.totalAmount));
//                                      }
                                    });
//            }
                                  },
                                  child: Text('Search'),
                                ),
                              ],
                            ),
                          ),
                        ),
                        body: ListView.builder(
                          itemCount: receiptItemCount,
                          itemBuilder: (context, index) {
                            return ReceiptCard(
                                    index: index,
                                    userRepository: _userRepository,
                                    receiptStatusType: _receiptStatusType,
                            type: type, ascending: ascending)
//                            ListTile(
//                            title: Text('${_userRepository
//                                .receiptRepository.getReceiptItems(_receiptStatusType)[index].companyName}'),
//                          )
                                ;
                          },
                        ),
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

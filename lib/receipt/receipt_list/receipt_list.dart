import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intelligent_receipt/data_model/enums.dart';
import 'package:intelligent_receipt/data_model/receipt_repository.dart';
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

  UserRepository get _userRepository => widget._userRepository;
  get _receiptStatusType => widget._receiptStatusType;

  CachedNetworkImage getImage(String imagePath) {
    return new CachedNetworkImage(
      imageUrl: Urls.GetImage + "/" + Uri.encodeComponent(imagePath),
      placeholder: (context, url) => new CircularProgressIndicator(),
      errorWidget: (context, url, error) => new Icon(Icons.error),
    );
  }

  @override
  void initState() {
    forceRefresh = true;
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
                      return ListView.builder(
                        itemCount: receiptItemCount,
                        itemBuilder: (context, index) {
                          return Card(
                            clipBehavior: Clip.antiAlias,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                SizedBox(
                                  height: 50,
                                  child: Stack(
                                    children: <Widget>[
                                      Positioned.fill(
                                        // In order to have the ink splash appear above the image, you
                                        // must use Ink.image. This allows the image to be painted as part
                                        // of the Material and display ink effects above it. Using a
                                        // standard Image will obscure the ink splash.
                                        child: getImage(_userRepository
                                            .receiptRepository
                                            .getReceiptItems(
                                                _receiptStatusType)[index]
                                            .imagePath),
//                                        Ink.image(
////                                          image: getImage(receipt.imagePath),
//                                          fit: BoxFit.cover,
//                                          child: Container(),
//                                        ),
                                      ),
                                      Positioned(
                                        bottom: 16.0,
                                        left: 16.0,
                                        right: 16.0,
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            'title',
                                            style: titleStyle,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      16.0, 16.0, 16.0, 0.0),
                                  child: DefaultTextStyle(
                                    softWrap: false,
                                    overflow: TextOverflow.ellipsis,
                                    style: descriptionStyle,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        // three line description
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 8.0),
                                          child: Text(
                                            "description",
                                            style: descriptionStyle.copyWith(
                                                color: Colors.black54),
                                          ),
                                        ),
                                        Text(
                                            '${_userRepository.receiptRepository.getReceiptItems(_receiptStatusType)[index].companyName}'),
                                        Text(
                                            '${_userRepository.receiptRepository.getReceiptItems(_receiptStatusType)[index].receiptDatatime}'),
                                      ],
                                    ),
                                  ),
                                ),
                                ButtonTheme.bar(
                                  child: ButtonBar(
                                    alignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      FlatButton(
                                        child: Text('Review',
                                            semanticsLabel:
                                                'Review ${_userRepository.receiptRepository.getReceiptItems(_receiptStatusType)[index].id}'),
                                        textColor: Colors.amber.shade500,
                                        onPressed: () {
                                          print('pressed');
                                        },
                                      ),
                                      FlatButton(
                                        child: Text('Delete',
                                            semanticsLabel:
                                                'Delete ${_userRepository.receiptRepository.getReceiptItems(_receiptStatusType)[index].id}'),
                                        textColor: Colors.amber.shade500,
                                        onPressed: () {
                                          print('pressed');
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
//                            ListTile(
//                              leading: GestureDetector(
//                                child: Container(
//                                    width: 80,
//                                    child: getImage(_userRepository
//                                        .receiptRepository
//                                        .getReceiptItems(
//                                            _receiptStatusType)[index]
//                                        .imagePath)),
//                              ),
//                              title: AutoSizeText(
//                                'Uploaded ${DateFormat().add_yMd().format(_userRepository.receiptRepository.getReceiptItems(_receiptStatusType)[index].uploadDatetime.toLocal())}',
//                                style: TextStyle(fontSize: 18),
//                                minFontSize: 8,
//                                maxLines: 1,
//                                overflow: TextOverflow.ellipsis,
//                              ),
//                              subtitle: AutoSizeText(
//                                'Click to View or Remove the receipt',
//                                style: TextStyle(fontSize: 18),
//                                minFontSize: 8,
//                                maxLines: 2,
//                                overflow: TextOverflow.ellipsis,
//                              ),
//                            ),
                          )
//                            ListTile(
//                            title: Text('${_userRepository
//                                .receiptRepository.getReceiptItems(_receiptStatusType)[index].companyName}'),
//                          )
                              ;
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

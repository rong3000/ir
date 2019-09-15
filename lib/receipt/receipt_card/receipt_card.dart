import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intelligent_receipt/data_model/receipt_repository.dart';
import 'package:intl/intl.dart';

import '../../data_model/enums.dart';
import '../../data_model/webservice.dart';

class ReceiptCard extends StatelessWidget {
  final ReceiptListItem _receiptItem;

  const ReceiptCard({
    Key key,
    @required ReceiptListItem receiptItem,
  })  : assert(receiptItem != null),
        _receiptItem = receiptItem,
        super(key: key);

  CachedNetworkImage getImage(String imagePath) {
    return new CachedNetworkImage(
      imageUrl: Urls.GetImage + "/" + Uri.encodeComponent(imagePath),
      placeholder: (context, url) => new CircularProgressIndicator(),
      errorWidget: (context, url, error) => new Icon(Icons.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle companyNameStyle =
        theme.textTheme.body1.copyWith(color: Colors.black);
    final TextStyle dateStyle = theme.textTheme.body2;
    final TextStyle amountStyle = theme.textTheme.body1;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
//        flex: 1,
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.16,
//          width: MediaQuery.of(context).size.width * 0.1,
              child: getImage(_receiptItem
                  .imagePath),
            ),
          ),
          Expanded(child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                child: DefaultTextStyle(
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                  style: dateStyle,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 0.0),
                        child: Text(
                          "Receipt Date ${DateFormat().add_yMd().format(_receiptItem.receiptDatatime.toLocal())}",
                          style: dateStyle.copyWith(color: Colors.black54).apply(fontSizeFactor: 0.75),
                        ),
                      ),
                      Padding(
                        padding:
                        const EdgeInsets.only(top: 0.0, bottom: 0.0),
                        child: Text(
                          '${_receiptItem.companyName}',
                          style: companyNameStyle,
                        ),
                      ),
                      Text(
                        'Total ${_receiptItem.totalAmount}',
                        style: amountStyle,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),),
          Expanded(child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                child: DefaultTextStyle(
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                  style: dateStyle,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // three line description
                      Padding(
                        padding: const EdgeInsets.only(bottom: 0.0),
                        child: Text(
                          "Uploaded ${DateFormat().add_yMd().format(_receiptItem.uploadDatetime.toLocal())}",
                          style: dateStyle.copyWith(color: Colors.black54).apply(fontSizeFactor: 0.75),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 0.0, bottom: 0.0),
                        child: Text(
                          CategoryName.values[_receiptItem
                              .categoryId]
                              .toString()
                              .split('.')[1],
                          style: companyNameStyle,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ButtonTheme.bar(
                child: ButtonBar(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      width: 50,
                      height: 25,
                      child:
                      OutlineButton(
                          child: Text('Review',
                              style:
                              dateStyle.copyWith(color: Colors.blue).apply(fontSizeFactor: 0.75),
                              semanticsLabel:
                              'Review ${_receiptItem.id}'),
//                    textColor: Colors.blue.shade500,

                          onPressed: () {
                            print('pressed');
                          },
                          borderSide: BorderSide(color: Colors.blue),
//                      shape: StadiumBorder(),
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(4.0))),
                    ),
                    Container(
                      width: 50,
                      height: 25,
                      child:
                      OutlineButton(
                          child: Text('Delete',
                              style:
                              dateStyle.copyWith(color: Colors.blue).apply(fontSizeFactor: 0.8),
                              semanticsLabel:
                              'Delete ${_receiptItem.id}'),
                          textColor: Colors.blue.shade500,
                          onPressed: () {
                            print('pressed');
                          },
                          borderSide: BorderSide(color: Colors.blue),
//                      shape: StadiumBorder(),
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(4.0))),
                    ),
                  ],
                ),
              ),
            ],
          ),),
        ],
      ),
    );
  }
}

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intelligent_receipt/data_model/action_with_lable.dart';
import 'package:intelligent_receipt/data_model/category_repository.dart';
import 'package:intelligent_receipt/data_model/receipt_repository.dart';
import 'package:intelligent_receipt/data_model/webservice.dart';
import 'package:intelligent_receipt/user_repository.dart';
import 'package:intl/intl.dart';

class ReceiptCard extends StatefulWidget {
  const ReceiptCard({
    Key key,
    @required ReceiptListItem receiptItem,
    this.actions,
  })  : assert(receiptItem != null),
        _receiptItem = receiptItem,
        super(key: key);

  final ReceiptListItem _receiptItem;
  final List<ActionWithLabel> actions;

  @override
  _ReceiptCardState createState() => _ReceiptCardState();
}

class _ReceiptCardState extends State<ReceiptCard> {
  CategoryRepository _categoryRepository;

  Image getImage(String imagePath) {
    var imageUrl = Urls.GetImage + "/" + Uri.encodeComponent(imagePath);
    return Image.network(imageUrl);
  }

  @override
  void initState() {
    _categoryRepository =
        RepositoryProvider.of<UserRepository>(context).categoryRepository;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle companyNameStyle =
        theme.textTheme.body1.copyWith(color: Colors.black);
    final TextStyle dateStyle = theme.textTheme.body2;
    final TextStyle amountStyle = theme.textTheme.body1;

    Widget _actionButton(BuildContext context, ActionWithLabel action) {
      if (action.action != null) {
        return Container(
          height: 25,
          child: OutlineButton(
              child: Text(action.label,
                  style: dateStyle
                      .copyWith(color: Colors.blue)
                      .apply(fontSizeFactor: 0.75),
                  semanticsLabel: '${action.label} ${widget._receiptItem.id}'),
//                    textColor: Colors.blue.shade500,

              onPressed: () => action.action(widget._receiptItem.id),
              borderSide: BorderSide(color: Colors.blue),
//                      shape: StadiumBorder(),
              shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(4.0))),
        );
      } else
        return null;
    }

    BoxDecoration myBoxDecoration() {
      return BoxDecoration(
        border: Border.all(),
      );
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
//        mainAxisSize: MainAxisSize.max,
//        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.16,
//          width: MediaQuery.of(context).size.width * 0.1,
              child: getImage(widget._receiptItem.imagePath),
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 5.0),
                  child: DefaultTextStyle(
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    style: dateStyle,
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.16,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(bottom: 0.0),
                            child: Text(
                              "Receipt Date ${DateFormat().add_yMd().format(widget._receiptItem.receiptDatetime.toLocal())}",
                              style: dateStyle
                                  .copyWith(color: Colors.black54)
                                  .apply(fontSizeFactor: 0.75),
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 0.0, bottom: 0.0),
                            child: AutoSizeText(
                              (widget._receiptItem.companyName == null)?"Being processed at the server":'${widget._receiptItem.companyName}',
                              style: TextStyle(fontSize: 12),
                              minFontSize: 6,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
//                          Padding(
//                            padding:
//                                const EdgeInsets.only(top: 0.0, bottom: 0.0),
//                            child: Text(
//                              '${widget._receiptItem.companyName}',
//                              style: companyNameStyle,
//                            ),
//                          ),
                          Text(
                            'Total ${widget._receiptItem.totalAmount}',
                            style: amountStyle,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.16,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0.0, 5.0, 0.0, 0.0),
                      child: DefaultTextStyle(
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                        style: dateStyle,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            // three line description
                            Padding(
                              padding: const EdgeInsets.only(bottom: 0.0),
                              child: Text(
                                "Uploaded ${DateFormat().add_yMd().format(widget._receiptItem.uploadDatetime.toLocal())}",
                                style: dateStyle
                                    .copyWith(color: Colors.black54)
                                    .apply(fontSizeFactor: 0.75),
                              ),
                            ),
//                            Padding(
//                              padding:
//                                  const EdgeInsets.only(top: 0.0, bottom: 0.0),
//                              child: AutoSizeText(
//                                _categoryRepository.categories
//                                    .singleWhere(
//                                      (c) =>
//                                  c.id ==
//                                      widget._receiptItem.categoryId,
//                                  orElse: () =>
//                                  Category()..categoryName = "To be selected during review",
//                                )
//                                    ?.categoryName,
//                                style: TextStyle(fontSize: 12),
//                                minFontSize: 6,
//                                maxLines: 2,
//                                overflow: TextOverflow.ellipsis,
//                              ),
////                              Text(
////                                _categoryRepository.categories
////                                    .singleWhere(
////                                      (c) =>
////                                          c.id ==
////                                          widget._receiptItem.categoryId,
////                                      orElse: () =>
////                                          Category()..categoryName = "Being Processed at backend",
////                                    )
////                                    ?.categoryName,
////                                style: companyNameStyle,
////                              ),
//                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  ButtonTheme.bar(
                    minWidth: 56,
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ButtonBar(
                      mainAxisSize: MainAxisSize.min,
                      alignment: MainAxisAlignment.start,
                      children: widget.actions
                          .map<Widget>((ActionWithLabel action) =>
                              _actionButton(context, action))
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

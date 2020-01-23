import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intelligent_receipt/data_model/action_with_lable.dart';
import 'package:intelligent_receipt/data_model/category_repository.dart';
import 'package:intelligent_receipt/data_model/receipt_repository.dart';
import 'package:intelligent_receipt/data_model/webservice.dart';
import 'package:intelligent_receipt/translations/global_translations.dart';
import 'package:intelligent_receipt/user_repository.dart';
import 'package:intl/intl.dart';
import 'package:auto_size_text/auto_size_text.dart';
import '../../helper_widgets/zoomable_image.dart';
import 'package:intelligent_receipt/translations/global_translations.dart';
import 'package:intelligent_receipt/data_model/setting_repository.dart';

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
  ReceiptRepository _receiptRepository;
  Currency _defaultCurrency;
  Future<Image> _getImageFuture;
  String _imagePath;

  void _retrieveImage(String imagePath) {
    if (imagePath != _imagePath) {
      var imageUrl = Urls.GetImage + "/" + Uri.encodeComponent(imagePath);
      _getImageFuture = _receiptRepository.getNetworkImage(imageUrl);
      _imagePath = imagePath;
    }
  }

  @override
  void initState() {
    _categoryRepository =
        RepositoryProvider.of<UserRepository>(context).categoryRepository;
    _receiptRepository =
        RepositoryProvider.of<UserRepository>(context).receiptRepository;
    _defaultCurrency = RepositoryProvider.of<UserRepository>(context).settingRepository?.getDefaultCurrency();
    _retrieveImage(widget._receiptItem.imagePath);
    super.initState();
  }

  String _getTextShownInCategoryField(ReceiptListItem receipt) {
    String unknownText = allTranslations.text('app.receipt-card.unknown-category');
    String text = _categoryRepository.categories
        .singleWhere(
          (c) =>
              c.id ==
              widget._receiptItem.categoryId,
          orElse: () =>
              Category()..categoryName = unknownText,
        )
        ?.categoryName;

    if ((text == unknownText) && (receipt.statusId == ReceiptStatusType.Uploaded.index)) {
      if (receipt.decodeStatus == DecodeStatusType.Success.index) {
        text = allTranslations.text('app.receipt-card.receipt-processed-review');
      } else {
        text = allTranslations.text('app.receipt-card.receipt-in-process-review');
      }
    }
    return text;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle companyNameStyle =
        theme.textTheme.body1.copyWith(color: Colors.black);
    final TextStyle dateStyle = theme.textTheme.body2;
    final TextStyle amountStyle = theme.textTheme.body1;
    _retrieveImage(widget._receiptItem.imagePath);

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
              onPressed: () => action.action(widget._receiptItem.id),
              borderSide: BorderSide(color: Colors.blue),
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

    String _getCurrencyText(ReceiptListItem receiptItem) {
      String currencyText = receiptItem?.currencyCode;
      if (currencyText == null) {
        currencyText = _defaultCurrency?.code;
      }

      return (currencyText == null) ? "" : currencyText;
    }

    Future<void> _showFullImage(String imagePath) async {
      await showDialog<void>(
          context: context,
          builder: (BuildContext context) {
            return SimpleDialog(
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.8,
                  child:
                    !imagePath.isEmpty ?
                    ZoomableImage(new NetworkImage(Urls.GetImage + "/" + Uri.encodeComponent(imagePath)), backgroundColor: Colors.white) :
                    Center(child: Text(allTranslations.text('app.common.no-image-text'), textAlign: TextAlign.center)),
                ),
                Container(
                  height: 30,
                  child: FlatButton(
                    child: Text(allTranslations.text('words.close')),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                )
              ],
            );
          });
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: GestureDetector(
              onTap: () {
                _showFullImage(widget._receiptItem.imagePath);
              },
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.16,
                child: FutureBuilder<Image> (
                  future: _getImageFuture,
                  builder:(BuildContext context, AsyncSnapshot<Image> snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.none:
                        return new Text(allTranslations.text('app.common.loading-status'));
                      case ConnectionState.waiting:
                        return new Center(
                            child: new CircularProgressIndicator());
                      case ConnectionState.active:
                        return new Text('');
                      case ConnectionState.done:
                        return snapshot.data;
                    }
                  }
                ) //getImage(widget._receiptItem.imagePath),
              ),
            )
          ),
          Expanded(
            flex: 2,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                  child: DefaultTextStyle(
                    softWrap: false,
                    overflow: TextOverflow.ellipsis,
                    style: dateStyle,
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.16,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(bottom: 0.0),
                            child: Text(
                              '${allTranslations.text('app.receipt-card.receipt-date-prefix')} ${DateFormat().add_yMd().format(widget._receiptItem.receiptDatetime.toLocal())}',
                              style: dateStyle
                                  .copyWith(color: Colors.black54)
                                  .apply(fontSizeFactor: 0.75),
                            ),
                          ),
                          Padding(
                            padding:
                            const EdgeInsets.only(top: 0.0, bottom: 0.0),
                            child: Text(
                              '${widget._receiptItem.companyName}',
                              style: companyNameStyle,
                            ),
                          ),
                          Text(
                            '${allTranslations.text('app.receipt-card.total-amount-prefix')} ${_getCurrencyText(widget._receiptItem)} ${widget._receiptItem.totalAmount}',
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
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                      child: DefaultTextStyle(
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                        style: dateStyle,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            // three line description
                            Padding(
                              padding: const EdgeInsets.only(bottom: 0.0),
                              child: Text(
                                "${allTranslations.text('app.receipt-card.uploaded-prefix')} ${DateFormat().add_yMd().format(widget._receiptItem.uploadDatetime.toLocal())}",
                                style: dateStyle
                                    .copyWith(color: Colors.black54)
                                    .apply(fontSizeFactor: 0.75),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 0.0),
                              child: AutoSizeText(
                                _getTextShownInCategoryField(widget._receiptItem),
                                style: TextStyle(fontSize: 12)
                                      .copyWith(color: Colors.black54)
                                      .apply(fontSizeFactor: 0.85),
                                minFontSize: 6,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  ButtonBarTheme(
                    data: ButtonBarThemeData(
                      buttonMinWidth: 56,
                      buttonPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                    ),
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

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intelligent_receipt/data_model/currency.dart';
import 'package:intelligent_receipt/data_model/report.dart';
import 'package:intelligent_receipt/data_model/webservice.dart';
import 'package:intelligent_receipt/translations/global_translations.dart';
import 'package:intelligent_receipt/user_repository.dart';
import 'package:intl/intl.dart';
import 'package:intelligent_receipt/data_model/GeneralUtility.dart';

class ActionWithLable {
  Function(int) action;
  String lable;
}

class ReportCard extends StatefulWidget {
  final UserRepository _userRepository;
  final Currency _baseCurrency;

  const ReportCard({
    Key key,
    @required Report reportItem,
    @required UserRepository userRepository,
    @required Currency baseCurrency,
    this.actions,
  })  : assert(reportItem != null && userRepository != null),
        _userRepository = userRepository,
        _reportItem = reportItem,
        _baseCurrency = baseCurrency,
        super(key: key);

  final Report _reportItem;
  final List<ActionWithLable> actions;

  @override
  _ReportCardState createState() => _ReportCardState();
}

class _ReportCardState extends State<ReportCard> {
  UserRepository get _userRepository => widget._userRepository;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle companyNameStyle =
        theme.textTheme.body1.copyWith(color: Colors.black);
    final TextStyle dateStyle = theme.textTheme.body2;
    Currency currency = _userRepository.settingRepository.getCurrencyForCurrencyCode(widget._reportItem.currencyCode);
    if (currency == null) {
      currency = widget._baseCurrency;
    }

    Widget _actionButton(BuildContext context, ActionWithLable action) {
      if (action.action != null) {
        return Container(
          height: 25,
          child: OutlineButton(
              child: Text(action.lable,
                  style: dateStyle
                      .copyWith(color: Colors.blue)
                      .apply(fontSizeFactor: 0.75),
                  semanticsLabel: '${action.lable} ${widget._reportItem.id}'),
              onPressed: () => action.action(widget._reportItem.id),
              borderSide: BorderSide(color: Colors.blue),
              shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(4.0))),
        );
      } else
        return null;
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.14,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20.0, 8.0, 0.0, 0.0),
                    child: DefaultTextStyle(
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                      style: dateStyle,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6.0),
                            child: Text(
                              '${widget._reportItem.reportName}',
                              style: dateStyle
                                  .copyWith(color: Colors.black54)
                                  .apply(fontSizeFactor: 0.75),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 0.0, bottom: 6.0),
                            child: Text(
                              '${allTranslations.text('app.report-card.total-amount-prefix')}: ${currency != null ? currency.code: ''} ${currency != null ? currency.symbol: ''}${widget._reportItem.totalAmount.toStringAsFixed(2)}',
                              style: companyNameStyle.apply(fontSizeFactor: 1.2),

                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 0.0, bottom: 0.0),
                            child: AutoSizeText(
                              '${widget._reportItem.description}',
                              style: TextStyle(fontSize: 12)
                                  .copyWith(color: Colors.black54)
                                  .apply(fontSizeFactor: 0.85),
                              minFontSize: 6,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

          ),
          Expanded(
            flex: 2,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.14,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(0.0, 6.0, 0.0, 0.0),
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
                                "${allTranslations.text('app.report-card.created-date-prefix')} ${getDateFormatForYMD().format(widget._reportItem.createDateTime.toLocal())}",
                                style: dateStyle
                                    .copyWith(color: Colors.black54)
                                    .apply(fontSizeFactor: 0.75),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 0.0, bottom: 0.0),
                              child: Text(
                                '${widget._reportItem.getValidReceiptCount(_userRepository.receiptRepository)} ${allTranslations.text('app.report-card.expenses-suffix')}',
                                style: companyNameStyle.apply(fontSizeFactor: 1.2),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  ButtonTheme.bar(
                    minWidth: 56.0,
                    padding : const EdgeInsets.symmetric(horizontal: 6.0),
                    child: ButtonBar(
                      mainAxisSize: MainAxisSize.max,
                      alignment: MainAxisAlignment.center,
                      children:
                      widget.actions.map<Widget>(
                              (ActionWithLable action) =>
                              _actionButton(context, action)
                      ).toList(),
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

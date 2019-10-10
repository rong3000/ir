import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intelligent_receipt/data_model/report.dart';
import 'package:intelligent_receipt/report/report_list/report_list.dart';
import 'package:intl/intl.dart';

import '../../data_model/enums.dart';
import '../../data_model/webservice.dart';

class ReportCard extends StatefulWidget {
  const ReportCard({
    Key key,
    @required Report reportItem,
    this.actions,
  })  : assert(reportItem != null),
        _reportItem = reportItem,
        super(key: key);

  final Report _reportItem;
  final List<ActionWithLable> actions;

  @override
  _ReportCardState createState() => _ReportCardState();
}

class _ReportCardState extends State<ReportCard> {
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
//                    textColor: Colors.blue.shade500,

              onPressed: () => action.action(widget._reportItem.id),
              borderSide: BorderSide(color: Colors.blue),
//                      shape: StadiumBorder(),
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
//        mainAxisSize: MainAxisSize.max,
//        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 0.0),
                          child: Text(
                            "Update Time ${DateFormat().add_yMd().format(widget._reportItem.updateDateTime.toLocal())}",
                            style: dateStyle
                                .copyWith(color: Colors.black54)
                                .apply(fontSizeFactor: 0.75),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 0.0, bottom: 0.0),
                          child: Text(
                            '${widget._reportItem.reportName}',
                            style: companyNameStyle,
                          ),
                        ),
                        Text(
                          'Description ${widget._reportItem.description}',
                          style: amountStyle,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        // three line description
                        Padding(
                          padding: const EdgeInsets.only(bottom: 0.0),
                          child: Text(
                            "Created ${DateFormat().add_yMd().format(widget._reportItem.createDateTime.toLocal())}",
                            style: dateStyle
                                .copyWith(color: Colors.black54)
                                .apply(fontSizeFactor: 0.75),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                ButtonTheme.bar(
                  child: ButtonBar(
                    mainAxisSize: MainAxisSize.min,
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
        ],
      ),
    );
  }
}
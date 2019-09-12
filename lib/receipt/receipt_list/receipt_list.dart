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

class _InputDropdown extends StatelessWidget {
  const _InputDropdown({
    Key key,
    this.child,
    this.labelText,
    this.valueText,
    this.valueStyle,
    this.onPressed,
  }) : super(key: key);

  final String labelText;
  final String valueText;
  final TextStyle valueStyle;
  final VoidCallback onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: labelText,
        ),
        baseStyle: valueStyle,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(valueText, style: valueStyle),
            Icon(Icons.arrow_drop_down,
              color: Theme.of(context).brightness == Brightness.light ? Colors.grey.shade700 : Colors.white70,
            ),
          ],
        ),
      ),
    );
  }
}

class _DateTimePicker extends StatelessWidget {
  const _DateTimePicker({
    Key key,
    this.labelText,
    this.selectedDate,
    this.selectDate,
  }) : super(key: key);

  final String labelText;
  final DateTime selectedDate;
  final ValueChanged<DateTime> selectDate;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate)
      selectDate(picked);
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle valueStyle = Theme.of(context).textTheme.title;
    return _InputDropdown(
      labelText: labelText,
      valueText: DateFormat.yMMMd().format(selectedDate),
      valueStyle: valueStyle,
      onPressed: () { _selectDate(context); },
    );
  }
}

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
  DateTime _fromDate = DateTime.now().subtract(Duration(days: 180));
  DateTime _toDate = DateTime.now();

  UserRepository get _userRepository => widget._userRepository;
  get _receiptStatusType => widget._receiptStatusType;

  Future<Null> _selectFromDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: _fromDate,
        firstDate: DateTime(1900, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != _fromDate)
      setState(() {
        _fromDate = picked;
      });
  }

  Future<Null> _selectToDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: _toDate,
        firstDate: DateTime(1900, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != _toDate)
      setState(() {
        _toDate = picked;
      });
  }

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
                            child: Column(
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    GestureDetector(
                                      onTap: () {
                                        _selectFromDate(context);
                                      },
                                      child: Text("From ${DateFormat().add_yMd().format(_fromDate.toLocal())}"),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        _selectToDate(context);
                                      },
                                      child: Text("To ${DateFormat().add_yMd().format(_toDate.toLocal())}"),
                                    ),
                                  ],
                                ),

                                Row(
                                  children: <Widget>[
                                    RaisedButton(
                                      onPressed: () {
                                        setState(() {
                                          forceRefresh = false;
                                          ascending = !ascending;
                                          type = 0;
                                          print("${ascending} ${forceRefresh}");
                                        });
                                      },
                                      child: Text('Upload Time'),
                                    ),
                                    RaisedButton(
                                      onPressed: () {
                                        setState(() {
                                          forceRefresh = false;
                                          ascending = !ascending;
                                          type =1;
                                          print("${ascending} ${forceRefresh}");
                                        });
                                      },
                                      child: Text('Receipt Time'),
                                    ),
                                    RaisedButton(
                                      onPressed: () {
                                        setState(() {
                                          forceRefresh = false;
                                          ascending = !ascending;
                                          type = 2;
                                          print("${ascending} ${forceRefresh}");
                                        });
                                      },
                                      child: Text('Company Name'),
                                    ),
                                    RaisedButton(
                                      onPressed: () {
                                        setState(() {
                                          forceRefresh = false;
                                          ascending = !ascending;
                                          type = 3;
                                          print("${ascending} ${forceRefresh}");
                                        });
                                      },
                                      child: Text('Amount'),
                                    ),
                                    RaisedButton(
                                      onPressed: () {
                                        setState(() {
                                          forceRefresh = false;
                                          ascending = !ascending;
                                          type = 4;
                                          print("${ascending} ${forceRefresh}");
                                        });
                                      },
                                      child: Text('Category'),
                                    ),
                                  ],
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
                            type: type, ascending: ascending, fromDate: _fromDate, toDate: _toDate,)
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

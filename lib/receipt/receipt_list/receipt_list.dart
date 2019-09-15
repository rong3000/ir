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
            Icon(
              Icons.arrow_drop_down,
              color: Theme.of(context).brightness == Brightness.light
                  ? Colors.grey.shade700
                  : Colors.white70,
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
    if (picked != null && picked != selectedDate) selectDate(picked);
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle valueStyle = Theme.of(context).textTheme.title;
    return _InputDropdown(
      labelText: labelText,
      valueText: DateFormat.yMMMd().format(selectedDate),
      valueStyle: valueStyle,
      onPressed: () {
        _selectDate(context);
      },
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
  ReceiptSortType type;
  DateTime _fromDate = DateTime.now().subtract(Duration(days: 180));
  DateTime _toDate = DateTime.now();

  UserRepository get _userRepository => widget._userRepository;
  get _receiptStatusType => widget._receiptStatusType;

  String dropdown1Value = 'Free';

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
    type = ReceiptSortType.UploadTime;
    super.initState();
    if (_receiptStatusType == ReceiptStatusType.Uploaded) {
      _simpleValue = _simpleValue1;
    } else {
      _simpleValue = _simpleValue2;
    }
  }

  static const menuItems = <String>[
    'Upload Time',
    'Receipt Time',
    'Company Name',
    'Amount',
    'Category'
  ];

  final List<PopupMenuItem<String>> _popUpMenuItems = menuItems
      .map(
        (String value) => PopupMenuItem<String>(
          value: value,
          child: Text(value),
        ),
      )
      .toList();

  String _btn3SelectedVal = 'Receipt Time';

  final ReceiptSortType _simpleValue1 = ReceiptSortType.UploadTime;
  final ReceiptSortType _simpleValue2 = ReceiptSortType.ReceiptTime;
  final ReceiptSortType _simpleValue3 = ReceiptSortType.CompanyName;
  final ReceiptSortType _simpleValue4 = ReceiptSortType.Amount;
  final ReceiptSortType _simpleValue5 = ReceiptSortType.Category;
  ReceiptSortType _simpleValue;

  void showMenuSelection(ReceiptSortType value) {
//    if (<String>[_simpleValue1, _simpleValue2, _simpleValue3].contains(value))
    _simpleValue = value;
//    showInSnackBar('You selected: $value');
    print('You selected: $value');
    setState(() {
      forceRefresh = false;
      ascending = !ascending;
      type = value;
      print("${ascending} ${forceRefresh}");
    });
  }

  void showInSnackBar(String value) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(value),
    ));
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle titleStyle =
        theme.textTheme.headline.copyWith(color: Colors.white);
    final TextStyle descriptionStyle = theme.textTheme.subhead;

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Row(
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  _selectFromDate(context);
                },
                child: Text(
                  "From   ${DateFormat().add_yMd().format(_fromDate.toLocal())}",
                  style: DefaultTextStyle.of(context)
                      .style
                      .apply(fontSizeFactor: 0.8),
                ),
              ),
              GestureDetector(
                onTap: () {
                  _selectToDate(context);
                },
                child: Text(
                  "    To   ${DateFormat().add_yMd().format(_toDate.toLocal())}",
                  style: DefaultTextStyle.of(context)
                      .style
                      .apply(fontSizeFactor: 0.8),
                ),
              ),
              Expanded(
                child: PopupMenuButton<ReceiptSortType>(
                  padding: EdgeInsets.zero,
                  initialValue: _simpleValue,
                  onSelected: showMenuSelection,
                  child: ListTile(
                    title: Text(
                        'Sort By [${_simpleValue.toString().split('.')[1]}]'),
//                                  subtitle: Text(_simpleValue),
                  ),
                  itemBuilder: (BuildContext context) =>
                      <PopupMenuItem<ReceiptSortType>>[
                    PopupMenuItem<ReceiptSortType>(
                      value: _simpleValue1,
                      child: Text(_simpleValue1.toString().split('.')[1]),
                    ),
                    PopupMenuItem<ReceiptSortType>(
                      value: _simpleValue2,
                      child: Text(_simpleValue2.toString().split('.')[1]),
                    ),
                    PopupMenuItem<ReceiptSortType>(
                      value: _simpleValue3,
                      child: Text(_simpleValue3.toString().split('.')[1]),
                    ),
                    PopupMenuItem<ReceiptSortType>(
                      value: _simpleValue4,
                      child: Text(_simpleValue4.toString().split('.')[1]),
                    ),
                    PopupMenuItem<ReceiptSortType>(
                      value: _simpleValue5,
                      child: Text(_simpleValue5.toString().split('.')[1]),
                    ),
                  ],
                ), //                              ListTile(
//                                title: const Text('Simple dropdown:'),
//                                trailing: DropdownButton<String>(
//                                  value: dropdown1Value,
//                                  onChanged: (String newValue) {
//                                    setState(() {
//                                      dropdown1Value = newValue;
//                                    });
//                                  },
//                                  items: <String>['One', 'Two', 'Free', 'Four'].map<DropdownMenuItem<String>>((String value) {
//                                    return DropdownMenuItem<String>(
//                                      value: value,
//                                      child: Text(value),
//                                    );
//                                  }).toList(),
//                                ),
//                              ),
              ),
            ],
          ),
        ),
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
                      List<ReceiptListItem> sortedReceiptItems = _userRepository
                          .receiptRepository
                          .getSortedReceiptItems(_receiptStatusType, type,
                              ascending, _fromDate, _toDate);
                      return ListView.builder (
                        itemCount: sortedReceiptItems.length,
                        itemBuilder: (context, index) {
                          return ReceiptCard(receiptItem: sortedReceiptItems[index]);
                        }
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

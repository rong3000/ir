import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intelligent_receipt/data_model/action_with_lable.dart';
import 'package:intelligent_receipt/data_model/enums.dart';
import 'package:intelligent_receipt/data_model/receipt_repository.dart';
import 'package:intelligent_receipt/receipt/receipt_card/receipt_card.dart';
import 'package:intelligent_receipt/user_repository.dart';
import 'package:intl/intl.dart';
import 'package:synchronized/synchronized.dart';

class ReceiptList extends StatefulWidget {
  final UserRepository _userRepository;
  final ReceiptStatusType _receiptStatusType;
  final List<ReceiptListItem> _receiptItems;
  final List<ActionWithLable> _actions;

  ReceiptList({
    Key key,
    @required UserRepository userRepository,
    @required ReceiptStatusType receiptStatusType,
    @required List<ReceiptListItem> receiptItems,
    @required List<ActionWithLable> actions,
  })  : assert(userRepository != null),
        _userRepository = userRepository,
        _receiptStatusType = receiptStatusType,
        _receiptItems = receiptItems,
        _actions = actions,
        super(key: key) {}

  @override
  ReceiptListState createState() => ReceiptListState();
}

class ReceiptListState extends State<ReceiptList> {
  final List<String> items = List<String>.generate(10000, (i) => "Item $i");
  ScrollController _scrollController = ScrollController();
//  List<ReceiptListItem> receipts;
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
  ReceiptSortType sortingType;
  DateTime _fromDate = DateTime.now().subtract(Duration(days: 180));
  DateTime _toDate = DateTime.now();

  UserRepository get _userRepository => widget._userRepository;
  get _receiptStatusType => widget._receiptStatusType;
  Lock _lock = new Lock();

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
    super.initState();
    if (_receiptStatusType == ReceiptStatusType.Uploaded) {
      sortingType = ReceiptSortType.UploadTime;
    } else {
      sortingType = ReceiptSortType.ReceiptTime;
    }
    if (subMenuOverlayEntry != null) {
      subMenuOverlayEntry.remove();
      subMenuOverlayEntry = null;
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
      sortingType = value;
      print("${ascending} ${forceRefresh}");
    });
  }

  void showInSnackBar(String value) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(value),
    ));
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _onTapDown(TapDownDetails details, BuildContext context) {
    print('_onLongPressDragStart details: ${details.globalPosition}');
    RenderBox renderBox = context.findRenderObject();
    var offset = renderBox
//                            .localToGlobal(Offset(0.0, renderBox.size.height));
        .globalToLocal(details.globalPosition);
    print('${offset.dx} ${offset.dy} ');
    dx = details.globalPosition.dx;
    dy = details.globalPosition.dy;
    dx2 = offset.dx;
    dy2 = offset.dy;
  }

  void showSubMenuView(double t, double r) {
    subMenuOverlayEntry = new OverlayEntry(builder: (context) {
      return new Positioned(
          top: t,
          right: r,
          width: 160,
          height: 300,
          child: new SafeArea(
              child: new Material(
            child: new Container(
              child: new Column(
                children: <Widget>[
                  Expanded(
                    child: new ListTile(
//                          leading: Icon(
//                            Icons.edit,
////                            color: Colors.white,
//                          ),
                      title: GestureDetector(
                        onTap: () {
                          setState(() {
                            forceRefresh = false;
                            sortingType = ReceiptSortType.UploadTime;
                          });
                          subMenuOverlayEntry.remove();
                          subMenuOverlayEntry = null;
                        },
                        child: Text('Upload Time'),
                      ),
                    ),
                  ),
                  Expanded(
                    child: new ListTile(
//                          leading: Icon(
//                            Icons.edit,
////                            color: Colors.white,
//                          ),
                      title: GestureDetector(
                        onTap: () {
                          setState(() {
                            forceRefresh = false;
                            sortingType = ReceiptSortType.ReceiptTime;
                          });
                          subMenuOverlayEntry.remove();
                          subMenuOverlayEntry = null;
                        },
                        child: Text('Receipt Time'),
                      ),
                    ),
                  ),
                  Expanded(
                    child: new ListTile(
//                          leading: Icon(
//                            Icons.edit,
////                            color: Colors.white,
//                          ),
                      title: GestureDetector(
                        onTap: () {
                          setState(() {
                            forceRefresh = false;
                            sortingType = ReceiptSortType.CompanyName;
                          });
                          subMenuOverlayEntry.remove();
                          subMenuOverlayEntry = null;
                        },
                        child: Text('Company Name'),
                      ),
                    ),
                  ),
                  Expanded(
                    child: new ListTile(
//                          leading: Icon(
//                            Icons.edit,
////                            color: Colors.white,
//                          ),
                      title: GestureDetector(
                        onTap: () {
                          setState(() {
                            forceRefresh = false;
                            sortingType = ReceiptSortType.Amount;
                          });
                          subMenuOverlayEntry.remove();
                          subMenuOverlayEntry = null;
                        },
                        child: Text('Amount'),
                      ),
                    ),
                  ),
                  Expanded(
                    child: new ListTile(
//                          leading: Icon(
//                            Icons.edit,
////                            color: Colors.white,
//                          ),
                      title: GestureDetector(
                        onTap: () {
                          setState(() {
                            forceRefresh = false;
                            sortingType = ReceiptSortType.Category;
                          });
                          subMenuOverlayEntry.remove();
                          subMenuOverlayEntry = null;
                        },
                        child: Text('Category'),
                      ),
                    ),
                  ),
                  Expanded(
                    child: new Row(
                      children: <Widget>[
                        Checkbox(
                          onChanged: (bool value) {
                            setState(() => this.ascending = value);
                            subMenuOverlayEntry.remove();
                            subMenuOverlayEntry = null;
                          },
                          value: this.ascending,
                        ),
                        Text('Ascending'),
                      ],
                    ),
                  ),
//                      Expanded(
//                        child: new ListTile(
//                          leading: Icon(
//                            Icons.cancel,
////                              color: Colors.white
//                          ),
//                          title: GestureDetector(
//                            onTap: () {
//                              subMenuOverlayEntry.remove();
//                              subMenuOverlayEntry = null;
//                              return Future.value(false);
//                            },
//                            child: Text('Cancel'),
//                          ),
//                        ),
//                      ),
                ],
              ),
            ),
          )));
    });
    Overlay.of(context).insert(subMenuOverlayEntry);
  }

  List<ReceiptListItem> getSortedReceiptItems(
      List<ReceiptListItem> receipts,
      ReceiptStatusType receiptStatus,
      ReceiptSortType type,
      bool ascending,
      DateTime fromDate,
      DateTime toDate) {
    List<ReceiptListItem> selectedReceipts = [];
    _lock.synchronized(() {
      for (var i = 0; i < receipts.length; i++) {
        if (receipts[i].statusId == receiptStatus.index &&
            receipts[i].uploadDatetime.isAfter(fromDate) &&
            receipts[i]
                .uploadDatetime
                .isBefore(toDate.add(Duration(days: 1)))) {
          selectedReceipts.add(receipts[i]);
          if (ascending) {
            switch (type) {
              case ReceiptSortType.UploadTime:
                selectedReceipts.sort(
                    (a, b) => a.uploadDatetime.compareTo(b.uploadDatetime));
                break;
              case ReceiptSortType.ReceiptTime:
                selectedReceipts.sort(
                    (a, b) => a.receiptDatetime.compareTo(b.receiptDatetime));
                break;
              case ReceiptSortType.CompanyName:
                selectedReceipts
                    .sort((a, b) => a.companyName.compareTo(b.companyName));
                break;
              case ReceiptSortType.Amount:
                selectedReceipts
                    .sort((a, b) => a.totalAmount.compareTo(b.totalAmount));
                break;
              case ReceiptSortType.Category:
                selectedReceipts
                    .sort((a, b) => a.categoryId.compareTo(b.categoryId));
                break;
              default:
                break;
            }
          } else {
            switch (type) {
              case ReceiptSortType.UploadTime:
                selectedReceipts.sort(
                    (b, a) => a.uploadDatetime.compareTo(b.uploadDatetime));
                break;
              case ReceiptSortType.ReceiptTime:
                selectedReceipts.sort(
                    (b, a) => a.receiptDatetime.compareTo(b.receiptDatetime));
                break;
              case ReceiptSortType.CompanyName:
                selectedReceipts
                    .sort((b, a) => a.companyName.compareTo(b.companyName));
                break;
              case ReceiptSortType.Amount:
                selectedReceipts
                    .sort((b, a) => a.totalAmount.compareTo(b.totalAmount));
                break;
              case ReceiptSortType.Category:
                selectedReceipts
                    .sort((b, a) => a.categoryId.compareTo(b.categoryId));
                break;
              default:
                break;
            }
          }
        }
      }
    });
    return selectedReceipts;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle titleStyle =
        theme.textTheme.headline.copyWith(color: Colors.white);
    final TextStyle descriptionStyle = theme.textTheme.subhead;
    List<ReceiptListItem> sortedReceiptItems = getSortedReceiptItems(
        widget._receiptItems,
        _receiptStatusType,
        sortingType,
        ascending,
        _fromDate,
        _toDate);

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              GestureDetector(
                  onTapDown: (details) {
                    return _onTapDown(details, context);
                  },
                  onTap: () {
                    if (subMenuOverlayEntry != null) {
                      subMenuOverlayEntry.remove();
                      subMenuOverlayEntry = null;
                      return Future.value(false);
                    }
                    showSubMenuView(
                        dy2 + 120,
                        (dx2 < MediaQuery.of(context).size.width - 200)
                            ? (MediaQuery.of(context).size.width - 200 - dx2)
                            : (MediaQuery.of(context).size.width - dx2));
                  },
                  child: Row(
                    children: <Widget>[
                      Text(
                        "Sort By [${sortingType.toString().split('.')[1]}]",
                        style: DefaultTextStyle.of(context)
                            .style
                            .apply(fontSizeFactor: 0.8),
                      ),
                      Icon(
                        ascending ? Icons.arrow_upward : Icons.arrow_downward,
                        color: Colors.black,
                      ),
                      IconButton(
                        icon: Icon(
                          Theme.of(context).platform == TargetPlatform.iOS
                              ? Icons.more_horiz
                              : Icons.more_vert,
                        ),
                        tooltip: 'Show menu',
//                      onPressed: _bottomSheet == null ? _showConfigurationSheet : null,
                      ),
                    ],
                  )),
            ],
          ),
        ),
        body: ListView.builder(
            itemCount: sortedReceiptItems.length,
            itemBuilder: (context, index) {
              return ReceiptCard(
                receiptItem: sortedReceiptItems[index],
                actions: widget._actions,
              );
            }),
      ),
    );
  }
}

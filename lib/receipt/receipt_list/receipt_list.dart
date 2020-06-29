import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intelligent_receipt/data_model/action_with_lable.dart';
import 'package:intelligent_receipt/data_model/enums.dart';
import 'package:intelligent_receipt/data_model/receipt_repository.dart';
import 'package:intelligent_receipt/receipt/receipt_card/receipt_card.dart';
import 'package:intelligent_receipt/translations/global_translations.dart';
import 'package:intelligent_receipt/user_repository.dart';
import 'package:synchronized/synchronized.dart';
import 'package:intelligent_receipt/data_model/GeneralUtility.dart';

class ReceiptList extends StatefulWidget {
  final UserRepository _userRepository;
  final ReceiptStatusType _receiptStatusType;
  final List<ReceiptListItem> _receiptItems;
  final List<ActionWithLabel> _actions;
  final Future<void> Function() _forceGetReceiptsFromServer;
  DateTime _fromDate = null;
  DateTime _toDate = null;

  ReceiptList({
    Key key,
    @required UserRepository userRepository,
    @required ReceiptStatusType receiptStatusType,
    @required List<ReceiptListItem> receiptItems,
    @required List<ActionWithLabel> actions,
    Future<void> Function() forceGetReceiptsFromServer,
    DateTime fromDate : null,
    DateTime toDate : null,
  })  : assert(userRepository != null),
        _userRepository = userRepository,
        _receiptStatusType = receiptStatusType,
        _receiptItems = receiptItems,
        _actions = actions,
        _forceGetReceiptsFromServer = forceGetReceiptsFromServer,
        _fromDate = fromDate,
        _toDate = toDate,
        super(key: key);

  @override
  ReceiptListState createState() => ReceiptListState();
}

class ReceiptListState extends State<ReceiptList> {
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
    if (widget._fromDate != null) {
      _fromDate = widget._fromDate;
    }
    if (widget._toDate != null) {
      _toDate = widget._toDate;
    }
    if (_receiptStatusType == ReceiptStatusType.Uploaded) {
      sortingType = ReceiptSortType.UploadTime;
    } else {
      sortingType = ReceiptSortType.ReceiptTime;
    }
    if (subMenuOverlayEntry != null) {
      subMenuOverlayEntry.remove();
      subMenuOverlayEntry = null;
    }
    if (_receiptStatusType == ReceiptStatusType.Uploaded) {
      _sortByValue = _sortByUploadTime;
    } else {
      _sortByValue = _sortByReceiptTime;
    }
  }

  final ReceiptSortType _sortByUploadTime = ReceiptSortType.UploadTime;
  final ReceiptSortType _sortByReceiptTime = ReceiptSortType.ReceiptTime;
  final ReceiptSortType _sortByCompanyName = ReceiptSortType.CompanyName;
  final ReceiptSortType _sortByAmount = ReceiptSortType.Amount;
  final ReceiptSortType _sortByCategory = ReceiptSortType.Category;
  ReceiptSortType _sortByValue;

  void showMenuSelection(ReceiptSortType value) {
    _sortByValue = value;
    setState(() {
      forceRefresh = false;
      sortingType = value;
    });
  }

  String _getSortByValueStr(ReceiptSortType sortType) {
    if (sortType == _sortByUploadTime){
      return allTranslations.text('app.receipt-list.upload-time-menu-item');
    } else if (sortType == _sortByReceiptTime) {
      return allTranslations.text('app.receipt-list.receipt-time-menu-item');
    } else if (sortType == _sortByCompanyName) {
      return allTranslations.text('app.receipt-list.company-name-menu-item');
    } else if (sortType == _sortByAmount) {
      return allTranslations.text('app.receipt-list.amount-menu-item');
    } else if (sortType == _sortByCategory) {
      return allTranslations.text('app.receipt-list.category-menu-item');
    } else {
      return allTranslations.text('app.receipt-list.unknown-menu-item');
    }
  }

  void _showInSnackBar(String value, {IconData icon: Icons.error, color: Colors.red}) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(value), Icon(icon)],
      ),
      backgroundColor: color,
    ));
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
                      title: GestureDetector(
                        onTap: () {
                          setState(() {
                            forceRefresh = false;
                            sortingType = ReceiptSortType.UploadTime;
                          });
                          subMenuOverlayEntry.remove();
                          subMenuOverlayEntry = null;
                        },
                        child: Text(allTranslations.text('app.receipt-list.upload-time-menu-item')),
                      ),
                    ),
                  ),
                  Expanded(
                    child: new ListTile(
                      title: GestureDetector(
                        onTap: () {
                          setState(() {
                            forceRefresh = false;
                            sortingType = ReceiptSortType.ReceiptTime;
                          });
                          subMenuOverlayEntry.remove();
                          subMenuOverlayEntry = null;
                        },
                        child: Text(allTranslations.text('app.receipt-list.receipt-time-menu-item')),
                      ),
                    ),
                  ),
                  Expanded(
                    child: new ListTile(
                      title: GestureDetector(
                        onTap: () {
                          setState(() {
                            forceRefresh = false;
                            sortingType = ReceiptSortType.CompanyName;
                          });
                          subMenuOverlayEntry.remove();
                          subMenuOverlayEntry = null;
                        },
                        child: Text(allTranslations.text('app.receipt-list.company-name-menu-item')),
                      ),
                    ),
                  ),
                  Expanded(
                    child: new ListTile(
                      title: GestureDetector(
                        onTap: () {
                          setState(() {
                            forceRefresh = false;
                            sortingType = ReceiptSortType.Amount;
                          });
                          subMenuOverlayEntry.remove();
                          subMenuOverlayEntry = null;
                        },
                        child: Text(allTranslations.text('app.receipt-list.amount-menu-item')),
                      ),
                    ),
                  ),
                  Expanded(
                    child: new ListTile(
                      title: GestureDetector(
                        onTap: () {
                          setState(() {
                            forceRefresh = false;
                            sortingType = ReceiptSortType.Category;
                          });
                          subMenuOverlayEntry.remove();
                          subMenuOverlayEntry = null;
                        },
                        child: Text(allTranslations.text('app.receipt-list.category-menu-item')),
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
                        Text(allTranslations.text('app.receipt-list.ascending-menu-item')),
                      ],
                    ),
                  ),
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
    for (var i = 0; i < receipts.length; i++) {
      if (receiptStatus == ReceiptStatusType.Uploaded) {
        if (receipts[i].uploadDatetime.isAfter(fromDate) &&
            receipts[i].uploadDatetime.isBefore(
                toDate.add(Duration(days: 1)))) {
          selectedReceipts.add(receipts[i]);
        }
      } else {
        if (receipts[i].receiptDatetime.isAfter(fromDate) &&
            receipts[i].receiptDatetime.isBefore(
                toDate.add(Duration(days: 1)))) {
          selectedReceipts.add(receipts[i]);
        }
      }
    }

    switch (type) {
      case ReceiptSortType.UploadTime:
        selectedReceipts.sort(
            (a, b) => ascending ? a.uploadDatetime.compareTo(b.uploadDatetime) : b.uploadDatetime.compareTo(a.uploadDatetime));
        break;
      case ReceiptSortType.ReceiptTime:
        selectedReceipts.sort(
            (a, b) => ascending ? a.receiptDatetime.compareTo(b.receiptDatetime) : b.receiptDatetime.compareTo(a.receiptDatetime));
        break;
      case ReceiptSortType.CompanyName:
        selectedReceipts
            .sort((a, b) => ascending ? a.companyName.compareTo(b.companyName) : b.companyName.compareTo(a.companyName));
        break;
      case ReceiptSortType.Amount:
        selectedReceipts
            .sort((a, b) => ascending ? a.totalAmount.compareTo(b.totalAmount) : b.totalAmount.compareTo(a.totalAmount));
        break;
      case ReceiptSortType.Category:
        selectedReceipts
            .sort((a, b) => ascending ? a.categoryName.compareTo(b.categoryName) : b.categoryName.compareTo(a.categoryName));
        break;
      default:
        break;
    }

    return selectedReceipts;
  }

  Future<void> _refresh() {
    if (widget._forceGetReceiptsFromServer != null) {
      widget._forceGetReceiptsFromServer();
    }
  }

  @override
  Widget build(BuildContext context) {
    List<ReceiptListItem> sortedReceiptItems = getSortedReceiptItems(
        widget._receiptItems,
        _receiptStatusType,
        sortingType,
        ascending,
        _fromDate,
        _toDate);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(60.0, 60.0),
        child: Container(
          height: 60.0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          _selectFromDate(context);
                        },
                        child: Text(
                          "${getDateFormatForYMD().format(_fromDate.toLocal())}",
                          style: TextStyle(height: 1, fontSize: 12),
                        ),
                      ),
                      Icon(Icons.arrow_forward),
                      GestureDetector(
                        onTap: () {
                          _selectToDate(context);
                        },
                        child: Text(
                          "${getDateFormatForYMD().format(_toDate.toLocal())}",
                          style: TextStyle(height: 1, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  PopupMenuButton<ReceiptSortType>(
                    padding: EdgeInsets.zero,
                    initialValue: _sortByValue,
                    onSelected: showMenuSelection,
                    child:
                        Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                      Icon(Icons.sort),
                      Text(
                        "[${_getSortByValueStr(_sortByValue)}]",
                        style: TextStyle(height: 1, fontSize: 12),
                      ),
                    ]),
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuItem<ReceiptSortType>>[
                      PopupMenuItem<ReceiptSortType>(
                        value: _sortByUploadTime,
                        child: Text(allTranslations.text('app.receipt-list.upload-time-menu-item')),
                      ),
                      PopupMenuItem<ReceiptSortType>(
                        value: _sortByReceiptTime,
                        child: Text(allTranslations.text('app.receipt-list.receipt-time-menu-item')),
                      ),
                      PopupMenuItem<ReceiptSortType>(
                        value: _sortByCompanyName,
                        child: Text(allTranslations.text('app.receipt-list.company-name-menu-item')),
                      ),
                      PopupMenuItem<ReceiptSortType>(
                        value: _sortByAmount,
                        child: Text(allTranslations.text('app.receipt-list.amount-menu-item')),
                      ),
                      PopupMenuItem<ReceiptSortType>(
                        value: _sortByCategory,
                        child: Text(allTranslations.text('app.receipt-list.category-menu-item')),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(
                      ascending ? Icons.arrow_upward : Icons.arrow_downward,
                      color: Colors.black,
                    ),
                    tooltip: allTranslations.text('app.receipt-list.toggle-ascending-menu-item'),
                    onPressed: () {
                      setState(() {
                        ascending = !ascending;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: ListView.builder(
          itemCount: sortedReceiptItems.length,
          itemBuilder: (context, index) {
            return ReceiptCard(
              receiptItem: sortedReceiptItems[index],
              actions: widget._actions,
            );
          }),
      )
    );
  }
}

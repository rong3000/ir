import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intelligent_receipt/data_model/enums.dart';
import 'package:intelligent_receipt/data_model/receipt_repository.dart';
import 'package:intelligent_receipt/main_screen/bloc/bloc.dart';
import 'package:flutter/rendering.dart';
import 'package:intelligent_receipt/receipt/edit_receipt/edit_receipt.dart';
import 'package:intelligent_receipt/receipt/receipt_list/receipt_list.dart';
import 'package:intelligent_receipt/user_repository.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intelligent_receipt/data_model/webservice.dart';

class DataTableDemo extends StatefulWidget {
  final UserRepository _userRepository;
  final ReceiptStatusType _receiptStatusType;

  DataTableDemo({
    Key key,
    @required UserRepository userRepository,
    @required ReceiptStatusType receiptStatusType,
  })  : assert(userRepository != null),
        _userRepository = userRepository,
        _receiptStatusType = receiptStatusType,
        super(key: key) {}

  @override
  DataTableDemoState createState() => DataTableDemoState();
}

class DataTableDemoState extends State<DataTableDemo> {
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
  ScrollController _scrollController = ScrollController();

  getData() async {
    await _userRepository.receiptRepository
        .getReceiptsFromServer(forceRefresh: true);
    receiptItemCount = _userRepository.receiptRepository
        .getReceiptItemsCount(_receiptStatusType);
    end = (receiptItemCount < 5) ? receiptItemCount : 5;
    print('after count is ${receiptItemCount}');
  }

  @override
  void initState() {
    sort = false;
    selectedReceipts = [];
    forceRefresh = true;
    refreshCount = 0;
    loadMoreCount = 0;
//    getData();
    print('initState');
    print('*****************');
    super.initState();
  }

  CachedNetworkImage getImage(String imagePath) {
    return  new CachedNetworkImage(
      imageUrl: Urls.GetImage + "/" + Uri.encodeComponent(imagePath),
      placeholder: (context, url) => new CircularProgressIndicator(),
      errorWidget: (context, url, error) => new Icon(Icons.error),
    );
  }

  onSortColumn(int columnIndex, bool ascending) {
    if (columnIndex == 0) {
      if (ascending) {
        receipts.sort((a, b) => a.receiptDatatime.compareTo(b.receiptDatatime));
      } else {
        receipts.sort((a, b) => b.receiptDatatime.compareTo(a.receiptDatatime));
      }
    }
  }

  onSelectedRow(bool selected, Receipt receipt) async {
    setState(() {
      if (selected) {
        selectedReceipts.add(receipt);
      } else {
        selectedReceipts.remove(receipt);
      }
    });
  }

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

  SingleChildScrollView dataBody(List<ReceiptListItem> receipts) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        dataRowHeight: 120,
        sortAscending: sort,
        sortColumnIndex: 0,
        columns: [
          DataColumn(
              label: Text("Image"),
              numeric: false,
              tooltip: "Receipt image"
          ),
          DataColumn(
              label: Text("Date"),
              numeric: false,
              tooltip: "This is Date",
              onSort: (columnIndex, ascending) {
                setState(() {
                  sort = !sort;
                });
                onSortColumn(columnIndex, ascending);
              }),
          DataColumn(
            label: Text("Amount"),
            numeric: false,
            tooltip: "This is Amount",
          ),
          DataColumn(
            label: Text("Companies"),
            numeric: false,
            tooltip: "This is Companies",
          ),
          DataColumn(
            label: Text("Category"),
            numeric: false,
            tooltip: "This is Category",
          ),
        ],
        rows: receipts
            .map(
              (receipt) => DataRow(
//                onSelectChanged: (b) {
//                  print('clicked & ${b}');
//                },
//                  selected: selectedReceipts.contains(receipt),
//                  onSelectChanged: (b) {
//                    print("id ${receipt.id} is Onselect");
//                    onSelectedRow(b, receipt);
//                  },
                  cells: [
                    DataCell(
                      GestureDetector(
                        child: Container(
                            width: 80,
                            child: getImage(receipt.imagePath)
                        ),
                      ),
                    ),
                    DataCell(
                      GestureDetector(
                        onTapDown: (details) {
                          return _onTapDown(details, context);
                        },
                        onTap: () {
                          print("id ${receipt.id} is tapped");
                          if (subMenuOverlayEntry != null) {
                            subMenuOverlayEntry.remove();
                            subMenuOverlayEntry = null;
                            return Future.value(false);
                          }
//                        showSubMenuView(dx, dy);
                          showSubMenuView(
                              dy2 + 120,
                              (dx2 < MediaQuery.of(context).size.width - 200)
                                  ? (MediaQuery.of(context).size.width -
                                      200 -
                                      dx2)
                                  : (MediaQuery.of(context).size.width - dx2),
                              receipt.id);
                        },
                        child: Text(
                            "${DateFormat().add_yMd().format(receipt.receiptDatatime.toLocal())}"),
                      ),
                    ),
                    DataCell(
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
//                        showSubMenuView(dx, dy);
                          showSubMenuView(
                              dy2 + 120,
                              (dx2 < MediaQuery.of(context).size.width - 200)
                                  ? (MediaQuery.of(context).size.width -
                                  200 -
                                  dx2)
                                  : (MediaQuery.of(context).size.width - dx2),
                              receipt.id);
                        },
                        child: Text("${receipt.totalAmount}"),
                      ),
                    ),
                    DataCell(
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
//                        showSubMenuView(dx, dy);
                          showSubMenuView(
                              dy2 + 120,
                              (dx2 < MediaQuery.of(context).size.width - 200)
                                  ? (MediaQuery.of(context).size.width -
                                  200 -
                                  dx2)
                                  : (MediaQuery.of(context).size.width - dx2),
                              receipt.id);
                        },
                        child: Text(receipt.companyName.toString()),
                      ),
                    ),
                    DataCell(
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
//                        showSubMenuView(dx, dy);
                          showSubMenuView(
                              dy2 + 120,
                              (dx2 < MediaQuery.of(context).size.width - 200)
                                  ? (MediaQuery.of(context).size.width -
                                  200 -
                                  dx2)
                                  : (MediaQuery.of(context).size.width - dx2),
                              receipt.id);
                        },
                        child: Text(CategoryName.values[receipt.categoryId]
                            .toString()
                            .split('.')[1]),
                      ),
                    ),
                  ]),
            )
            .toList(),
      ),
    );
  }

  void showSubMenuView(double t, double r, int id) {
    subMenuOverlayEntry = new OverlayEntry(builder: (context) {
      return new Positioned(
          top: t,
          right: r,
          width: 160,
          height: 160,
          child: new SafeArea(
              child: new Material(
            child: new Container(
              child: new Column(
                children: <Widget>[
                  Expanded(
                    child: new ListTile(
                      leading: Icon(
                        Icons.edit,
//                            color: Colors.white,
                      ),
                      title: GestureDetector(
                        onTap: () {
                          print('View/Modify ${id}');
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) {
                              subMenuOverlayEntry.remove();
                              subMenuOverlayEntry = null;
//                              return EditReceiptPage();
                              return EditReceiptScreen(userRepository: _userRepository, receiptId: id);
                            }),
                          );
                        },
                        child: Text('View/Modify'),
                      ),
                    ),
                  ),
                  Expanded(
                    child: new ListTile(
                      leading: Icon(
                        Icons.delete,
//                              color: Colors.white
                      ),
                      title: GestureDetector(
                        onTap: () {
                          print('delete ${id}');
                        },
                        child: Text('Delete'),
                      ),
                    ),
                  ),
                  Expanded(
                    child: new ListTile(
                      leading: Icon(
                        Icons.cancel,
//                              color: Colors.white
                      ),
                      title: GestureDetector(
                        onTap: () {
                          subMenuOverlayEntry.remove();
                          subMenuOverlayEntry = null;
                          return Future.value(false);
                        },
                        child: Text('Cancel'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )));
    });
    Overlay.of(context).insert(subMenuOverlayEntry);
  }

  Future<Null> _handleRefresh() async {
    forceRefresh = true;
    await _userRepository.receiptRepository
        .getReceiptsFromServer(forceRefresh: forceRefresh);
    setState(() {
      print('before refresh counter is ${refreshCount}');
//      receiptItemCount = _userRepository.receiptRepository
//          .getReceiptItemsCount(_receiptStatusType);
//      end = (receiptItemCount < 5) ? receiptItemCount : 5;
      refreshCount++;
      loadMoreCount = 0;
      print(
          'after refresh counter is ${refreshCount}, ${forceRefresh} ${receiptItemCount} ${end}');
    });
  }

  loadMore() {
    setState(() {
      forceRefresh = false;
      print(
          'before loading more, counter is ${loadMoreCount}, start = ${start}, end = ${end}');
      loadMoreCount++;
      print(
          'after loading more, counter is ${loadMoreCount}, start = ${start}, end = ${end}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        verticalDirection: VerticalDirection.down,
        children: <Widget>[
          Expanded(
            child: Scrollbar(
              child: RefreshIndicator(
                onRefresh: _handleRefresh,
                child: NotificationListener<ScrollNotification>(
                  onNotification: (ScrollNotification scrollInfo) {
                    if (scrollInfo is ScrollEndNotification) {
                      if (scrollInfo.metrics.pixels ==
                          scrollInfo.metrics.maxScrollExtent) {
                        print(
                            "${_scrollController.position.pixels}, ${_scrollController.position.maxScrollExtent}, ");
                        print(
                            "${scrollInfo.metrics.pixels}, ${scrollInfo.metrics.maxScrollExtent}, ");
                        loadMore();
                      }
                    }
                  },
                  child: ListView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: <Widget>[
                      FutureBuilder<DataResult>(
                          future: _userRepository.receiptRepository
                              .getReceiptsFromServer(
                                  forceRefresh: forceRefresh),
                          builder: (BuildContext context,
                              AsyncSnapshot<DataResult> snapshot) {
                            switch (snapshot.connectionState) {
                              case ConnectionState.none:
                                return new Text('Loading...');
                              case ConnectionState.waiting:
                                return new Center(
                                    child: new CircularProgressIndicator());
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
                                    receiptItemCount = _userRepository
                                        .receiptRepository
                                        .getReceiptItemsCount(
                                            _receiptStatusType);
                                    if (loadMoreCount == 0) {
                                      end = (receiptItemCount < 5)
                                          ? receiptItemCount
                                          : 5;
                                      print(
                                          "receiptItemCount ${receiptItemCount} start ${start} end ${end}");
                                      return dataBody(_userRepository
                                          .receiptRepository
                                          .getReceiptItemsByRange(
                                              _receiptStatusType, start, end));
                                    } else {
                                      end = ((end + 5) < receiptItemCount)
                                          ? (end + 5)
                                          : receiptItemCount;
                                      print(
                                          "receiptItemCount ${receiptItemCount} start ${start} end ${end}");
                                      return dataBody(_userRepository
                                          .receiptRepository
                                          .getReceiptItemsByRange(
                                              _receiptStatusType, start, end));
                                    }
                                  } else {
                                    return Column(
                                      children: <Widget>[
                                        Text(
                                            'Failed retrieving data, error code is ${snapshot.data.messageCode}'),
                                        Text(
                                            'Error message is ${snapshot.data.message}'),
                                      ],
                                    );
                                  }
                                }
                                ;
                            }
                          }),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ReceiptsPage extends StatelessWidget {
  final UserRepository _userRepository;

  ReceiptsPage({Key key, @required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(key: key) {}

  @override
  Widget build(BuildContext context) {
    final _kTabPages = <Widget>[
      ReceiptsTabs(
          userRepository: _userRepository,
          receiptStatusType: ReceiptStatusType.Uploaded),
      ReceiptsTabs(
          userRepository: _userRepository,
          receiptStatusType: ReceiptStatusType.Decoded),
      ReceiptsTabs(
          userRepository: _userRepository,
          receiptStatusType: ReceiptStatusType.Reviewed),
    ];
    final _kTabs = <Tab>[
      Tab(text: 'Pending'),
      Tab(text: 'Unreviewed'),
      Tab(text: 'Reviewed'),
    ];
    return DefaultTabController(
      length: _kTabs.length,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.cyan,
          title: TabBar(
            tabs: _kTabs,
          ),
        ),
        body: TabBarView(
          children: _kTabPages,
        ),
      ),
    );
  }
}

class ReceiptsTabs extends StatefulWidget {
  final UserRepository _userRepository;
  final ReceiptStatusType _receiptStatusType;

  ReceiptsTabs({
    Key key,
    @required UserRepository userRepository,
    @required ReceiptStatusType receiptStatusType,
  })  : assert(userRepository != null),
        _userRepository = userRepository,
        _receiptStatusType = receiptStatusType,
        super(key: key) {}

  @override
  _ReceiptsTabsState createState() => _ReceiptsTabsState();
}

class _ReceiptsTabsState extends State<ReceiptsTabs> {
  HomeBloc _homeBloc;

  UserRepository get _userRepository => widget._userRepository;
  get _receiptStatusType => widget._receiptStatusType;

  @override
  void initState() {
    super.initState();
    _homeBloc = BlocProvider.of<HomeBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: BlocBuilder(
            bloc: _homeBloc,
            builder: (BuildContext context, HomeState state) {
              return Scaffold(
                body: OrientationBuilder(builder: (context, orientation) {
                  return Column(
                    children: <Widget>[
                      Flexible(
                        flex: 2,
                        fit: FlexFit.tight,
                        child:
                        FutureBuilder<DataResult>(
                            future: _userRepository.receiptRepository
                                .getReceiptsFromServer(),
                            builder: (BuildContext context,
                                AsyncSnapshot<DataResult> snapshot) {
                              switch (snapshot.connectionState) {
                                case ConnectionState.none:
                                  return new Text('Loading...');
                                case ConnectionState.waiting:
                                  return new Center(
                                      child: new CircularProgressIndicator());
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
                                      List<ReceiptListItem> ReceiptItems =
                                          _userRepository.receiptRepository
                                              .getReceiptItems(
                                              _receiptStatusType);
                                      return ReceiptList(
                                        userRepository: _userRepository,
                                        receiptStatusType: _receiptStatusType,
                                        receiptItems: ReceiptItems,
                                      );
                                    } else {
                                      return Column(
                                        children: <Widget>[
                                          Text(
                                              'Failed retrieving data, error code is ${snapshot.data.messageCode}'),
                                          Text(
                                              'Error message is ${snapshot.data.message}'),
                                        ],
                                      );
                                    }
                                  }
                                  ;
                              }
                            }),
                      ),
                    ],
                  );
                }),
              );
            }),
      ),
    );
  }
}

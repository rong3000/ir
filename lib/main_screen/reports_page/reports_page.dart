import 'package:flutter/material.dart';
import 'package:intelligent_receipt/data_model/enums.dart';
import 'package:intelligent_receipt/data_model/receipt_repository.dart';
import 'package:intl/intl.dart';

import '../../user_repository.dart';

class LoadMoreItem extends StatefulWidget {
  @override
  LoadMoreItemState createState() => new LoadMoreItemState();
}

class LoadMoreItemState extends State<LoadMoreItem> {
  @override
  Widget build(BuildContext context) {
    return new Container(
      child: new Center(
        child: new CircularProgressIndicator(),
      ),
    );
  }
}

class DataTableDemo extends StatefulWidget {
  final UserRepository _userRepository;
  final String _name;
  final ReceiptStatusType _receiptStatusType;

  DataTableDemo({
    Key key,
    @required UserRepository userRepository,
    @required String name,
    @required ReceiptStatusType receiptStatusType,
  })  : assert(userRepository != null),
        _userRepository = userRepository,
        _name = name,
        _receiptStatusType = receiptStatusType,
        super(key: key) {}

  @override
  DataTableDemoState createState() => DataTableDemoState();
}

class DataTableDemoState extends State<DataTableDemo> {
  List<ReceiptListItem> receipts;
  List<ReceiptListItem> selectedReceipts;
  bool sort;
  int start;
  int end;
  bool forceRefresh;
  int receiptItemCount;
  bool fromServer;

  UserRepository get _userRepository => widget._userRepository;
  get _name => widget._name;
  get _receiptStatusType => widget._receiptStatusType;
  ScrollController _scrollController = ScrollController();


  @override
  void initState() {
    sort = false;
    selectedReceipts = [];
    forceRefresh = true;
    start = 0;

    getData() async {
      await _userRepository.receiptRepository
          .getReceiptsFromServer(forceRefresh: true);
    }

    getData();

    receiptItemCount = _userRepository.receiptRepository
          .getReceiptItemsCount(_receiptStatusType);
    end = (receiptItemCount < 5) ? receiptItemCount : 5;
    print('count is ${receiptItemCount}');
    super.initState();
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

  SingleChildScrollView dataBody(List<ReceiptListItem> receipts) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        sortAscending: sort,
        sortColumnIndex: 0,
        columns: [
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
          DataColumn(
            label: Text("Actions"),
            numeric: false,
            tooltip: "This is Action",
          ),
        ],
        rows: receipts
            .map(
              (receipt) => DataRow(
//                  selected: selectedReceipts.contains(receipt),
//                  onSelectChanged: (b) {
//                    print("id ${receipt.id} is Onselect");
//                    onSelectedRow(b, receipt);
//                  },
                  cells: [
                    DataCell(
                      Text(
                          "${DateFormat().add_yMd().format(receipt.receiptDatatime.toLocal())}"),
                      showEditIcon: false,
                      onTap: () {
                        print('Selected Date cell of id ${receipt.id}');
                      },
                    ),
                    DataCell(
                      Text("${receipt.totalAmount}"),
                      showEditIcon: false,
                      onTap: () {
                        print('Selected Amount cell of id ${receipt.id}');
                      },
                    ),
                    DataCell(
                      Text(receipt.companyName.toString()),
                      showEditIcon: false,
                      onTap: () {
                        print('Selected Company cell of id ${receipt.id}');
                      },
                    ),
                    DataCell(
                      Text(CategoryName.values[receipt.categoryId]
                          .toString()
                          .split('.')[1]),
                      showEditIcon: false,
                      onTap: () {
                        print('Selected Category cell of id ${receipt.id}');
                      },
                    ),
                    DataCell(
                      Text('View & Modify ${receipt.id}'),
                      showEditIcon: false,
                      onTap: () {
                        print('Clicked Action Button of id ${receipt.id}');
                      },
                    ),
                  ]),
            )
            .toList(),
      ),
    );
  }

  Future<Null> _handleRefresh() async {
    forceRefresh = true;
    await _userRepository.receiptRepository
        .getReceiptsFromServer(forceRefresh: forceRefresh);
    setState(() {
      print('${forceRefresh}');
      receiptItemCount = _userRepository.receiptRepository
          .getReceiptItemsCount(_receiptStatusType);
      end = (receiptItemCount < 5) ? receiptItemCount : 5;
      print('${forceRefresh} ${receiptItemCount} ${end}');
    });
  }

  loadMore() {
//    receiptItemCount = _userRepository.receiptRepository.getReceiptItemsCount(_receiptStatusType);
//    print("count = ${receiptItemCount}");
    setState(() {
      forceRefresh = false;
      print('before loading data, start = ${start}, end = ${end}');
      end = ((end + 5) < receiptItemCount) ? (end + 5) : receiptItemCount;
      print('after loading data, start = ${start}, end = ${end}');
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
//                    if (scrollInfo.metrics.pixels ==
//                        scrollInfo.metrics.maxScrollExtent)
//                    print("${_scrollController.position.pixels}, ${_scrollController.position.maxScrollExtent}, ");
//                    print("${scrollInfo.metrics.pixels}, ${scrollInfo.metrics.maxScrollExtent}, ");
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
//                  dataBody(),
                      FutureBuilder<bool>(
                          future: _userRepository.receiptRepository
                              .getReceiptsFromServer(
                                  forceRefresh: forceRefresh),
                          builder: (BuildContext context,
                              AsyncSnapshot<bool> snapshot) {
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
//                              return new Text(snapshot.data[0].companyName);
                                  return FutureBuilder<List<ReceiptListItem>>(
                                      future: _userRepository.receiptRepository
                                          .getReceiptItemsByRange(
                                              _receiptStatusType, start, end),
                                      builder: (BuildContext context,
                                          AsyncSnapshot<List<ReceiptListItem>>
                                              snapshot) {
                                        switch (snapshot.connectionState) {
                                          case ConnectionState.none:
                                            return new Text('Loading...');
                                          case ConnectionState.waiting:
                                            return new Center(
                                                child:
                                                    new CircularProgressIndicator());
                                          case ConnectionState.active:
                                            return new Text('');
                                          case ConnectionState.done:
                                            if (snapshot.hasError) {
                                              return new Text(
                                                '${snapshot.error}',
                                                style: TextStyle(
                                                    color: Colors.red),
                                              );
                                            } else {
//                              return new Text(snapshot.data[0].companyName);
                                              return dataBody(snapshot.data);
//                                              return dataBody(snapshot.data.getRange(0, 5).toList());
                                            }
                                        }
                                      });
                                }
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

class TabsExample extends StatelessWidget {
  final UserRepository _userRepository;

  TabsExample({Key key, @required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(key: key) {}

  @override
  Widget build(BuildContext context) {
    final _kTabPages = <Widget>[
      DataTableDemo(
          userRepository: _userRepository,
          name: 'a',
          receiptStatusType: ReceiptStatusType.Uploaded),
      DataTableDemo(
          userRepository: _userRepository,
          name: 'b',
          receiptStatusType: ReceiptStatusType.Decoded),
      DataTableDemo(
          userRepository: _userRepository,
          name: 'c',
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
          // If `TabController controller` is not provided, then a
          // DefaultTabController ancestor must be provided instead.
          // Another way is to use a self-defined controller, c.f. "Bottom tab
          // bar" example.
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

class ReportsPage extends StatefulWidget {
  final UserRepository _userRepository;

  ReportsPage({Key key, @required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(key: key) {}
  @override
  _ReportsPageState createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  UserRepository get _userRepository => widget._userRepository;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OrientationBuilder(builder: (context, orientation) {
        return Column(
          children: <Widget>[
            Flexible(
              flex: 2,
              fit: FlexFit.tight,
              child: TabsExample(userRepository: _userRepository),
            ),
            Flexible(
                fit: FlexFit.tight,
                child: Wrap(
                  children: <Widget>[
                    FractionallySizedBox(
                      widthFactor:
                          orientation == Orientation.portrait ? 1 : 0.33,
                      child: Container(
                        height: MediaQuery.of(context).size.height *
                            (orientation == Orientation.portrait ? 0.1 : 0.2),
                        child: Card(
                          child: ListTile(
                            leading: Icon(Icons.album),
                            title: Text('Intelligent Receipt'),
                            subtitle: Text(
                                'Invite your friends to join IR then receive more free automatically scans'),
                          ),
                        ),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor:
                          orientation == Orientation.portrait ? 1 : 0.33,
                      child: Container(
                        height: MediaQuery.of(context).size.height *
                            (orientation == Orientation.portrait ? 0.1 : 0.2),
                        child: Card(
                          child: ListTile(
                            leading: Icon(Icons.album),
                            title: Text('Intelligent Receipt'),
                            subtitle: Text('Get unlimited automatically scans'),
                          ),
                        ),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor:
                          orientation == Orientation.portrait ? 1 : 0.33,
                      child: Container(
                        height: MediaQuery.of(context).size.height *
                            (orientation == Orientation.portrait ? 0.1 : 0.2),
                        child: Card(
                          child: ListTile(
                            leading: Icon(Icons.album),
                            title: Text('Intelligent Receipt'),
                            subtitle: Text(
                                'We have sent you an email, please click confirm'),
                          ),
                        ),
                      ),
                    ),
                  ],
                )),
          ],
        );
      }),
    );
  }
}

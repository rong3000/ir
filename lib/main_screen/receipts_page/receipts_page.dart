import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intelligent_receipt/data_model/action_with_lable.dart';
import 'package:intelligent_receipt/data_model/enums.dart';
import 'package:intelligent_receipt/data_model/receipt_repository.dart';
import 'package:intelligent_receipt/main_screen/bloc/bloc.dart';
import 'package:flutter/rendering.dart';
import 'package:intelligent_receipt/main_screen/settings_page/plan_screen/plan_screen.dart';
import 'package:intelligent_receipt/receipt/add_edit_reciept_manual/add_edit_receipt_manual.dart';
import 'package:intelligent_receipt/receipt/edit_receipt/edit_receipt.dart';
import 'package:intelligent_receipt/receipt/receipt_list/receipt_list.dart';
import 'package:intelligent_receipt/receipt/upload_receipt_image/update_receipt_image.dart';
import 'package:intelligent_receipt/user_repository.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intelligent_receipt/data_model/webservice.dart';

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
  DataResult dataResult;
//  List<ReceiptListItem> ReceiptItems = [];

  Future<void> getDataResultFromServer() async {
//    dataResult = await _userRepository.receiptRepository.getReceiptsFromServer(forceRefresh: true);
    dataResult = await _userRepository.receiptRepository
        .getReceiptsFromServer(forceRefresh: true);
    setState(() {});
  }

  void reviewAction(int id) {
    print('Review ${id}');
  }

  Future<void> deleteAndSetState(List<int> receiptIds) async {
    await _userRepository.receiptRepository.deleteReceipts(receiptIds);
    setState(() {});
  }

  void deleteAction(int id) {
    List<int> receiptIds = [];
    receiptIds.add(id);
    deleteAndSetState(receiptIds);
  }

  void addAction(int id) {
    print('Add ${id}');
  }

  void removeAction(int id) {
    print('Add ${id}');
  }

  @override
  void initState() {
//    getDataResultFromServer();
    super.initState();
    _homeBloc = BlocProvider.of<HomeBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          FloatingActionButton(
            heroTag: "btn1",
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) {
                  return AddEditReiptForm();
                }),
              );
            },
            backgroundColor: Colors.redAccent,
            child: const Icon(
              Icons.add,
              semanticLabel: 'Add Expense Manually',
            ),
          ),
          FloatingActionButton(
            heroTag: "btn2",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => UploadReceiptImage(
                        userRepository: _userRepository,
                        imageSource: IRImageSource.Gallary)),
              );
            },
            backgroundColor: Colors.redAccent,
            child: const Icon(
              Icons.camera,
              semanticLabel: 'Snap Receipt',
            ),
          ),
        ],
      ),
      body: Center(
        child: BlocBuilder(
            bloc: _homeBloc,
            builder: (BuildContext context, HomeState state) {
              return
              FutureBuilder<DataResult>(
                  future: _userRepository.receiptRepository
                      .getReceiptsFromServer(forceRefresh: true),
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
                        {
                          {
                            List<ReceiptListItem> ReceiptItems = _userRepository.receiptRepository
                                .getReceiptItems(_receiptStatusType);
                            List<ActionWithLable> actions = [];
                            ActionWithLable r = new ActionWithLable();
                            r.action = reviewAction;
                            r.lable = 'Review';
                            ActionWithLable d = new ActionWithLable();
                            d.action = deleteAction;
                            d.lable = 'Delete';
                            actions.add(r);
                            actions.add(d);
                            return Scaffold(
                              body: OrientationBuilder(builder: (context, orientation) {
                                return Column(
                                  children: <Widget>[
                                    Flexible(
                                        flex: 2,
                                        fit: FlexFit.tight,
                                        child: ReceiptList(
                                          userRepository: _userRepository,
                                          receiptStatusType: _receiptStatusType,
                                          receiptItems: ReceiptItems,
                                          actions: actions,
                                        )),
                                  ],
                                );
                              }),
                            );
                          }
                        }
                    }
                  });
//              if (dataResult == null || dataResult.success == false) {
//                return Text('Loading...');
//              } else

            }),
      ),
    );
  }
}

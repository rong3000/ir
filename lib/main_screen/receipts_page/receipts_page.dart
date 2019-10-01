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

  Future<void> getDataResultFromServer() async {
    print('4');
//    dataResult = await _userRepository.receiptRepository.getReceiptsFromServer(forceRefresh: true);
    await _userRepository.receiptRepository
        .getReceiptsFromServer(forceRefresh: true);
    print('5');
    setState(() {
      print('6');
    });
    print('7');
  }

  @override
  void initState() {
    getDataResultFromServer();
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
              if (!_userRepository.receiptRepository.receipts.isNotEmpty) {
                print('8');
                return Text('Loading...');
              } else {
                List<ReceiptListItem> ReceiptItems = _userRepository
                    .receiptRepository
                    .getReceiptItems(_receiptStatusType);
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
                            )),
                      ],
                    );
                  }),
                );
              }
            }),
      ),
    );
  }
}

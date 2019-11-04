import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/rendering.dart';
import 'package:intelligent_receipt/data_model/enums.dart';
import 'package:intelligent_receipt/data_model/receipt.dart';
import 'package:intelligent_receipt/main_screen/bloc/home_bloc.dart';
import 'package:intelligent_receipt/main_screen/bloc/home_state.dart';
import 'package:intelligent_receipt/report/add_report_screen/add_report_screen.dart';
import 'package:intelligent_receipt/report/report_list/report_list.dart';
import 'package:intelligent_receipt/user_repository.dart';

class ReportsPage_ extends StatelessWidget {
  final UserRepository _userRepository;

  ReportsPage_({Key key, @required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(key: key) {}

  @override
  Widget build(BuildContext context) {
    final _kTabPages = <Widget>[
      ReportsPage(
//          ReportsTabs(
          userRepository: _userRepository,
          reportStatusType: ReportStatusType.Active),
      ReportsPage(
//          ReportsTabs(
          userRepository: _userRepository,
          reportStatusType: ReportStatusType.Submitted),
    ];
    final _kTabs = <Tab>[
      Tab(text: 'Active Reports'),
      Tab(text: 'Submitted Reports'),
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

//class ReportsTabs extends StatefulWidget {
class ReportsPage extends StatefulWidget {
  final UserRepository _userRepository;
  final ReportStatusType _reportStatusType;

//  ReportsTabs({
  ReportsPage({
    Key key,
    @required UserRepository userRepository,
    @required ReportStatusType reportStatusType,
  })  : assert(userRepository != null),
        _userRepository = userRepository,
        _reportStatusType = reportStatusType,
        super(key: key) {}

  @override
//  _ReportsTabsState createState() => _ReportsTabsState();
  _ReportsPageState createState() => _ReportsPageState();
}

//class _ReportsTabsState extends State<ReportsTabs> {
class _ReportsPageState extends State<ReportsPage> {
//  HomeBloc _homeBloc;

  UserRepository get _userRepository => widget._userRepository;
  get _reportStatusType => widget._reportStatusType;

  void _showMessage() {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: const Text('You tapped the floating action button.'),
          actions: <Widget>[
            FlatButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
//    _homeBloc = BlocProvider.of<HomeBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _reportStatusType == ReportStatusType.Submitted? AppBar(
        title: Text('Archived Reports'),
      ):null,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
        _userRepository.receiptRepository.resetCachedReceiptItems(_userRepository.reportRepository);
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) {
              return AddReportScreen(
                  userRepository: _userRepository,
                  title: 'New Receipt Group',
              );
            }),
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(
          Icons.add,
          semanticLabel: 'Add',
        ),
      ),
      body: Center(
        child: Scaffold(
          body: OrientationBuilder(builder: (context, orientation) {
            return Column(
              children: <Widget>[
                Flexible(
                  flex: 2,
                  fit: FlexFit.tight,
                  child:
//                        DataTableDemo(
                  ReportList(
                      userRepository: _userRepository,
                      reportStatusType: _reportStatusType),
//                          Scaffold(
//                            appBar: AppBar(title: SortingBar(userRepository: _userRepository),),
//                            body: ReportList(
//                                userRepository: _userRepository,
//                                reportStatusType: _reportStatusType),
//                          )
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intelligent_receipt/data_model/currency.dart';
import 'package:intelligent_receipt/data_model/enums.dart';
import 'package:intelligent_receipt/report/add_edit_report/add_edit_report.dart';
import 'package:intelligent_receipt/report/report_list/report_list.dart';
import 'package:intelligent_receipt/translations/global_translations.dart';
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
      Tab(text: allTranslations.text('app.reports-page.active-groups-tab-label')),
      Tab(text: allTranslations.text('app.reports-page.submitted-groups-tab-label')),
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
  ReportList _reportList;

//  ReportsTabs({
  ReportsPage({
    Key key,
    @required UserRepository userRepository,
    @required ReportStatusType reportStatusType,
  })  : assert(userRepository != null),
        _userRepository = userRepository,
        _reportStatusType = reportStatusType,
        super(key: key) {
    _reportList = ReportList(userRepository: _userRepository, reportStatusType: _reportStatusType);
  }

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
              child: Text(allTranslations.text('words.ok')),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _reportStatusType == ReportStatusType.Submitted? AppBar(
        title: Text(allTranslations.text('app.reports-page.archived-groups-page-label')),
      ):null,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) {
              return AddEditReport(
                  userRepository: _userRepository,
                  title: allTranslations.text('app.add-reports-page.title'),
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
          body: Column(
              children: <Widget>[
                Flexible(
                  flex: 2,
                  fit: FlexFit.tight,
                  child: widget._reportList
                ),
              ],
            )
        ),
      ),
    );
  }
}

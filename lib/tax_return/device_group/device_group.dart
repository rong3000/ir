import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intelligent_receipt/data_model/currency.dart';
import 'package:intelligent_receipt/data_model/enums.dart';
import 'package:intelligent_receipt/data_model/report.dart';
import 'package:intelligent_receipt/report/add_edit_report/add_edit_report.dart';
import 'package:intelligent_receipt/report/add_edit_report/add_edit_report2.dart';
import 'package:intelligent_receipt/report/report_card/report_card.dart';
import 'package:intelligent_receipt/user_repository.dart';
import 'package:intl/intl.dart';
import 'package:intelligent_receipt/data_model/http_statuscode.dart';
import 'package:intelligent_receipt/data_model/exception_handlers/unsupported_version.dart';
import 'package:intelligent_receipt/translations/global_translations.dart';
import 'package:intelligent_receipt/data_model/GeneralUtility.dart';

import '../../data_model/webservice.dart';

class DeviceGroup extends StatefulWidget {
  final UserRepository _userRepository;
  final FiscYear _fiscYear;

  DeviceGroup({
    Key key,
    @required UserRepository userRepository,
    @required FiscYear fiscYear,
  })  : assert(userRepository != null),
        _userRepository = userRepository,
        _fiscYear = fiscYear,
        super(key: key) {}

  @override
  DeviceGroupState createState() => DeviceGroupState();
}

class DeviceGroupState extends State<DeviceGroup> {
  final List<String> items = List<String>.generate(10000, (i) => "Item $i");
  ScrollController _scrollController = ScrollController();
  List<Report> reports;
  List<Report> selectedReports;
  bool sort;
  int start = 0;
  int end;
  int reportItemCount;
  bool fromServer;
  int refreshCount = 0;
  int loadMoreCount = 0;
  OverlayEntry subMenuOverlayEntry;
  GlobalKey anchorKey = GlobalKey();
  bool ascending;
  ReportSortType sortingType;
  DateTime _fromDate = DateTime.now().subtract(Duration(days: 180));
  DateTime _toDate = DateTime.now();
  Future<DataResult> _getReportsFuture = null;
  Currency _baseCurrency;

  UserRepository get _userRepository => widget._userRepository;
  get _fiscYear => widget._fiscYear;

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

  Future<void> _getReportsFromServer({forceRefresh : false}) {
    _getReportsFuture = _userRepository.taxReturnRepository.getTaxReturns();
  }

  Future<void> _forceGetReportsFromServer() async {
    _getReportsFuture = _userRepository.taxReturnRepository.getTaxReturns();
//    _getReportsFuture = _userRepository.reportRepository.getReportsFromServer(forceRefresh: true);
    setState(() {});
  }

  Future<void> _getBaseCurrency() async {
    _baseCurrency = _userRepository.settingRepository.getDefaultCurrency();
    if (_baseCurrency == null) {
      await _userRepository.settingRepository.getSettingsFromServer();
      _baseCurrency = _userRepository.settingRepository.getDefaultCurrency();
      setState(() {
      });
    }
  }

  @override
  void initState() {
    _getReportsFromServer();
    _getBaseCurrency();
    ascending = false;
    super.initState();
    if (_fiscYear == FiscYear.Current) {
      sortingType = ReportSortType.CreateTime;
    } else {
      sortingType = ReportSortType.UpdateTime;
    }
    if (subMenuOverlayEntry != null) {
      subMenuOverlayEntry.remove();
      subMenuOverlayEntry = null;
    }
    if (_fiscYear == FiscYear.Current) {
      _sortByValue = _sortByCreateTime;
    } else {
      _sortByValue = _sortByUpdateTime;
    }
  }

  static const menuItems = <String>[
    'Upload Time',
    'Group Time',
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

  String _btn3SelectedVal = 'Group Time';

  final ReportSortType _sortByCreateTime = ReportSortType.CreateTime;
  final ReportSortType _sortByUpdateTime = ReportSortType.UpdateTime;
  final ReportSortType _sortByGroupName = ReportSortType.GroupName;
  ReportSortType _sortByValue;

  void showMenuSelection(ReportSortType value) {
//    if (<String>[_sortByCreateTime, _sortByUpdateTime, _sortByGroupName].contains(value))
    _sortByValue = value;
//    showInSnackBar('You selected: $value');
    print('You selected: $value');
    setState(() {
      sortingType = value;
    });
  }

  String _getSortByValueStr(ReportSortType sortType) {
    if (sortType == _sortByCreateTime){
      return allTranslations.text('app.reports-list.create-time');
    } else if (sortType == _sortByUpdateTime) {
      return allTranslations.text('app.reports-list.update-time');
    } else if (sortType == _sortByGroupName) {
      return allTranslations.text('app.reports-list.group-name');
    } else {
      return allTranslations.text('app.reports-list.unknown');
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

  void reviewAction(int id) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) {
        return AddEditReport2(
          userRepository: _userRepository,
          title: 'Edit Receipt Group',
          reportId: id,
        );
      }),
    );
    print('Review ${id}');
  }

  Future<void> deleteAndSetState(int reportId) async {
    DataResult result = await _userRepository.reportRepository.deleteReport(reportId);
    if (result.success) {
      setState(() => {});
    } else {
      _showInSnackBar("${allTranslations.text("app.reports-list.failed-delete-group-message")} \n${result.message}");
    }
  }

  void deleteAction(int id) {
    deleteAndSetState(id);
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
                            sortingType = ReportSortType.CreateTime;
                          });
                          subMenuOverlayEntry.remove();
                          subMenuOverlayEntry = null;
                        },
                        child: Text(allTranslations.text('app.reports-list.create-time')),
                      ),
                    ),
                  ),
                  Expanded(
                    child: new ListTile(
                      title: GestureDetector(
                        onTap: () {
                          setState(() {
                            sortingType = ReportSortType.UpdateTime;
                          });
                          subMenuOverlayEntry.remove();
                          subMenuOverlayEntry = null;
                        },
                        child: Text(allTranslations.text('app.reports-list.update-time')),
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
                            sortingType = ReportSortType.GroupName;
                          });
                          subMenuOverlayEntry.remove();
                          subMenuOverlayEntry = null;
                        },
                        child: Text(allTranslations.text('app.reports-list.group-name')),
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
                        Text(allTranslations.text('app.reports-list.ascending')),
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

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle titleStyle =
        theme.textTheme.headline.copyWith(color: Colors.white);
    final TextStyle descriptionStyle = theme.textTheme.subhead;

    return Scaffold(
//        appBar: PreferredSize(
//          preferredSize: Size(60.0, 60.0),
//          child: Container(
//            height: 60.0,
//            child: Column(
//              mainAxisAlignment: MainAxisAlignment.center,
//              children: <Widget>[
//                Row(
//                  mainAxisSize: MainAxisSize.max,
//                  mainAxisAlignment: MainAxisAlignment.spaceAround,
//                  children: <Widget>[
//                    Row(
//                      mainAxisSize: MainAxisSize.max,
//                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                      children: <Widget>[
//                        GestureDetector(
//                          onTap: () {
//                            _selectFromDate(context);
//                          },
//                          child: Text(
//                            "${getDateFormatForYMD().format(_fromDate.toLocal())}",
//                            style: TextStyle(height: 1, fontSize: 12),
//                          ),
//                        ),
//                        Icon(Icons.arrow_forward),
//                        GestureDetector(
//                          onTap: () {
//                            _selectToDate(context);
//                          },
//                          child: Text(
//                            "${getDateFormatForYMD().format(_toDate.toLocal())}",
//                            style: TextStyle(height: 1, fontSize: 12),
//                          ),
//                        ),
//                      ],
//                    ),
//                    PopupMenuButton<ReportSortType>(
//                      padding: EdgeInsets.zero,
//                      initialValue: _sortByValue,
//                      onSelected: showMenuSelection,
//                      child: Row(
//                          mainAxisSize: MainAxisSize.min,
//                          children: <Widget>[
//                            Icon(Icons.sort),
//                            Text(
//                              "[${_getSortByValueStr(_sortByValue)}]",
//                              style: TextStyle(height: 1, fontSize: 12),
//                            ),
//                          ]),
//                      itemBuilder: (BuildContext context) =>
//                          <PopupMenuItem<ReportSortType>>[
//                        PopupMenuItem<ReportSortType>(
//                          value: _sortByCreateTime,
//                          child: Text(allTranslations.text('app.reports-list.create-time')),
//                        ),
//                        PopupMenuItem<ReportSortType>(
//                          value: _sortByUpdateTime,
//                          child: Text(allTranslations.text('app.reports-list.update-time')),
//                        ),
//                        PopupMenuItem<ReportSortType>(
//                          value: _sortByGroupName,
//                          child: Text(allTranslations.text('app.reports-list.group-name')),
//                        ),
//                      ],
//                    ),
//                    IconButton(
//                      icon: Icon(
//                        ascending ? Icons.arrow_upward : Icons.arrow_downward,
//                        color: Colors.black,
//                      ),
//                      tooltip: 'Toggle ascending',
//                      onPressed: () {
//                        setState(() {
//                          ascending = !ascending;
//                        });
//                      },
//                    ),
//                  ],
//                ),
//              ],
//            ),
//          ),
//        ),
        body: RefreshIndicator(
          onRefresh: _forceGetReportsFromServer,
          child: FutureBuilder<DataResult>(
              future: _getReportsFuture,
              builder:
                  (BuildContext context, AsyncSnapshot<DataResult> snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                    return new Text(allTranslations.text('app.reports-list.loading'));
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
                        List<Report> sortedReportItems =
                        _userRepository.taxReturnRepository.taxReturns[0].receiptGroups;
//                        _userRepository.reportRepository.getSortedReportItems(
//                            ReportStatusType.Active,
//                            sortingType,
//                            ascending,
//                            _fromDate,
//                            _toDate);
                        List<ActionWithLable> actions = [];
                        ActionWithLable r = new ActionWithLable();
                        r.action = reviewAction;
                        r.lable = allTranslations.text('app.reports-list.review');
                        ActionWithLable d = new ActionWithLable();
                        d.action = deleteAction;
                        d.lable = allTranslations.text('app.reports-list.delete');
                        actions.add(r);
                        actions.add(d);
                        return ListView.builder(
                            itemCount: sortedReportItems.length,
                            controller: _scrollController,
                            physics: AlwaysScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              return ReportCard(
                                reportItem: sortedReportItems[index],
                                userRepository: _userRepository,
                                actions: actions,
                                baseCurrency: _baseCurrency,
                              );
                            });
                      } else {
                        if (snapshot.data.messageCode == HTTPStatusCode.UNSUPPORTED_VERSION) {
                          return UnsupportedVersion();
                        }

                        return Column(
                          children: <Widget>[
                            Text('${allTranslations.text("app.reports-list.failed-load-groups-message")} ${snapshot.data.messageCode} ${snapshot.data.message}'),
                          ],
                        );
                      }
                    }
                 }
              }),
        ),
      )
    ;
  }
}

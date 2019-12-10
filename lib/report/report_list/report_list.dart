import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intelligent_receipt/data_model/currency.dart';
import 'package:intelligent_receipt/data_model/enums.dart';
import 'package:intelligent_receipt/data_model/report.dart';
import 'package:intelligent_receipt/report/add_edit_report/add_edit_report.dart';
import 'package:intelligent_receipt/report/report_card/report_card.dart';
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

class ReportList extends StatefulWidget {
  final UserRepository _userRepository;
  final ReportStatusType _reportStatusType;

  ReportList({
    Key key,
    @required UserRepository userRepository,
    @required ReportStatusType reportStatusType,
  })  : assert(userRepository != null),
        _userRepository = userRepository,
        _reportStatusType = reportStatusType,
        super(key: key) {}

  @override
  ReportListState createState() => ReportListState();
}

class ActionWithLable {
  Function(int) action;
  String lable;
}

class ReportListState extends State<ReportList> {
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
  get _reportStatusType => widget._reportStatusType;

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
    _getReportsFuture = _userRepository.reportRepository.getReportsFromServer(forceRefresh: forceRefresh);
  }

  Future<void> _forceGetReportsFromServer() async {
    _getReportsFuture = _userRepository.reportRepository.getReportsFromServer(forceRefresh: true);
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
    if (_reportStatusType == ReportStatusType.Active) {
      sortingType = ReportSortType.CreateTime;
    } else {
      sortingType = ReportSortType.UpdateTime;
    }
    if (subMenuOverlayEntry != null) {
      subMenuOverlayEntry.remove();
      subMenuOverlayEntry = null;
    }
    if (_reportStatusType == ReportStatusType.Active) {
      _simpleValue = _simpleValue1;
    } else {
      _simpleValue = _simpleValue2;
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

  final ReportSortType _simpleValue1 = ReportSortType.CreateTime;
  final ReportSortType _simpleValue2 = ReportSortType.UpdateTime;
  final ReportSortType _simpleValue3 = ReportSortType.GroupName;
  ReportSortType _simpleValue;

  void showMenuSelection(ReportSortType value) {
//    if (<String>[_simpleValue1, _simpleValue2, _simpleValue3].contains(value))
    _simpleValue = value;
//    showInSnackBar('You selected: $value');
    print('You selected: $value');
    setState(() {
      sortingType = value;
    });
  }

  void showInSnackBar(String value) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(value),
    ));
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void reviewAction(int id) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) {
        return AddEditReport(
          userRepository: _userRepository,
          title: 'Edit Receipt Group',
          reportId: id,
        );
      }),
    );
    print('Review ${id}');
  }

  Future<void> deleteAndSetState(int reportId) async {
    DataResult result =
        await _userRepository.reportRepository.deleteReport(reportId);
    setState(() => {});
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
                        child: Text('Create Time'),
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
                        child: Text('Update Time'),
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
                        child: Text('Group Name'),
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

    return MaterialApp(
      home: Scaffold(
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
                            "${DateFormat().add_yMd().format(_fromDate.toLocal())}",
                            style: TextStyle(height: 1, fontSize: 12),
                          ),
                        ),
                        Icon(Icons.arrow_forward),
                        GestureDetector(
                          onTap: () {
                            _selectToDate(context);
                          },
                          child: Text(
                            "${DateFormat().add_yMd().format(_toDate.toLocal())}",
                            style: TextStyle(height: 1, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                    PopupMenuButton<ReportSortType>(
                      padding: EdgeInsets.zero,
                      initialValue: _simpleValue,
                      onSelected: showMenuSelection,
                      child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(Icons.sort),
                            Text(
//                          'x',
                              "[${_simpleValue.toString().split('.')[1]}]",
                              style: TextStyle(height: 1, fontSize: 12),
                            ),
                          ]),
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuItem<ReportSortType>>[
                        PopupMenuItem<ReportSortType>(
                          value: _simpleValue1,
                          child: Text(_simpleValue1.toString().split('.')[1]),
                        ),
                        PopupMenuItem<ReportSortType>(
                          value: _simpleValue2,
                          child: Text(_simpleValue2.toString().split('.')[1]),
                        ),
                        PopupMenuItem<ReportSortType>(
                          value: _simpleValue3,
                          child: Text(_simpleValue3.toString().split('.')[1]),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(
                        ascending ? Icons.arrow_upward : Icons.arrow_downward,
                        color: Colors.black,
                      ),
                      tooltip: 'Toggle ascending',
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
          onRefresh: _forceGetReportsFromServer,
          child: FutureBuilder<DataResult>(
              future: _getReportsFuture,
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
                        List<Report> sortedReportItems =
                        _userRepository.reportRepository.getSortedReportItems(
                            _reportStatusType,
                            sortingType,
                            ascending,
                            _fromDate,
                            _toDate);
                        List<ActionWithLable> actions = [];
                        ActionWithLable r = new ActionWithLable();
                        r.action = reviewAction;
                        r.lable = 'Review';
                        ActionWithLable d = new ActionWithLable();
                        d.action = deleteAction;
                        d.lable = 'Delete';
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
                        return Column(
                          children: <Widget>[
                            Text(
                                'Failed retrieving data, error code is ${snapshot.data.messageCode}'),
                            Text('Error message is ${snapshot.data.message}'),
                          ],
                        );
                      }
                    }
                }
              }),
        ),
      )
    );
  }
}

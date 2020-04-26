import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intelligent_receipt/data_model/currency.dart';
import 'package:intelligent_receipt/data_model/enums.dart';
import 'package:intelligent_receipt/report/add_edit_report/add_edit_report.dart';
import 'package:intelligent_receipt/report/add_edit_report/add_edit_report.dart';
import 'package:intelligent_receipt/report/report_list/report_list.dart';
import 'package:intelligent_receipt/tax_return/device_group/device_group.dart';
import 'package:intelligent_receipt/translations/global_translations.dart';
import 'package:intelligent_receipt/user_repository.dart';

//class ReportsTabs extends StatefulWidget {
class TaxReturnPage extends StatefulWidget {
  final UserRepository _userRepository;
  final FiscYear _fiscYear;
  DeviceGroup _deviceGroup;

//  ReportsTabs({
  TaxReturnPage({
    Key key,
    @required UserRepository userRepository,
    @required FiscYear fiscYear,
  })  : assert(userRepository != null),
        _userRepository = userRepository,
        _fiscYear = fiscYear,
        super(key: key) {
    _deviceGroup = DeviceGroup(userRepository: _userRepository, fiscYear: _fiscYear);
  }

  @override
//  _ReportsTabsState createState() => _ReportsTabsState();
  _TaxReturnPageState createState() => _TaxReturnPageState();
}

//class _ReportsTabsState extends State<ReportsTabs> {
class _TaxReturnPageState extends State<TaxReturnPage> {
//  HomeBloc _homeBloc;

  UserRepository get _userRepository => widget._userRepository;
  get _fiscYear => widget._fiscYear;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _fiscYear == FiscYear.Current
          ? AppBar(
              title: Text(allTranslations.text('Tax Return 2019-2020')),
            )
          : AppBar(
              title: Text(allTranslations.text('Tax Return 2018-2019')),
            ),
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
            Flexible(flex: 2, fit: FlexFit.tight,
                  child: widget._deviceGroup
                ),
          ],
        )),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intelligent_receipt/data_model/currency.dart';
import 'package:intelligent_receipt/data_model/enums.dart';
import 'package:intelligent_receipt/data_model/taxreturn.dart';
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
  final TaxReturn _taxReturn;
  DeviceGroup _deviceGroup;

//  ReportsTabs({
  TaxReturnPage({
    Key key,
    @required UserRepository userRepository,
    FiscYear fiscYear,
    @required TaxReturn taxReturn,
  })  : assert(userRepository != null),
        _userRepository = userRepository,
        _fiscYear = fiscYear,
        _taxReturn = taxReturn,
        super(key: key) {
    _deviceGroup = DeviceGroup(userRepository: _userRepository, taxReturn: _taxReturn,);
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
      appBar: AppBar(
              title: Text(widget._taxReturn.description),
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

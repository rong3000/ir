import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intelligent_receipt/data_model/enums.dart';
import 'package:intelligent_receipt/data_model/taxreturn.dart';
import 'package:intelligent_receipt/tax_return/tax_return_deductions/tax_return_deductions.dart';
import 'package:intelligent_receipt/translations/global_translations.dart';
import 'package:intelligent_receipt/user_repository.dart';

class TaxReturnPage extends StatefulWidget {
  final UserRepository _userRepository;
  final FiscYear _fiscYear;
  final TaxReturn _taxReturn;
  TaxReturnDeductions _deviceGroup;

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
    _deviceGroup = TaxReturnDeductions(userRepository: _userRepository, taxReturn: _taxReturn,);
  }

  @override
  _TaxReturnPageState createState() => _TaxReturnPageState();
}

class _TaxReturnPageState extends State<TaxReturnPage> {

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

import 'package:flutter/material.dart';
import 'package:intelligent_receipt/data_model/enums.dart';
import 'package:intelligent_receipt/data_model/taxreturn.dart';
import 'package:intelligent_receipt/main_screen/tax_return_page/tax_return_page.dart';
import 'package:intelligent_receipt/translations/global_translations.dart';
import 'package:intelligent_receipt/data_model/data_result.dart';
import 'package:intelligent_receipt/user_repository.dart';
import 'package:intelligent_receipt/data_model/report.dart';
import 'package:intelligent_receipt/report/add_edit_report/add_edit_report.dart';
import 'package:intelligent_receipt/helper_widgets/show_alert_message.dart';

class TaxReturnCard extends StatefulWidget {
  final UserRepository _userRepository;

  TaxReturnCard({
    Key key,
    @required UserRepository userRepository,
  })  : assert(userRepository != null),
        _userRepository = userRepository,
        super(key: key);

  @override
  _TaxReturnCardState createState() => _TaxReturnCardState();
}

class _TaxReturnCardState extends State<TaxReturnCard> {
  int _selectedTaxReturnYear = 0;
  UserRepository _userRepository;
  Future<DataResult> _getTaxReturnsFromServer;

  _TaxReturnCardState();

  @override
  void initState() {
    _userRepository = widget._userRepository;
    _getTaxReturnsFromServer = _userRepository.taxReturnRepository.getTaxReturns();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(5.0, 10.0, 5.0, 0.0),
          child: Container(
            constraints: BoxConstraints(maxHeight: 160, minHeight: 50),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Center (
                    child:Text(
                      allTranslations.text('app.functions-page.tax-return-title'),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    )),
                const Padding(padding: EdgeInsets.only(bottom: 2.0)),
                Text(
                  allTranslations.text('app.functions-page.tax-return-description'),
                  maxLines: 6,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
                _getTaxReturnListDropWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _viewTaxReturnList() async {
    DataResult result = await _userRepository.taxReturnRepository.getTaxReturn(_selectedTaxReturnYear);
    if (result.success) {
      TaxReturn taxReturn = result.obj;
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) {
          return TaxReturnPage(userRepository: _userRepository, taxReturn: taxReturn,);
        }),
      );
    } else {
      showAlertMessage(context,
          title: allTranslations.text('app.functions-page.tax-return-loading-failed-title'),
          message: allTranslations.text('app.functions-page.tax-return-loading-failed-message') + result.messageCode.toString() + " " + result.message);
    }
  }

  List<DropdownMenuItem<int>> _getTaxReturnList() {
    var list = List<DropdownMenuItem<int>>();
    var taxReturnList = _userRepository.taxReturnRepository.taxReturns;
    for (var tax in taxReturnList) {
      list.add(
        DropdownMenuItem<int>(value: tax.year, child: Text(tax.description)),
      );
    }
    if ((_selectedTaxReturnYear <= 0) && (list.length > 0)) {
      _selectedTaxReturnYear = taxReturnList[0].year;
    }
    return list;
  }

  Widget _getTaxReturnListDropWidget() {
    return FutureBuilder<DataResult>(
        future: _getTaxReturnsFromServer,
        builder: (BuildContext context, AsyncSnapshot<DataResult> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return new Text(allTranslations.text('app.functions-page.tax-return-list-loading'));
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
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Flexible(
                        flex: 6,
                        child: DropdownButtonFormField<int>(
                          isDense: true,
                          decoration:
                          InputDecoration(labelText: allTranslations.text('app.functions-page.tax-return-list')),
                          items: _getTaxReturnList(),
                          value: _selectedTaxReturnYear,
                          onChanged: (int newValue) {
                            setState(() {
                              _selectedTaxReturnYear = newValue;
                            });
                          },
                        ),
                      ),
                      Flexible(
                        flex: 4,
                        child: RaisedButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          onPressed: _viewTaxReturnList,
                          child: Text(allTranslations.text('app.functions-page.quarterly-report-view')),
                          color: Colors.lightBlue,
                        )
                      ),
                    ],
                  );
                } else {
                  return Column(
                    children: <Widget>[
                      Text(
                          '${allTranslations.text("app.functions-page.tax-return-list-loading-failed")} ${snapshot.data.messageCode} ${snapshot.data.message}'),
                    ],
                  );
                }
              }
          }
        });
  }
}


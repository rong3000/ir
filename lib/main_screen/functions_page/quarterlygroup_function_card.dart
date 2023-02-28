import 'package:flutter/material.dart';
import 'package:intelligent_receipt/translations/global_translations.dart';
import 'package:intelligent_receipt/data_model/data_result.dart';
import 'package:intelligent_receipt/user_repository.dart';
import 'package:intelligent_receipt/data_model/report.dart';
import 'package:intelligent_receipt/report/add_edit_report/add_edit_report.dart';
import 'package:intelligent_receipt/helper_widgets/show_alert_message.dart';

class QuarterlyGroupCard extends StatefulWidget {
  UserRepository _userRepository;

  QuarterlyGroupCard(this._userRepository);

  @override
  State<StatefulWidget> createState() {
    return _QuarterlyGroupCardState();
  }
}

class _QuarterlyGroupCardState extends State<QuarterlyGroupCard> {
  int _selectedQuarterlyGroupId = 0;
  UserRepository _userRepository;
  Future<DataResult> _getQuarterlyGroupsFromServer;

  _QuarterlyGroupCardState();

  @override
  void initState() {
    _userRepository = widget._userRepository;
    _getQuarterlyGroupsFromServer = _userRepository.quarterlyGroupRepository.getQuarterlyGroups();
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
                      allTranslations.text('app.functions-page.quarterly-report-title'),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    )),
                const Padding(padding: EdgeInsets.only(bottom: 2.0)),
                Text(
                  allTranslations.text('app.functions-page.quarterly-report-description'),
                  maxLines: 6,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
                _getQuanterlyGroupDropWidget(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _viewQuarterlyGroup() async {
    DataResult result = await _userRepository.quarterlyGroupRepository.getQuarterlyGroup(_selectedQuarterlyGroupId);
    if (result.success) {
      Report report = result.obj;
      if (report.id == 0) {
        // initialize the quarterly report
        report.rePopulateReceipsForQuarterlyGroup(_userRepository, _selectedQuarterlyGroupId);
      }
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) {
          return AddEditReport(
              userRepository: _userRepository,
              title: allTranslations.text('app.functions-page.quarterly-report-edit-title'),
              report: report);
        }),
      );
    } else {
      showAlertMessage(context,
          title: allTranslations.text('app.functions-page.quarterly-report-loading-failed-title'),
          message: allTranslations.text('app.functions-page.quarterly-report-loading-failed-message') + result.messageCode.toString() + " " + result.message);
    }
  }

  List<DropdownMenuItem<int>> _getQuanterlyGrouplist() {
    var list = List<DropdownMenuItem<int>>();
    var groupList = _userRepository.quarterlyGroupRepository.quarterlyGroups;
    for (var group in groupList) {
      list.add(
        DropdownMenuItem<int>(value: group.id, child: Text(group.groupName)),
      );
    }
    if ((_selectedQuarterlyGroupId <= 0) && (list.length > 0)) {
      _selectedQuarterlyGroupId = groupList[0].id;
    }
    return list;
  }

  Widget _getQuanterlyGroupDropWidget() {
    return FutureBuilder<DataResult>(
        future: _getQuarterlyGroupsFromServer,
        builder: (BuildContext context, AsyncSnapshot<DataResult> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return new Text(allTranslations.text('app.functions-page.quarterly-report-list-loading'));
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
                          InputDecoration(labelText: allTranslations.text('app.functions-page.quarterly-report-list')),
                          items: _getQuanterlyGrouplist(),
                          value: _selectedQuarterlyGroupId,
                          onChanged: (int newValue) {
                            setState(() {
                              _selectedQuarterlyGroupId = newValue;
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
                          onPressed: _viewQuarterlyGroup,
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
                          '${allTranslations.text("app.functions-page.quarterly-report-list-loading-failed")} ${snapshot.data.messageCode} ${snapshot.data.message}'),
                    ],
                  );
                }
              }
          }
        });
  }
}


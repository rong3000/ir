import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intelligent_receipt/data_model/data_result.dart';

import '../../user_repository.dart';


class SettingsPage extends StatefulWidget {
  final UserRepository _userRepository;

  final String name;
  SettingsPage(
      {Key key, @required UserRepository userRepository, @required this.name})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(key: key) {
  }

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  UserRepository get _userRepository => widget._userRepository;
  DataResult dataResult;

  fetchFromServer() async {

    print('3');
    await _userRepository.receiptRepository.getReceiptsFromServer(forceRefresh: true);

    print('4');
  }

  Future<void> getDataResultFromServer() async {
    dataResult = await _userRepository.receiptRepository.getReceiptsFromServer(forceRefresh: true);
    setState(() {
    });
  }

  @override
  void initState() {
    getDataResultFromServer();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
//    getDataResultFromServer();
    if (_userRepository.receiptRepository.receipts.isNotEmpty) {
      return Scaffold(
        body: Column(
          children: <Widget>[
            Text("${_userRepository.receiptRepository.receipts[0].companyName}"),
            Text("${dataResult.success}"),
            Card(
              child: ListTile(
                leading: Icon(Icons.album),
                title: AutoSizeText(
                  '${widget.name}\'s Receipts',
                  style: TextStyle(fontSize: 18),
                  minFontSize: 8,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            Card(
              child: ListTile(
//                leading: Icon(Icons.album),
                title: AutoSizeText(
                  'Default Currency',
                  style: TextStyle(fontSize: 18),
                  minFontSize: 8,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Text("AUD A\$"),

              ),
            ),
            Card(
              child: ListTile(
//                leading: Icon(Icons.album),
                title: AutoSizeText(
                  'Categories',
                  style: TextStyle(fontSize: 18),
                  minFontSize: 8,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Text("AUD A\$"),

              ),
            ),
          ],
        ),
      );
    } else {return Container();}
    //        if (dataResult.success) {

  }
}

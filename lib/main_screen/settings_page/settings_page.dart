import 'package:flutter/material.dart';
import 'package:intelligent_receipt/data_model/data_result.dart';

import '../../user_repository.dart';


class SettingsPage extends StatefulWidget {
  final UserRepository _userRepository;

  SettingsPage({Key key, @required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(key: key) {}

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
    print('3');
    dataResult = await _userRepository.receiptRepository.getReceiptsFromServer(forceRefresh: true);
    setState(() {
      dataResult = dataResult;
    });
    print('4');
  }

  @override
  void initState() {
    print('1');
//    fetchFromServer();
    getDataResultFromServer();

    print('2');
    super.initState();

    print('5');
  }

  @override
  Widget build(BuildContext context) {
    //        if (dataResult.success) {
    if (_userRepository.receiptRepository.receipts.isNotEmpty) {
      print('6');
      return Scaffold(
        body: Column(
          children: <Widget>[
                Text("${_userRepository.receiptRepository.receipts[0].companyName}"),
            Text("${dataResult.success}"),
//            Text("${dataResult.message}"),
//            Text("${dataResult.messageCode}"),
          ],
        ),
      );
    }
  }
}

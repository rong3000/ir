import 'package:flutter/material.dart';
import 'package:intelligent_receipt/data_model/receipt_repository.dart';

import '../../user_repository.dart';

class EditReceiptScreen extends StatefulWidget {
  final UserRepository _userRepository;
  final int _receiptId;

  EditReceiptScreen(
      {Key key,
      @required UserRepository userRepository,
      @required int receiptId})
      : assert(userRepository != null),
        _userRepository = userRepository,
        _receiptId = receiptId,
        super(key: key) {}

  @override
  EditReceiptScreenState createState() => EditReceiptScreenState();
}

class EditReceiptScreenState extends State<EditReceiptScreen> {
  UserRepository get _userRepository => widget._userRepository;
  int get _receiptId => widget._receiptId;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Receipt editing')),
      body: FutureBuilder<DataResult>(
          future: _userRepository.receiptRepository.getReceipt(_receiptId),
          builder: (BuildContext context, AsyncSnapshot<DataResult> snapshot) {
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
                  return Column(
                    children: <Widget>[
                      Text("Receipt editing ${_receiptId}"),
                      Text("${(snapshot.data.obj as Receipt).receiptDatetime}"),
                      Text("${(snapshot.data.obj as Receipt).uploadDatetime}"),
                      Text("${(snapshot.data.obj as Receipt).totalAmount}"),
                      Text("${(snapshot.data.obj as Receipt).categoryId}"),
                      Text("${(snapshot.data.obj as Receipt).companyName}"),
                      Text("${(snapshot.data.obj as Receipt).image}"),
                    ],
                  );
                }
            }
          }),
    );
  }
}

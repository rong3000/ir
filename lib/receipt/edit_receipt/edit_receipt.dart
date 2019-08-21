import 'package:flutter/material.dart';

import '../../user_repository.dart';

class EditReceiptScreen extends StatefulWidget {
  final UserRepository _userRepository;

  EditReceiptScreen({Key key, @required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(key: key) {}

  @override
  EditReceiptScreenState createState() => EditReceiptScreenState();
}

class EditReceiptScreenState extends State<EditReceiptScreen> {
  UserRepository get _userRepository => widget._userRepository;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Receipt editing')),
      body: Column(
        children: <Widget>[
          Text("Receipt editing"),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intelligent_receipt/data_model/receipt_repository.dart';

import '../../user_repository.dart';


class TabsExample extends StatelessWidget {
  final UserRepository _userRepository;

  TabsExample({Key key, @required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(key: key) {}

  @override
  Widget build(BuildContext context) {
    final _kTabPages = <Widget>[
      FutureBuilder<DataResult>(
          future: _userRepository.receiptRepository
              .getReceiptsFromServer(
              forceRefresh: true),
          builder: (BuildContext context,
              AsyncSnapshot<DataResult> snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                return new Text('Loading...');
              case ConnectionState.waiting:
                return new Center(
                    child: new CircularProgressIndicator());
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
                      Text("${snapshot.connectionState}"),
//                      Text("${snapshot.toString()}"),
                      Text("${snapshot.data.success}"),
                      Text("${snapshot.hasData}"),
//                      Text("${snapshot.error}"),
                      Text("${snapshot.hasError}"),
//                      Text("${snapshot.requireData}"),
//                      Text("${snapshot.runtimeType}"),
//                      Text("${snapshot.data}"),
//                      Text("${snapshot.connectionState}"),
                    ],
                  );

                }
                ;
            }
          }),
      Text('Submitted Reports'),
//      DataTableDemo(
//          userRepository: _userRepository,
//          name: 'a',
//          receiptStatusType: ReceiptStatusType.Uploaded),
//      DataTableDemo(
//          userRepository: _userRepository,
//          name: 'b',
//          receiptStatusType: ReceiptStatusType.Decoded),
//      DataTableDemo(
//          userRepository: _userRepository,
//          name: 'c',
//          receiptStatusType: ReceiptStatusType.Reviewed),
    ];
    final _kTabs = <Tab>[
      Tab(text: 'Active Reports'),
      Tab(text: 'Submitted Reports'),
    ];
    return DefaultTabController(
      length: _kTabs.length,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.cyan,
          // If `TabController controller` is not provided, then a
          // DefaultTabController ancestor must be provided instead.
          // Another way is to use a self-defined controller, c.f. "Bottom tab
          // bar" example.
          title: TabBar(
            tabs: _kTabs,
          ),
        ),
        body: TabBarView(
          children: _kTabPages,
        ),
      ),
    );
  }
}

class ReportsPage extends StatefulWidget {
  final UserRepository _userRepository;

  ReportsPage({Key key, @required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(key: key) {}

  @override
  _ReportsPageState createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  UserRepository get _userRepository => widget._userRepository;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OrientationBuilder(builder: (context, orientation) {
        return Column(
          children: <Widget>[
            Flexible(
              flex: 2,
              fit: FlexFit.tight,
              child: TabsExample(userRepository: _userRepository),
            ),
          ],
        );
      }),
    );
  }
}

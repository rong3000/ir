import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intelligent_receipt/main_screen/bloc/bloc.dart';

class ReceiptsPage extends StatefulWidget {
  @override
  _ReceiptsPageState createState() => _ReceiptsPageState();
}

class _ReceiptsPageState extends State<ReceiptsPage> {
  HomeBloc _homeBloc;

  @override
  void initState() {
    super.initState();
    _homeBloc = BlocProvider.of<HomeBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: BlocBuilder(
            bloc: _homeBloc,
            builder: (BuildContext context, HomeState state) {
              return Column(
                children: <Widget>[
                  Flexible(
                      flex: 15,
                      fit: FlexFit.tight,
                      child: Row(
                        children: <Widget>[
                          Flexible(
                            flex: 1,
                            fit: FlexFit.tight,
                            child: Container(
                              color: Colors.cyan,
                              child: ListTile(
                                leading: Icon(Icons.album),
                                title: Wrap(children: <Widget>[

                                  Text('Add Your (First) Receipt'),
                                  Text(
                                      ''),
                                ],),
                              ),
                            ),
                          ),
                          Flexible(
                            flex: 1,
                            fit: FlexFit.tight,
                            child: Container(
                              color: Colors.cyan,
                              child: ListTile(
                                leading: Icon(Icons.album),
                                title: Wrap(children: <Widget>[

                                  Text('Manually Add Your (First) Receipt'),
                                  Text(
                                      ''),
                                ],),
                              ),
                            ),
                          ),
                        ],
                      )
                  ),
                  Flexible(
                      flex: 15,
                      fit: FlexFit.tight,
                      child: Row(
                        children: <Widget>[
                          Flexible(
                            flex: 1,
                            fit: FlexFit.tight,
                            child: Container(
                              color: Colors.cyan,
                              child: ListTile(
                                leading: Icon(Icons.album),
                                title: Wrap(children: <Widget>[

                                  Text('View Imported Receipts'),
                                  Text(
                                      ''),
                                ],),
                              ),
                            ),
                          ),
                          Flexible(
                            flex: 1,
                            fit: FlexFit.tight,
                            child: Container(
                              color: Colors.cyan,
                              child: ListTile(
                                leading: Icon(Icons.album),
                                title: Wrap(children: <Widget>[

                                  Text('View Reports'),
                                  Text(
                                      ''),
                                ],),
                              ),
                            ),
                          ),
                        ],
                      )
                  ),
                  Flexible(
                    flex: 10,
                    fit: FlexFit.tight,
                    child: Container(
                      color: Colors.cyan,
                      child: ListTile(
                        leading: Icon(Icons.album),
                        title: Wrap(children: <Widget>[

                          Text('Intelligent Receipt'),
                          Text(
                              'Get unlimited automatically scans'),
                        ],),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 10,
                    fit: FlexFit.tight,
                    child: Container(
                      color: Colors.cyan,
                      child: ListTile(
                        leading: Icon(Icons.album),
                        title: Wrap(children: <Widget>[

                          Text('Intelligent Receipt'),
                          Text(
                              'We have sent you an email, please click confirm'),
                        ],),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 10,
                    fit: FlexFit.tight,
                    child: Container(
                      color: Colors.cyan,
                      child: ListTile(
                        leading: Icon(Icons.album),
                        title: Wrap(children: <Widget>[

                          Text('Intelligent Receipt'),
                          Text(
                              'Invite your friends to join IR then receive more free automatically scans'),
                        ],),
                      ),
                    ),
                  ),
                ],
              );
            }),
      ),
    );
  }
}

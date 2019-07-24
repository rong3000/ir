import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intelligent_receipt/main_screen/bloc/bloc.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  HomeBloc _homeBloc;

  @override
  void initState() {
    super.initState();
    _homeBloc = BlocProvider.of<HomeBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    final Orientation orientation = MediaQuery.of(context).orientation;
    return BlocListener(
        bloc: _homeBloc,
        listener: (BuildContext context, HomeState state) {
          if (state is State1) {
            Scaffold.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('State1...'),
                      CircularProgressIndicator(),
                    ],
                  ),
                ),
              );
          }
          if (state is State2) {
            _ackAlert(context);
          }
        },
        child: BlocBuilder(
            bloc: _homeBloc,
            builder: (BuildContext context, HomeState state) {
              return Column(
                children: <Widget>[
                  Flexible(
                    flex: 1,
                    child: Column(
                      children: <Widget>[
                        Flexible(
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: FractionallySizedBox(
                                  heightFactor: 1,
                                  child: Card(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        const ListTile(
                                          leading: Icon(Icons.album),
                                          title: Text('Add Your (First) Receipt'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: FractionallySizedBox(
                                  heightFactor: 1,
                                  child: Card(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        const ListTile(
                                          leading: Icon(Icons.album),
                                          title: Text(
                                              'Manually Add Your (First) Receipt'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Flexible(
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: FractionallySizedBox(
                                  heightFactor: 1,
                                  child: Card(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        const ListTile(
                                          leading: Icon(Icons.album),
                                          title: Text('View Imported Receipts'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: FractionallySizedBox(
                                  heightFactor: 1,
                                  child: Card(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        const ListTile(
                                          leading: Icon(Icons.album),
                                          title: Text('View Reports'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
//                  MediaQuery.removePadding(
//                    removeTop: true,
//                    context: context,
//                    child: Text(state.toString()),
//                  ),
//                  Row(
//                    children: <Widget>[
//                      Expanded(
//                        child:
//                        RaisedButton(
//                          shape: RoundedRectangleBorder(
//                            borderRadius: BorderRadius.circular(30.0),
//                          ),
//                          onPressed: () => {_homeBloc.dispatch(Event1())},
//                          child: Text('Event 1'),
//                        ),
//                      ),
//                      Expanded(
//                        child:
//                        RaisedButton(
//                          shape: RoundedRectangleBorder(
//                            borderRadius: BorderRadius.circular(30.0),
//                          ),
//                          onPressed: () => {_homeBloc.dispatch(Event2())},
//                          child: Text('Event 2'),
//                        ),
//                      ),
//                      Expanded(
//                        child:
//                        RaisedButton(
//                          shape: RoundedRectangleBorder(
//                            borderRadius: BorderRadius.circular(30.0),
//                          ),
//                          onPressed: () => {_homeBloc.dispatch(Event3())},
//                          child: Text('Event 3'),
//                        ),
//                      ),
//                    ],
//                  ),

                  Flexible(
                    flex: 1,
                    child: Column(
                      children: <Widget>[
                        Flexible(
                          child: Card(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                const ListTile(
                                  leading: Icon(Icons.album),
                                  title: Text('Intelligent Receipt'),
                                  subtitle: Text(
                                      'Invite your friends to join IR then receive more free automatically scans'),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Flexible(
                          child: Card(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                const ListTile(
                                  leading: Icon(Icons.album),
                                  title: Text('Intelligent Receipt'),
                                  subtitle:
                                      Text('Get unlimited automatically scans'),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Flexible(
                          child: Card(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                const ListTile(
                                  leading: Icon(Icons.album),
                                  title: Text('Intelligent Receipt'),
                                  subtitle: Text(
                                      'We have sent you an email, please click confirm'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }));
  }

  Future<void> _ackAlert(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Not in stock'),
          content: const Text('This item is no longer available'),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

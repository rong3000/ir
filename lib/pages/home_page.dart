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
                  MediaQuery.removePadding(
                    removeTop: true,
                    context: context,
                    child: Text(state.toString()),
                  ),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child:
                        RaisedButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          onPressed: () => {_homeBloc.dispatch(Event1())},
                          child: Text('Event 1'),
                        ),
                      ),
                      Expanded(
                        child:
                        RaisedButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          onPressed: () => {_homeBloc.dispatch(Event2())},
                          child: Text('Event 2'),
                        ),
                      ),
                      Expanded(
                        child:
                        RaisedButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          onPressed: () => {_homeBloc.dispatch(Event3())},
                          child: Text('Event 3'),
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Container(
                                height: 100.0,
                                color: Colors.blue,
                                margin: EdgeInsets.all(5),
                                child:
                                Text('Add Your (First) Receipt'),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: 100.0,
                                color: Colors.red,
                                margin: EdgeInsets.all(5),
                                child:
                                Text('Manually Add Your (First) Receipt'),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Container(
                                height: 100.0,
                                color: Colors.amber,
                                margin: EdgeInsets.all(5),
                                child:
                                Text('View Imported Receipts'),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: 100.0,
                                color: Colors.pink,
                                margin: EdgeInsets.all(5),
                                child:
                                Text('View Reports'),
                              ),
                            ),
                          ],
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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intelligent_receipt/home/bloc/bloc.dart';

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
                  RaisedButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    onPressed: () => {_homeBloc.dispatch(Event1())},
                    child: Text('Event 1'),
                  ),
                  RaisedButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    onPressed: () => {_homeBloc.dispatch(Event2())},
                    child: Text('Event 2'),
                  ),
                  RaisedButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    onPressed: () => {_homeBloc.dispatch(Event3())},
                    child: Text('Event 3'),
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

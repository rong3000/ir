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
                  Expanded(
                    child: SafeArea(
                      top: true,
                      bottom: true,
                      child: GridView.count(
                        crossAxisCount: (orientation == Orientation.portrait) ? 2 : 3,
                        mainAxisSpacing: 4.0,
                        crossAxisSpacing: 4.0,
                        padding: const EdgeInsets.all(4.0),
                        childAspectRatio: (orientation == Orientation.portrait) ? 1.0 : 1.3,
                        children: <Widget>[
                          Text('Add Your (First) Receipt'),
                          Text('Manually Add Your (First) Receipt'),
                          Text('View Imported Receipts'),
                          Text('View Reports'),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: SafeArea(
                      top: false,
                      bottom: false,
                      child: GridView.count(
                        crossAxisCount: (orientation == Orientation.portrait) ? 1 : 1,
                        mainAxisSpacing: 4.0,
                        crossAxisSpacing: 4.0,
                        padding: const EdgeInsets.all(4.0),
                        childAspectRatio: (orientation == Orientation.portrait) ? 2 : 2,
                        children: <Widget>[
                          Text('Intelligent Receipt'),
                          Text('Intelligent Receipt'),
                          Text('Intelligent Receipt'),
                        ],
                      ),
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

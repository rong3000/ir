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
  Widget build(BuildContext context) {
    BlocBuilder(
        bloc: _homeBloc,
        builder: (BuildContext context, HomeState state) {
          return Scaffold(
            body: Stack(
              children: <Widget>[
                MediaQuery.removePadding(
                  removeTop: true,
                  context: context,
                  child: Text('Home'),
                ),
                RaisedButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  onPressed: () => {_homeBloc.dispatch(Event1())},
                  child: Text('Home Button 1'),
                )
              ],
            ),
          );
        });
  }
}

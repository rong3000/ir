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
          if (state.State1) {
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
          if (state.State2) {}
        },
        child: BlocBuilder(
            bloc: _homeBloc,
            builder: (BuildContext context, HomeState state) {
              return Column(
                children: <Widget>[
                  MediaQuery.removePadding(
                    removeTop: true,
                    context: context,
                    child: Text('home'),
                  ),
                  RaisedButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    onPressed: () => {_homeBloc.dispatch(Event1())},
                    child: Text('Home Button 1'),
                  )
                ],
              );
            }));
  }
}

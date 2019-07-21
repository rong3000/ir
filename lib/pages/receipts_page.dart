import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intelligent_receipt/home/bloc/bloc.dart';

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
                  MediaQuery.removePadding(
                    removeTop: true,
                    context: context,
                    child: Text(state.toString()),
                  ),
                ],
              );
            }),
      ),
    );
  }
}

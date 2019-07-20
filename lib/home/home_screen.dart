import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intelligent_receipt/user_repository.dart';
import 'package:intelligent_receipt/home/home.dart';

class HomeScreen extends StatelessWidget {
  final UserRepository _userRepository;

  HomeScreen({Key key, @required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: Center(
        child: BlocProvider<HomeBloc>(
          builder: (context) => HomeBloc(userRepository: _userRepository),
          child: HomeForm(),
        ),
      ),
    );
  }
}

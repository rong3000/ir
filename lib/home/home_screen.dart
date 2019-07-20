import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intelligent_receipt/navigator/navigator_screen.dart';
import 'package:intelligent_receipt/user_repository.dart';
import 'package:intelligent_receipt/home/home.dart';

class HomeScreen extends StatelessWidget {
  final UserRepository _userRepository;
  final String name;

  HomeScreen({Key key, @required UserRepository userRepository, @required this.name})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: BlocProvider<HomeBloc>(
          builder: (context) => HomeBloc(userRepository: _userRepository),
          child: NavigatorScreen(userRepository: _userRepository, name: this.name),
        ),
      ),
    );
  }
}

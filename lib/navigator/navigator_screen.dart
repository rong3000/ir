import 'package:flutter/material.dart';
import 'package:intelligent_receipt/authentication_bloc/bloc.dart';
import 'package:intelligent_receipt/home/bloc/bloc.dart';
import 'package:intelligent_receipt/login/login.dart';
import 'package:intelligent_receipt/pages/home_page.dart';
import 'package:intelligent_receipt/pages/search_bar.dart';
import 'package:intelligent_receipt/pages/settings_page.dart';
import 'package:intelligent_receipt/pages/receipts_page.dart';
import 'package:intelligent_receipt/pages/reports_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intelligent_receipt/user_repository.dart';

class NavigatorScreen extends StatefulWidget {
  final UserRepository _userRepository;

  final String name;
  NavigatorScreen({Key key, @required UserRepository userRepository, @required this.name})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(key: key);

  @override
  _NavigatorScreenState createState() => _NavigatorScreenState();
}

class _NavigatorScreenState extends State<NavigatorScreen> {
  HomeBloc _homeBloc;

  final _defaultColor = Colors.grey;
  final _activeColor = Colors.blue;
  int _currentIndex = 0;
  final PageController _controller = PageController(
    initialPage: 0,
  );

  @override
  void initState() {
    super.initState();
    _homeBloc = BlocProvider.of<HomeBloc>(context);
  }

  UserRepository get _userRepository => widget._userRepository;
  get name => widget.name;

  @override
  Widget build(BuildContext context) {
    return BlocListener(
      bloc: _homeBloc,
      listener: (BuildContext context, HomeState state) {
        if (state.button1Pressed) {
          Scaffold.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Button 1 of Home Page pressed'),
                    CircularProgressIndicator(),
                  ],
                ),
              ),
            );
        }
        if (state.isSuccess) {
          // BlocProvider.of<AuthenticationBloc>(context).dispatch(LoggedIn());
          // Navigator.of(context).pop();
        }
      },
      child: BlocBuilder(
        bloc: _homeBloc,
        builder: (BuildContext context, HomeState state) {
          return Scaffold(
            appBar: AppBar(
              title: SearchBar(name: name),
            ),
            body: PageView(
              controller: _controller,
              children: <Widget>[
                HomePage(),
                ReceiptsPage(),
                ReportsPage(),
                SettingsPage(),
              ],
            ),
            bottomNavigationBar: BottomNavigationBar(
                currentIndex: _currentIndex,
                onTap: (index) {
                  _controller.jumpToPage(index);
                  setState(() {
                    _currentIndex = index;
                  });
                },
                type: BottomNavigationBarType.fixed,
                items: [
                  BottomNavigationBarItem(
                      icon: Icon(Icons.home, color: _defaultColor),
                      activeIcon: Icon(Icons.home, color: _activeColor),
                      title: Text(
                        'Home',
                        style: TextStyle(
                            color: _currentIndex != 0 ? _defaultColor : _activeColor),
                      )),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.search, color: _defaultColor),
                      activeIcon: Icon(Icons.search, color: _activeColor),
                      title: Text(
                        'Receipts',
                        style: TextStyle(
                            color: _currentIndex != 1 ? _defaultColor : _activeColor),
                      )),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.camera_alt, color: _defaultColor),
                      activeIcon: Icon(Icons.camera_alt, color: _activeColor),
                      title: Text(
                        'Reports',
                        style: TextStyle(
                            color: _currentIndex != 2 ? _defaultColor : _activeColor),
                      )),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.account_circle, color: _defaultColor),
                      activeIcon: Icon(Icons.account_circle, color: _activeColor),
                      title: Text(
                        'Settings',
                        style: TextStyle(
                            color: _currentIndex != 3 ? _defaultColor : _activeColor),
                      )),
                ]),
            drawer: Drawer(
              child: ListView(
                children: <Widget>[
                  DrawerHeader(
                    child: Text('Drawer Header'),
                  ),
                  ListTile(
                    title: Text('Log In'),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) {
                          return LoginScreen(userRepository: _userRepository);
                        }),
                      );
                    },
                  ),
                  ListTile(
                    title: Text('Log Out'),
                    onTap: () {
                      BlocProvider.of<AuthenticationBloc>(context).dispatch(
                        LoggedOut(),
                      );
                    },
                  ),
                  ListTile(
                    title: Text('Item 3'),
                  ),
                  ListTile(
                    title: Text('Item 4'),
                  ),
                ],
              ),
            ),
          );
          // return !state.isEmailValid ? 'Invalid Email' : null;
          // onPressed: isHomeButtonEnabled(state)
        },
      ),
    );


  }
}

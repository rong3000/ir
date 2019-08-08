import 'package:flutter/material.dart';
import 'package:intelligent_receipt/authentication_bloc/bloc.dart';
import 'package:intelligent_receipt/main_screen/bloc/bloc.dart';
import 'package:intelligent_receipt/login/login.dart';
import 'package:intelligent_receipt/main_screen/home_page/home_page.dart';
import 'package:intelligent_receipt/main_screen/search_bar/search_bar.dart';
import 'package:intelligent_receipt/main_screen/settings_page/settings_page.dart';
import 'package:intelligent_receipt/main_screen/reports_page/reports_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intelligent_receipt/user_repository.dart';
import 'receipts_page/receipts_page.dart';

class HomeScreen extends StatefulWidget {
  final UserRepository _userRepository;

  final String name;
  HomeScreen(
      {Key key, @required UserRepository userRepository, @required this.name})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(key: key) {
  }

  @override
  _HomeScreenState createState() => _HomeScreenState();

}

class _HomeScreenState extends State<HomeScreen> {
  final _defaultColor = Colors.grey;
  final _activeColor = Colors.blue;
  int _currentIndex = 0;
  final PageController _controller = PageController(
    initialPage: 0,
  );

  UserRepository get _userRepository => widget._userRepository;
  get name => widget.name;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HomeBloc>(
      builder: (context) => HomeBloc(userRepository: _userRepository),
      child: Scaffold(
        appBar: AppBar(
          title: SearchBar(name: name),
        ),
        body: PageView(
          controller: _controller,
          children: <Widget>[
            HomePage(),
            ReceiptsPage(userRepository: _userRepository),
            ReportsPage(userRepository: _userRepository),
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
                        color:
                            _currentIndex != 0 ? _defaultColor : _activeColor),
                  )),
              BottomNavigationBarItem(
                  icon: Icon(Icons.search, color: _defaultColor),
                  activeIcon: Icon(Icons.search, color: _activeColor),
                  title: Text(
                    'Receipts',
                    style: TextStyle(
                        color:
                            _currentIndex != 1 ? _defaultColor : _activeColor),
                  )),
              BottomNavigationBarItem(
                  icon: Icon(Icons.camera_alt, color: _defaultColor),
                  activeIcon: Icon(Icons.camera_alt, color: _activeColor),
                  title: Text(
                    'Reports',
                    style: TextStyle(
                        color:
                            _currentIndex != 2 ? _defaultColor : _activeColor),
                  )),
              BottomNavigationBarItem(
                  icon: Icon(Icons.account_circle, color: _defaultColor),
                  activeIcon: Icon(Icons.account_circle, color: _activeColor),
                  title: Text(
                    'Settings',
                    style: TextStyle(
                        color:
                            _currentIndex != 3 ? _defaultColor : _activeColor),
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
				  Navigator.pop(context);
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
      ),
    );
  }
}

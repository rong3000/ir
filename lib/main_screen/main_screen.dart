import 'package:flutter/material.dart';
import 'package:intelligent_receipt/authentication_bloc/bloc.dart';
import 'package:intelligent_receipt/data_model/enums.dart';
import 'package:intelligent_receipt/main_screen/bloc/bloc.dart';
import 'package:intelligent_receipt/login/login.dart';
import 'package:intelligent_receipt/main_screen/home_page/home_page.dart';
import 'package:intelligent_receipt/main_screen/search_bar/search_bar.dart';
import 'package:intelligent_receipt/main_screen/settings_page/settings_page.dart';
import 'package:intelligent_receipt/main_screen/reports_page/reports_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intelligent_receipt/translations/global_translations.dart';
import 'package:intelligent_receipt/user_repository.dart';
import 'receipts_page/receipts_page.dart';

class MainScreen extends StatefulWidget {
  final UserRepository _userRepository;

  final String name;
  MainScreen(
      {Key key, @required UserRepository userRepository, @required this.name})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(key: key);

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  
  var appTitle = allTranslations.text('app.title');

  final _defaultColor = Colors.grey;
  final _activeColor = Colors.blue;
  int _currentIndex = 0;
  final PageController _controller = PageController(
    initialPage: 0,
  );

  UserRepository get _userRepository => widget._userRepository;
  get name => widget.name;

  void jumpTo(int i) {
    _controller.jumpToPage(i);
    setState(() {
      _currentIndex = i;
    });
  }

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
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          children: <Widget>[
            HomePage(userRepository: _userRepository, action: jumpTo,),
            ReceiptsPage(userRepository: _userRepository),
            ReportsPage(
                userRepository: _userRepository,
                reportStatusType: ReportStatusType.Active),
            SettingsPage(userRepository: _userRepository, name: name),
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
                  icon: Icon(Icons.receipt, color: _defaultColor),
                  activeIcon: Icon(Icons.receipt, color: _activeColor),
                  title: Text(
                    'Receipts',
                    style: TextStyle(
                        color:
                            _currentIndex != 1 ? _defaultColor : _activeColor),
                  )),
              BottomNavigationBarItem(
                  icon: Icon(Icons.insert_chart, color: _defaultColor),
                  activeIcon: Icon(Icons.insert_chart, color: _activeColor),
                  title: Text(
                    'Groups',
                    style: TextStyle(
                        color:
                            _currentIndex != 2 ? _defaultColor : _activeColor),
                  )),
              BottomNavigationBarItem(
                  icon: Icon(Icons.settings, color: _defaultColor),
                  activeIcon: Icon(Icons.settings, color: _activeColor),
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
                child: Column(
                  children: <Widget>[
                    Text(appTitle),
                    Icon(Icons.verified_user),
                    Text('$name'),
                  ],
                ),
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
//              ListTile(
//                title: Text('FB'),
//                onTap: () {
//                  Navigator.of(context).push(
//                    MaterialPageRoute(builder: (context) {
//                      return FB();
//                    }),
//                  );
//                },
//              ),
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
                title: Text('View Archived Groups'),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) {
                      return ReportsPage(
                          userRepository: _userRepository,
                          reportStatusType: ReportStatusType.Submitted);
                    }),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

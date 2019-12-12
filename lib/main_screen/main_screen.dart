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
import 'package:upgrader/upgrader.dart';
import 'receipts_page/receipts_page.dart';

class MainScreen extends StatefulWidget {
  final UserRepository _userRepository;
  HomePage _homePage;
  ReceiptsPage _receiptsPage;
  ReportsPage _reportsPage;
  SettingsPage _settingsPage;

  final String name;
  MainScreen(
      {Key key, @required UserRepository userRepository, @required this.name})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(key: key) {
    _homePage = new HomePage(userRepository: userRepository);
    _receiptsPage = new ReceiptsPage(userRepository: userRepository);
    _reportsPage = new ReportsPage(userRepository: userRepository, reportStatusType: ReportStatusType.Active);
    _settingsPage = new SettingsPage(userRepository: userRepository, name: name);
  }

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  
  String get appTitle => allTranslations.text('app.title');
  String get homeTabLabel => allTranslations.text('app.main-screen.home-tab-label');
  String get receiptsTabLabel => allTranslations.text('app.main-screen.receipts-tab-label');
  String get groupsTabLabel => allTranslations.text('app.main-screen.groups-tab-label');
  String get settingsTabLabel => allTranslations.text('app.main-screen.settings-tab-label');

  final _defaultColor = Colors.grey;
  final _activeColor = Colors.blue;
  int _currentIndex = 0;
//  bool _verified;
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

  Future<void> userReload() async {
    await _userRepository.currentUser.reload();
    setState(() {

    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    userReload();
//    _verified = _userRepository.currentUser.isEmailVerified;
  }

  @override
  Widget build(BuildContext context) {
    Upgrader().clearSavedSettings();
    widget._homePage.setAction(jumpTo);
    // On Android, setup the Appcast.
    // On iOS, the default behavior will be to use the App Store version of
    // the app, so update the Bundle Identifier in example/ios/Runner with a
    // valid identifier already in the App Store.
    final String appcastURL =
        'https://raw.githubusercontent.com/larryaasen/upgrader/master/test/testappcast.xml';
    final cfg = AppcastConfiguration(url: appcastURL, supportedOS: ["android"]);

    return BlocProvider<HomeBloc>(
      builder: (context) => HomeBloc(userRepository: _userRepository),
      child: Scaffold(
        appBar: AppBar(
          title: SearchBar(userRepository: _userRepository, name: name),
        ),
        body: PageView(
          controller: _controller,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
//              _verified = _userRepository.currentUser.isEmailVerified;
            });
            userReload();
          },
          children: <Widget>[
            widget._homePage,
            widget._receiptsPage,
            widget._reportsPage,
            widget._settingsPage,
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              _controller.jumpToPage(index);
              setState(() {
                _currentIndex = index;
//                _verified = _userRepository.currentUser.isEmailVerified;
              });
              userReload();
            },
            type: BottomNavigationBarType.fixed,
            items: [
              BottomNavigationBarItem(
                  icon: Icon(Icons.home, color: _defaultColor),
                  activeIcon: Icon(Icons.home, color: _activeColor),
                  title: Text(
                    homeTabLabel,
                    style: TextStyle(
                        color:
                            _currentIndex != 0 ? _defaultColor : _activeColor),
                  )),
              BottomNavigationBarItem(
                  icon: Icon(Icons.receipt, color: _defaultColor),
                  activeIcon: Icon(Icons.receipt, color: _activeColor),
                  title: Text(
                    receiptsTabLabel,
                    style: TextStyle(
                        color:
                            _currentIndex != 1 ? _defaultColor : _activeColor),
                  )),
              BottomNavigationBarItem(
                  icon: Icon(Icons.insert_chart, color: _defaultColor),
                  activeIcon: Icon(Icons.insert_chart, color: _activeColor),
                  title: Text(
                    groupsTabLabel,
                    style: TextStyle(
                        color:
                            _currentIndex != 2 ? _defaultColor : _activeColor),
                  )),
              BottomNavigationBarItem(
                  icon: Icon(Icons.settings, color: _defaultColor),
                  activeIcon: Icon(Icons.settings, color: _activeColor),
                  title: Text(
                    settingsTabLabel,
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

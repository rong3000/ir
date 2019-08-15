import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intelligent_receipt/main_screen/bloc/bloc.dart';
import 'package:flutter/rendering.dart';
import 'package:intelligent_receipt/main_screen/receipts_page/paginated_data_table.dart';
import 'package:intelligent_receipt/user_repository.dart';

class TabsExample extends StatelessWidget {
  final UserRepository _userRepository;

  TabsExample(
      {Key key, @required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(key: key) {
  }

  @override
  Widget build(BuildContext context) {
    final _kTabPages = <Widget>[
      DataTableDemo(userRepository: _userRepository),
      DataTableDemo(userRepository: _userRepository),
      DataTableDemo(userRepository: _userRepository),
    ];
    final _kTabs = <Tab>[
      Tab(text: 'Pending'),
      Tab(text: 'Unreviewed'),
      Tab(text: 'Reviewed'),
    ];
    return DefaultTabController(
      length: _kTabs.length,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.cyan,
          // If `TabController controller` is not provided, then a
          // DefaultTabController ancestor must be provided instead.
          // Another way is to use a self-defined controller, c.f. "Bottom tab
          // bar" example.
          title: TabBar(
            tabs: _kTabs,
          ),
        ),
        body: TabBarView(
          children: _kTabPages,
        ),
      ),
    );
  }
}

class ReceiptsPage extends StatefulWidget {
  final UserRepository _userRepository;

  ReceiptsPage(
      {Key key, @required UserRepository userRepository})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(key: key) {
  }

  @override
  _ReceiptsPageState createState() => _ReceiptsPageState();
}

class _ReceiptsPageState extends State<ReceiptsPage> {
  HomeBloc _homeBloc;

  UserRepository get _userRepository => widget._userRepository;

  @override
  void initState() {
//    getData() async {
//      await _userRepository.receiptRepository
//          .getReceiptsFromServer(forceRefresh: true);
//    }
//
//    getData();
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
              return Scaffold(
                body: OrientationBuilder(builder: (context, orientation){
                  return
                    Column(
                      children: <Widget>[
                        Flexible(
                          flex: 2,
                          fit: FlexFit.tight,
                          child: TabsExample(userRepository: _userRepository),
                        ),
                        Flexible(
                            fit: FlexFit.tight,
                            child: Wrap(
                              children: <Widget>[
                                FractionallySizedBox(
                                  widthFactor: orientation == Orientation.portrait ? 1: 0.33,
                                  child: Container(
                                    height: MediaQuery.of(context).size.height * (orientation == Orientation.portrait ? 0.125: 0.32),
                                    child:
                                    Card(
                                      child: ListTile(
                                        leading: Icon(Icons.album),
                                        title: AutoSizeText(
                                          'Snapped on...',
                                          style: TextStyle(fontSize: 18),
                                          minFontSize: 8,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        subtitle: AutoSizeText(
                                          'Click to View or Remove the receipt',
                                          style: TextStyle(fontSize: 18),
                                          minFontSize: 8,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),

                                      ),
                                    ),
                                  ),
                                ),
                                FractionallySizedBox(
                                  widthFactor: orientation == Orientation.portrait ? 1: 0.33,
                                  child: Container(
                                    height: MediaQuery.of(context).size.height * (orientation == Orientation.portrait ? 0.125: 0.32),
                                    child:
                                    Card(
                                      child: ListTile(
                                        leading: Icon(Icons.album),
                                        title: AutoSizeText(
                                          'Snapped on...',
                                          style: TextStyle(fontSize: 18),
                                          minFontSize: 8,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        subtitle: AutoSizeText(
                                          'Click to View or Remove the receipt',
                                          style: TextStyle(fontSize: 18),
                                          minFontSize: 8,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),

                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                        ),
                      ],
                    );
                }),
              );
            }),
      ),
    );
  }
}

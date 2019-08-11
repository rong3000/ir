import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intelligent_receipt/main_screen/bloc/bloc.dart';
import 'package:flutter/rendering.dart';
import 'package:intelligent_receipt/user_repository.dart';

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
                          child: TableListView(userRepository: _userRepository),
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

class TableListView extends StatefulWidget {
  final UserRepository _userRepository;

  TableListView(
      {Key key, @required UserRepository userRepository, this.title})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(key: key) {
  }
  final String title;

  @override
  TableListViewState createState() => new TableListViewState();
}

class TableListViewState extends State<TableListView> {
  UserRepository get _userRepository => widget._userRepository;
  int present = 0;
  int perPage = 5;

  final originalItems = List<String>.generate(100, (i) => "Item $i");
//  final originalReceips = ;
  var items = List<String>();


  @override
  void initState() {
    super.initState();
    setState(() {
      items.addAll(originalItems.getRange(present, present + perPage));
      present = present + perPage;
    });
  }

  void loadMore() {
    setState(() {
      if((present + perPage )> originalItems.length) {
        items.addAll(
            originalItems.getRange(present, originalItems.length));
      } else {
        items.addAll(
            originalItems.getRange(present, present + perPage));
      }
      present = present + perPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo.metrics.pixels ==
              scrollInfo.metrics.maxScrollExtent) {
            loadMore();
          }
        },
        child: ListView.builder(
          itemCount: (present <= originalItems.length) ? items.length + 1 : items.length,
          itemBuilder: (context, index) {
            return (index == items.length ) ?
            Container(
              child: new Center(
                child: new CircularProgressIndicator(),
              ),
            )
                :
            ListTile(
              title: Text('${items[index]}'),
            );
          },
        ),
      ),
    );
  }
}

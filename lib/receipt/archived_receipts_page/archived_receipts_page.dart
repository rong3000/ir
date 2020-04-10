import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intelligent_receipt/data_model/archived_receipt_models/archivedreceiptdatarange.dart';
import 'package:intelligent_receipt/data_model/preferences/preferences_repository.dart';
import './bloc/archived_receipts_bloc.dart';
import './bloc/archived_receipts_events.dart';
import './bloc/archived_receipts_state.dart';
import './loading_spinner.dart';
import './archived_receipts_list_page.dart';
import 'package:intelligent_receipt/translations/global_translations.dart';
import 'package:intelligent_receipt/user_repository.dart';
import 'package:intl/intl.dart';

class ArchivedReceiptsPage extends StatefulWidget {
  final UserRepository _userRepository;

  ArchivedReceiptsPage({
    Key key,
    @required UserRepository userRepository,
  })  : assert(userRepository != null),
        _userRepository = userRepository,
        super(key: key);

  @override
  _ArchivedReceiptsPageState createState() => _ArchivedReceiptsPageState();
}

class _ArchivedReceiptsPageState extends State<ArchivedReceiptsPage> {
  ArchivedReceiptsBloc _archivedReceiptsBloc;
  PreferencesRepository _preferencesRepository;
  DateFormat dateFormat;
  Function(int) action;

  @override
  void initState() {
    super.initState();
    _archivedReceiptsBloc = BlocProvider.of<ArchivedReceiptsBloc>(context);
    _archivedReceiptsBloc.dispatch(GetArchiveMetaData());

    _preferencesRepository = widget._userRepository.preferencesRepository;
    var locale = _preferencesRepository.getPreferredLanguage();
    dateFormat = DateFormat.yMMMM(locale);
  }

  viewReceiptsAction(yearMonth) {
    Navigator.of(context)
        .push(MaterialPageRoute(
            builder: (context) => ArchivedReceiptsListPage(yearMonth)))
        .then((shouldReload) {
          // Future enhancement could be to not reload based on the value of shouldReload
          // Would require a away to restore old state when navigating back from list page
          _archivedReceiptsBloc.dispatch(GetArchiveMetaData());
    });
  }

  generateArchiveCards(
    Orientation orientation, ArchivedReceiptDataRange dataRange) {
    var yearMonths = dataRange.data.keys.toList();
    yearMonths.sort((a, b) {
      var yma = int.parse(a);
      var ymb = int.parse(b);
      if (yma == ymb) {
        return 0;
      }
      return yma > ymb ? -1 : 1;
    });

    var result = List<Widget>();

    for (var ym in yearMonths) {
      var year = int.parse(ym.substring(0, 4));
      var month = int.parse(ym.substring(4));
      var date = DateTime(year, month, 1);
      var count = dataRange.data[ym].length;

      var item = Container(
        constraints: BoxConstraints(maxHeight: 10),
        child: GestureDetector(
          onTap: () {
            viewReceiptsAction(ym);
          },
          child: Card(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Icon(Icons.library_books, size: 32),
                Text(
                  dateFormat.format(date),
                  style: TextStyle(fontSize: 20),
                ),
                Text(
                  '$count receipts',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      );

      result.add(item);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final Orientation orientation = MediaQuery.of(context).orientation;
    return Scaffold(
      appBar: AppBar(
        title: Text(allTranslations.text('app.archived-receipts-screen.title')),
      ),
      body: BlocBuilder(
          bloc: _archivedReceiptsBloc,
          builder: (BuildContext context, ArchivedReceiptsState state) {
            if (state is GetArchiveMetaDataSuccessState) {
              return OrientationBuilder(builder: (context, orientation) {
                return GridView.count(
                  padding: EdgeInsets.all(10),
                  primary: false,
                  childAspectRatio: 1.3,
                  crossAxisCount: orientation == Orientation.portrait ? 2 : 3,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  children: generateArchiveCards(orientation, state.dataRange),
                );
              });
            } else if (state is GetArchiveMetaDataFailState) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Card(
                        child: Text(allTranslations.text('app.archived-receipts-screen.fail-load')),
                      ),
                    ],
                  )
                ],
              );
            } else {
              // Loading Spinner
              return ArchiveLoadingSpinner();
            }
          }),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intelligent_receipt/data_model/setting_repository.dart';
import 'package:intelligent_receipt/translations/global_translations.dart';
import 'package:intelligent_receipt/user_repository.dart';

class CurrencyScreen extends StatefulWidget {
  final UserRepository _userRepository;
  final Currency defaultCurrency;
  CurrencyScreen({Key key, @required UserRepository userRepository, this.defaultCurrency})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(key: key) {}

  @override
  _CurrencyScreenState createState() => new _CurrencyScreenState();
}

class _CurrencyScreenState extends State<CurrencyScreen> {
  String get title => allTranslations.text('app.currency-screen.title');
  UserRepository get _userRepository => widget._userRepository;
  TextEditingController editingController = TextEditingController();
  List<Currency> duplicateItems;
  Currency selectedCurrency;
  bool show;

  var items = List<Currency>();

  @override
  void initState() {
    duplicateItems = _userRepository.settingRepository.getCurrencies();
    items.addAll(duplicateItems);
    selectedCurrency = widget.defaultCurrency;
    super.initState();
  }

  void filterSearchResults(String query) {
    List<Currency> dummySearchList = List<Currency>();
    dummySearchList.addAll(duplicateItems);
    if(query.isNotEmpty) {
      List<Currency> dummyListData = List<Currency>();
      dummySearchList.forEach((item) {
        if(item.name.toLowerCase().contains(query.toLowerCase())) {
          dummyListData.add(item);
        }
      });
      setState(() {
        items.clear();
        items.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        items.clear();
        items.addAll(duplicateItems);
      });
    }
  }

  Future<void> _setAsDefaultCurrency(int currencyId) async{
    await _userRepository.settingRepository.setDefaultCurrency(currencyId);
    setState(() {
      selectedCurrency = _userRepository
          .settingRepository
          .getDefaultCurrency();
    });
    Navigator.pop(context);
}

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(title),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onChanged: (value) {
                  filterSearchResults(value);
                },
                controller: editingController,
                decoration: InputDecoration(
                    labelText: allTranslations.text('words.search'),
                    hintText:  allTranslations.text('words.search'),
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(25.0)))),
              ),
            ),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('${items[index].name} ${items[index].symbol} ${items[index].country}'),
                    trailing: (items[index].id == selectedCurrency?.id) ?
                    Icon(Icons.check) : null,
                    onTap: () {
                      _setAsDefaultCurrency(items[index].id);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

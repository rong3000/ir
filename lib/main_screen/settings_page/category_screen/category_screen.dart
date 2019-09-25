import 'package:flutter/material.dart';
import 'package:intelligent_receipt/data_model/category_repository.dart';
import 'package:intelligent_receipt/data_model/data_result.dart';
import 'package:intelligent_receipt/data_model/setting_repository.dart';
import 'package:intelligent_receipt/user_repository.dart';

enum DialogDemoAction {
  cancel,
  discard,
  disagree,
  agree,
}

class CategoryScreen extends StatefulWidget {
  final String title;
  final UserRepository _userRepository;
  final Currency defaultCurrency;
  CategoryScreen(
      {Key key,
      @required UserRepository userRepository,
      this.title,
      this.defaultCurrency})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(key: key) {}

  @override
  _CategoryScreenState createState() => new _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  UserRepository get _userRepository => widget._userRepository;
  TextEditingController editingController = TextEditingController();
  List<Category> duplicateItems;
  Currency selectedCurrency;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  var items = List<Category>();

  @override
  void initState() {
    duplicateItems = _userRepository.categoryRepository.categories;
    items.addAll(duplicateItems);
    selectedCurrency = widget.defaultCurrency;
    super.initState();
  }

  void filterSearchResults(String query) {
    List<Category> dummySearchList = List<Category>();
    dummySearchList.addAll(duplicateItems);
    if (query.isNotEmpty) {
      List<Category> dummyListData = List<Category>();
      dummySearchList.forEach((item) {
        if (item.categoryName.toLowerCase().contains(query.toLowerCase())) {
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

  Future<void> _setAsDefaultCurrency(int currencyId) async {
    DataResult dataResult =
        await _userRepository.settingRepository.setDefaultCurrency(currencyId);
    setState(() {
      selectedCurrency = _userRepository.settingRepository.getDefaultCurrency();
    });
  }

  void showDemoDialog<T>({BuildContext context, Widget child}) {
    showDialog<T>(
      context: context,
      builder: (BuildContext context) => child,
    ).then<void>((T value) {
      // The value passed to Navigator.pop() or null.
      if (value != null) {
        _scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text('You selected: $value'),
        ));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle dialogTextStyle = theme.textTheme.subhead.copyWith(color: theme.textTheme.caption.color);
//    duplicateItems = _userRepository.settingRepository.getCurrencies();
    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: new Text(widget.title),
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
                    labelText: "Search",
                    hintText: "Search",
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
                    title: Text('${items[index].categoryName}'),
                    trailing: (items[index].id == selectedCurrency.id)
                        ? Icon(Icons.check)
                        : null,
                    onTap: () {
                      showDemoDialog<DialogDemoAction>(
                        context: context,
                        child: AlertDialog(
                          content: Text(
                            "Modify/Delete Category",
                            style: dialogTextStyle,
                          ),
                          actions: <Widget>[
                            FlatButton(
                              child: const Text('CANCEL'),
                              onPressed: () {
                                Navigator.pop(context, DialogDemoAction.cancel);
                              },
                            ),
                            FlatButton(
                              child: const Text('DISCARD'),
                              onPressed: () {
                                Navigator.pop(
                                    context, DialogDemoAction.discard);
                              },
                            ),
                          ],
                        ),
                      );
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

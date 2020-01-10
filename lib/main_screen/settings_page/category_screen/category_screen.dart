import 'package:flutter/material.dart';
import 'package:intelligent_receipt/data_model/category_repository.dart';
import 'package:intelligent_receipt/data_model/data_result.dart';
import 'package:intelligent_receipt/data_model/setting_repository.dart';
import 'package:intelligent_receipt/translations/global_translations.dart';
import 'package:intelligent_receipt/user_repository.dart';

enum DialogDemoAction {
  cancel,
  rename,
  delete,
  discard,
  disagree,
  agree,
}

class CategoryScreen extends StatefulWidget {
  String get title => allTranslations.text('app.category-screen.title');
  final UserRepository _userRepository;
  final Currency defaultCurrency;
  CategoryScreen(
      {Key key,
      @required UserRepository userRepository,
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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController _textFieldController = TextEditingController();

  var items = List<Category>();

  @override
  void initState() {
    duplicateItems = _userRepository.categoryRepository.categories;
    items.addAll(duplicateItems);
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

  Future<void> _updateCategory(Category category) async {
    DataResult dataResult =
        await _userRepository.categoryRepository.updateCategory(category);
    setState(() {
      items.clear();
      items.addAll(duplicateItems);
      editingController.clear();
    });
  }

  Future<void> _deleteCategory(int categoryId) async {
    DataResult dataResult =
        await _userRepository.categoryRepository.deleteCategory(categoryId);
    setState(() {
      items.clear();
      items.addAll(duplicateItems);
      editingController.clear();
    });
  }

  Future<void> _addCategory(String categoryName) async {
    DataResult dataResult =
        await _userRepository.categoryRepository.addCategory(categoryName);
    setState(() {
      items.clear();
      items.addAll(duplicateItems);
    });
  }

  void showDemoDialog<T>({BuildContext context, Widget child}) {
    showDialog<T>(
      context: context,
      builder: (BuildContext context) => child,
    ).then<void>((T value) {
      // The value passed to Navigator.pop() or null.
      if (value != null) {
//        _scaffoldKey.currentState.showSnackBar(SnackBar(
//          content: Text('You selected: $value'),
//        ));
      }
    });
  }

  void _showInSnackBar(String value, {IconData icon: Icons.error, color: Colors.red}) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [Text(value), Icon(icon)],
      ),
      backgroundColor: color,
    ));
  }

  Future<void> _refreshCategories() async {
    DataResult result = await _userRepository.categoryRepository.getCategoriesFromServer(forceRefresh: true);
    if (result.success) {
      setState(() {
        duplicateItems = _userRepository.categoryRepository.categories;
        items.addAll(duplicateItems);
      });
    } else {
      _showInSnackBar("${result.messageCode}:${result.message}");
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle dialogTextStyle =
        theme.textTheme.subhead.copyWith(color: theme.textTheme.caption.color);
    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: Row(
          children: <Widget>[
            new Text(widget.title),
            SizedBox(
                width: 60,
                child: FlatButton(
                  onPressed: () {
                    _textFieldController.text = '';
                    showDemoDialog<DialogDemoAction>(
                      context: context,
                      child: AlertDialog(
                        title: Text(
                          allTranslations.text('app.category-screen.add-dialog-title'),
                          style: dialogTextStyle,
                        ),
                        content: TextField(
                          controller: _textFieldController,
                        ),
                        actions: <Widget>[
                          FlatButton(
                            child: Text(allTranslations.text('words.cancel')),
                            onPressed: () {
                              Navigator.pop(context, DialogDemoAction.cancel);
                            },
                          ),
                          FlatButton(
                            child: Text(allTranslations.text('words.add')),
                            onPressed: () {
                              _addCategory(_textFieldController.text);
                              Navigator.pop(context, DialogDemoAction.rename);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                  child: Icon(Icons.add),
                )),
            SizedBox(
                width: 60,
                child: FlatButton(
                  onPressed: () {
                    _textFieldController.text = '';
                    _refreshCategories();
                  },
                  child: Icon(Icons.refresh),
                )),
          ],
        ),
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
                    labelText: allTranslations.text('app.category-screen.search-label'),
                    hintText: allTranslations.text('app.category-screen.search-label'),
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
                    onTap: () {
                      _textFieldController.text =
                          '${items[index].categoryName}';
                      showDemoDialog<DialogDemoAction>(
                        context: context,
                        child: AlertDialog(
                          title: Text(
                            allTranslations.text('app.category-screen.modify-alert-title'),
                            style: dialogTextStyle,
                          ),
                          content: TextField(
                            controller: _textFieldController,
//                            decoration: InputDecoration(hintText: '${items[index].categoryName}'),
                          ),
                          actions: <Widget>[
                            FlatButton(
                              child: Text(allTranslations.text('words.cancel')),
                              onPressed: () {
                                Navigator.pop(context, DialogDemoAction.cancel);
                              },
                            ),
                            FlatButton(
                              child: Text(allTranslations.text('words.rename')),
                              onPressed: () {
                                items[index].categoryName =
                                    _textFieldController.text;
                                _updateCategory(items[index]);
                                Navigator.pop(context, DialogDemoAction.rename);
                              },
                            ),
                            FlatButton(
                              child: Text(allTranslations.text('words.delete')),
                              onPressed: () {
                                _deleteCategory(items[index].id);
                                Navigator.pop(context, DialogDemoAction.delete);
                                editingController.text == '';
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

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intelligent_receipt/data_model/preferences/preferences_repository.dart';
import 'package:intelligent_receipt/main_screen/settings_page/preferences/bloc/preferences_bloc.dart';
import 'package:intelligent_receipt/main_screen/settings_page/preferences/bloc/preferences_event.dart';
import 'package:intelligent_receipt/main_screen/settings_page/preferences/bloc/preferences_state.dart';
import 'package:intelligent_receipt/translations/global_translations.dart';
import 'package:intelligent_receipt/user_repository.dart';
import 'package:intelligent_receipt/data_model/setting_repository.dart';

class PreferencesScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _PreferencesScreenState();
  }
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  final _taxPercentageFormKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  PreferencesRepository _prefsRepository;
  PreferencesBloc _prefsBloc;
  String selectedLanguage;
  String get pageTitle => allTranslations.text('app.preferences-page.title');
  String get languageDropDownLabel => allTranslations.text('app.preferences-page.language-dropdown-label');
  UserRepository _userRepository;
  bool _taxInclusive = true;
  double _taxPercentage = 10;

  @override
  void initState() {
    _userRepository = RepositoryProvider.of<UserRepository>(context);
    _prefsRepository = RepositoryProvider.of<UserRepository>(context).preferencesRepository;
    _prefsBloc = BlocProvider.of<PreferencesBloc>(context);
    selectedLanguage = getDefaultLanguage();
    _taxInclusive = _userRepository.settingRepository.isTaxInclusive();
    _taxPercentage = _userRepository.settingRepository.getTaxPercentage();

    if (!_userRepository.settingRepository.isDataFetched()) {
      _userRepository.settingRepository.getSettingsFromServer().then((onValue) {
        setState(() {
          _taxInclusive = _userRepository.settingRepository.isTaxInclusive();
          _taxPercentage = _userRepository.settingRepository.getTaxPercentage();
        });
      });
    }

    super.initState();
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

  List<DropdownMenuItem> getLanguageChoices() {
    var supportedLanguages = _prefsRepository.getSupportedLanguages();
    var items = List<DropdownMenuItem>();
    supportedLanguages.forEach((key, value) {
      items.add(DropdownMenuItem(value: key, child: Text(value)));
    });

    return items;
  }

  String getDefaultLanguage() {
    return _prefsRepository.getPreferredLanguage();
  }

  Future<void> _saveTaxInclusive(bool isTaxInclusive) async {
    if (isTaxInclusive == _taxInclusive) {
      return;
    }

    DataResult result = await _userRepository.settingRepository.setTaxInclusive(isTaxInclusive);
    if (result.success) {
      _showInSnackBar(allTranslations.text('app.preferences-page.tax-inclusive-saved-success'), icon: Icons.info, color: Colors.blue);
      setState(() {
        _taxInclusive = isTaxInclusive;
      });
    } else {
      _showInSnackBar(allTranslations.text('app.preferences-page.tax-inclusive-saved-fail') + result.message);
    }
  }

  Future<void> _saveTaxPercentage() async {
    double taxPercentage = _userRepository.settingRepository.getTaxPercentage();
    if (taxPercentage == _taxPercentage) {
      return;
    }

    DataResult result = await _userRepository.settingRepository.setTaxPercentage(_taxPercentage);
    if (result.success) {
      _showInSnackBar(allTranslations.text('app.preferences-page.tax-percentage-saved-success'), icon: Icons.info, color: Colors.blue);
    } else {
      _showInSnackBar(allTranslations.text('app.preferences-page.tax-percentage-saved-fail') + result.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: _prefsBloc,
      builder: (BuildContext context, PreferencesState state) {
        return Scaffold(
          key: _scaffoldKey,
          appBar: AppBar(
            title: Text(pageTitle),
          ),
          body: Padding(
            padding: EdgeInsets.all(8),
            child: Column(
              children: <Widget>[
                DropdownButtonFormField(
                  decoration: InputDecoration(labelText: languageDropDownLabel),
                  items: getLanguageChoices(),
                  value: state.language,
                  onChanged: (newValue) {
                    _prefsBloc.dispatch(LanguageChanged(preferredLanguage: newValue));
                  },
                ),
                Form(
                  key: _taxPercentageFormKey,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Flexible(
                        flex: 6,
                        child: Padding(
                          padding: EdgeInsets.only(top: 5),
                          child: TextFormField(
                            decoration: InputDecoration(labelText: allTranslations.text('app.preferences-page.tax-percentage-label')),
                            initialValue: _taxPercentage.toString(),
                            validator: (String value) {
                              double taxPercentage = double.tryParse(value);
                              if (taxPercentage < 0 || taxPercentage > 100) {
                                return allTranslations.text('app.preferences-page.tax-percentage-range');
                              }
                              return null;
                            },
                            onChanged: (String value) {
                              _taxPercentage = double.tryParse(value);
                            },
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 4,
                        child: IconButton(
                          icon: const Icon(Icons.save),
                          color: Colors.blue,
                          onPressed: () {
                            if (!this._taxPercentageFormKey.currentState.validate()) {
                              return;
                            }
                            _saveTaxPercentage();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                SwitchListTile(
                  title: Text(allTranslations.text('app.preferences-page.tax-inclusive-lable')),
                  value: _taxInclusive,
                  onChanged: (bool value) { _saveTaxInclusive(value); },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intelligent_receipt/data_model/preferences/preferences_repository.dart';
import 'package:intelligent_receipt/main_screen/settings_page/preferences/bloc/preferences_bloc.dart';
import 'package:intelligent_receipt/main_screen/settings_page/preferences/bloc/preferences_state.dart';
import 'package:intelligent_receipt/translations/global_translations.dart';
import 'package:intelligent_receipt/user_repository.dart';

class PreferencesScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _PreferencesScreenState();
  }
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  PreferencesRepository _prefsRepository;
  PreferencesBloc _prefsBloc;
  String selectedLanguage;
  String pageTitle = allTranslations.text('app.preferences-page.title');

  @override
  void initState() {
    _prefsRepository =
        RepositoryProvider.of<UserRepository>(context).preferencesRepository;
    _prefsBloc = BlocProvider.of<PreferencesBloc>(context);
    selectedLanguage = getDefaultLanguage();
    super.initState();
  }

  List<DropdownMenuItem> getLanguageChoices(){
    var supportedLanguages = _prefsRepository.getSupportedLanguages();
    var items = List<DropdownMenuItem>();
    supportedLanguages.forEach((key, value){
      items.add(DropdownMenuItem(value: key, child: Text(value)));
    });

    return items;
  }

  String getDefaultLanguage(){
    return _prefsRepository.getDefaultLanguage();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: _prefsBloc,
      builder: (BuildContext context, PreferencesState state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(pageTitle),
          ),
          body: Column(
            children: <Widget>[
              DropdownButtonFormField(
                items: getLanguageChoices(),
                value: selectedLanguage,
                onChanged: (newValue) {
                  setState(() {
                    selectedLanguage = newValue;
                  });
                },)
            ],
          ),
        );
      },
    );
  }
}

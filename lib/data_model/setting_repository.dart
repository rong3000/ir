import "currency.dart";
import "setting.dart";
import "webservice.dart";
import "package:intelligent_receipt/user_repository.dart";
import 'package:synchronized/synchronized.dart';

export 'currency.dart';

class SettingRepository {
  List<Currency> _currencies;
  List<Setting> _generalSettings;
  final UserRepository _userRepository;
  Lock _lockCurrencies = new Lock();
  Lock _lockSettings = new Lock();

  SettingRepository(UserRepository userRepository)
      : _userRepository = userRepository {
    _currencies = new List<Currency>();
    _generalSettings = new List<Setting>();
  }

  List<Currency> getCurrencies() {
    List<Currency> currencies = new List<Currency>();
    _lockCurrencies.synchronized(() {
      currencies = _currencies;
    });
    return currencies;
  }

  Currency getDefaultCurrency() {
    String currencyId = _getSettingValue(Setting_DefaultCurrency);
    var currId = int.tryParse(currencyId);
    return  _getCurrencyById(currId);
  }

  Future<DataResult> setDefaultCurrency(int currencyId) {
    return _addOrUpdateSystemSetting(Setting_DefaultCurrency, currencyId.toString());
  }

  Future<DataResult> getCurrenciesFromServer() async {
    DataResult result = new DataResult(false, "Unknown");
    await _lockCurrencies.synchronized(() async {
      if ((_userRepository == null) || (_userRepository.userId <= 0)) {
        // Log an error
        result = DataResult.fail();
      }

      result = await webserviceGet(
          Urls.GetCurrencies, "",
          timeout: 3000);
      if (result.success) {
        Iterable l = result.obj;
        _currencies = l.map((model) => Currency.fromJason(model)).toList();
        result.obj = _currencies;
      }
    });

    return result;
  }

  Future<DataResult> getSettingsFromServer() async {
    DataResult result = new DataResult(false, "Unknown");
    await _lockSettings.synchronized(() async {
      if ((_userRepository == null) || (_userRepository.userId <= 0)) {
        // Log an error
        result = DataResult.fail();
      }

      result = await webserviceGet(
          Urls.GetSystemSettings + _userRepository.userId.toString(), "",
          timeout: 3000);
      if (result.success) {
        Iterable l = result.obj;
        _generalSettings = l.map((model) => Setting.fromJason(model)).toList();
        result.obj = _generalSettings;
      }
    });

    return result;
  }

  Currency _getCurrencyById(int currencyId) {
    Currency currency = null;
    _lockCurrencies.synchronized(() {
      for (int i = 0; i < _currencies.length; i++) {
        if (_currencies[i].id == currencyId) {
          currency = _currencies[i];
          break;
        }
      }
    });
    return currency;
  }

  String _getSettingValue(String settingKey) {
    String value = "";
    _lockSettings.synchronized(() {
      for (int i = 0; i < _generalSettings.length; i++) {
        if (_generalSettings[i].key == settingKey) {
          value = _generalSettings[i].value;
          break;
        }
      }
    });
    return value;
  }

  Future<DataResult> _addOrUpdateSystemSetting(String key, String value) async {
    DataResult result = await webservicePost(Urls.AddOrUpdateSystemSetting + _userRepository.userId.toString() + "/" + Uri.encodeComponent(key) + "/" + Uri.encodeComponent(value), "", "");
    if (result.success) {
      Setting setting = Setting.fromJason(result.obj);
      result.obj = setting;

      // update local cache
      _lockSettings.synchronized(() {
        bool existing = false;
        for (int i = 0; i < _generalSettings.length; i++) {
          if (_generalSettings[i].key == setting.key) {
            _generalSettings[i] = setting;
            existing = true;
            break;
          }
        }

        if (!existing) {
          _generalSettings.add(setting);
        }
      });
    }

    return result;
  }

  static String Setting_DefaultCurrency = "DefaultCurrency";
}
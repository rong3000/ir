import 'package:intelligent_receipt/data_model/ir_repository.dart';

import "currency.dart";
import "setting.dart";
import "webservice.dart";
import "package:intelligent_receipt/user_repository.dart";
import 'package:synchronized/synchronized.dart';

export 'currency.dart';
export 'data_result.dart';

class SettingRepository extends IRRepository {
  bool _dataFetched = false;
  List<Currency> _currencies;
  List<Setting> _generalSettings;
  Lock _lockCurrencies = new Lock();
  Lock _lockSettings = new Lock();

  SettingRepository(UserRepository userRepository) : super (userRepository) {
    _currencies = new List<Currency>();
    _generalSettings = new List<Setting>();
  }

  bool isDataFetched() {
    return _dataFetched;
  }

  List<Currency> getCurrencies() {
    List<Currency> currencies = new List<Currency>();
    _lockCurrencies.synchronized(() {
      currencies = _currencies;
    });
    return currencies;
  }

  Currency getCurrencyForCurrencyCode(String currencyCode) {
    if (currencyCode == null) {
      return null;
    }

    Currency currency;
    _lockCurrencies.synchronized(() {
      for (int i = 0; i < _currencies.length; i++) {
        if (_currencies[i].code == currencyCode) {
          currency = _currencies[i];
          break;
        }
      }
    });
    return currency;
  }

  Currency getDefaultCurrency() {
    String currencyId = _getSettingValue(Setting_DefaultCurrency);
    var currId = int.tryParse(currencyId);
    return  _getCurrencyById(currId);
  }

  Future<DataResult> setDefaultCurrency(int currencyId) {
    return _addOrUpdateSystemSetting(Setting_DefaultCurrency, currencyId.toString());
  }

  bool isTaxInclusive() {
    String taxInclusiveStr = _getSettingValue(Setting_IsTaxInclusive);
    bool isTaxInclusive = true;
    if (taxInclusiveStr.isNotEmpty) {
      isTaxInclusive = (taxInclusiveStr == "1") ? true : false;
    }
    return isTaxInclusive;
  }

  Future<DataResult> setTaxInclusive(bool isTaxInclusive) {
    return _addOrUpdateSystemSetting(Setting_IsTaxInclusive, isTaxInclusive ? "1" : "0");
  }

  double getTaxPercentage() {
    String taxPercentageStr = _getSettingValue(Setting_TaxPercentage);
    return taxPercentageStr.isNotEmpty ? double.tryParse(taxPercentageStr) : 10;
  }

  Future<DataResult> setTaxPercentage(double taxPercentage) {
    return _addOrUpdateSystemSetting(Setting_TaxPercentage, taxPercentage.toString());
  }

  Future<DataResult> getCurrenciesFromServer({bool forceRefresh : false}) async {
    DataResult result = new DataResult(false, "Unknown");
    await _lockCurrencies.synchronized(() async {
      if (_dataFetched && !forceRefresh) {
        result = DataResult.success(_currencies);
      } else if ((userRepository == null) || (userRepository.userGuid == null)) {
        // Log an error
        result = DataResult.fail();
      } else {
        result = await webserviceGet(
            Urls.GetCurrencies, await getToken(),
            timeout: 5000);
        if (result.success) {
          Iterable l = result.obj;
          _currencies = l.map((model) => Currency.fromJason(model)).toList();
          result.obj = _currencies;
          _dataFetched = true;
        }
      }
    });

    return result;
  }

  Future<DataResult> getSettingsFromServer() async {
    DataResult result = new DataResult(false, "Unknown");
    await _lockSettings.synchronized(() async {
      if ((userRepository == null) || (userRepository.userGuid == null)) {
        // Log an error
        result = DataResult.fail();
      }

      result = await webserviceGet(
          Urls.GetSystemSettings, 
          await getToken(),
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
    Currency currency;
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
    DataResult result = await webservicePost(Urls.AddOrUpdateSystemSetting + Uri.encodeComponent(key) + "/" + Uri.encodeComponent(value), await getToken(), "");
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
  static String Setting_IsTaxInclusive = "IsTaxInclusive";
  static String Setting_TaxPercentage = "TaxPercentage";
}
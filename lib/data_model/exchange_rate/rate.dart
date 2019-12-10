import 'package:json_annotation/json_annotation.dart';
part 'rate.g.dart';

@JsonSerializable()
class Rate {
  double CAD;
  double HKD;
  double LVL;
  double PHP;
  double DKK;
  double HUF;
  double CZK;
  double AUD;
  double RON;
  double SEK;
  double IDR;
  double INR;
  double BRL;
  double RUB;
  double LTL;
  double JPY;
  double THB;
  double CHF;
  double SGD;
  double PLN;
  double BGN;
  double TRY;
  double CNY;
  double NOK;
  double NZD;
  double ZAR;
  double USD;
  double MXN;
  double EEK;
  double GBP;
  double KRW;
  double MYR;
  double HRK;
  double EUR;

  Rate(
      {this.CAD,
      this.HKD,
      this.LVL,
      this.PHP,
      this.DKK,
      this.HUF,
      this.CZK,
      this.AUD,
      this.RON,
      this.SEK,
      this.IDR,
      this.INR,
      this.BRL,
      this.RUB,
      this.LTL,
      this.JPY,
      this.THB,
      this.CHF,
      this.SGD,
      this.PLN,
      this.BGN,
      this.TRY,
      this.CNY,
      this.NOK,
      this.NZD,
      this.ZAR,
      this.USD,
      this.MXN,
      this.EEK,
      this.GBP,
      this.KRW,
      this.MYR,
      this.HRK,
      this.EUR});

  double getRate(String currentCode) {
    double rate;
    switch (currentCode) {
      case 'CAD':
        return rate = this.CAD;
      case 'HKD':
        return rate = this.HKD;
      case 'LVL':
        return rate = this.LVL;
      case 'PHP':
        return rate = this.PHP;
      case 'DKK':
        return rate = this.DKK;
      case 'HUF':
        return rate = this.HUF;
      case 'CZK':
        return rate = this.CZK;
      case 'AUD':
        return rate = this.AUD;
      case 'RON':
        return rate = this.RON;
      case 'SEK':
        return rate = this.SEK;
      case 'IDR':
        return rate = this.IDR;
      case 'INR':
        return rate = this.INR;
      case 'BRL':
        return rate = this.BRL;
      case 'RUB':
        return rate = this.RUB;
      case 'LTL':
        return rate = this.LTL;
      case 'JPY':
        return rate = this.JPY;
      case 'THB':
        return rate = this.THB;
      case 'CHF':
        return rate = this.CHF;
      case 'SGD':
        return rate = this.SGD;
      case 'PLN':
        return rate = this.PLN;
      case 'BGN':
        return rate = this.BGN;
      case 'TRY':
        return rate = this.TRY;
      case 'CNY':
        return rate = this.CNY;
      case 'NOK':
        return rate = this.NOK;
      case 'NZD':
        return rate = this.NZD;
      case 'ZAR':
        return rate = this.ZAR;
      case 'USD':
        return rate = this.USD;
      case 'MXN':
        return rate = this.MXN;
      case 'EEK':
        return rate = this.EEK;
      case 'GBP':
        return rate = this.GBP;
      case 'KRW':
        return rate = this.KRW;
      case 'MYR':
        return rate = this.MYR;
      case 'HRK':
        return rate = this.HRK;
      case 'EUR':
        return rate = this.EUR;
      default:
        break;
    }
  }

  factory Rate.fromJson(Map<String, dynamic> json) => _$RateFromJson(json);

  Map<String, dynamic> toJson() => _$RateToJson(this);
}

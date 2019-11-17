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
        this.HRK});

  double getRate(String currentCode) {
    double rate;
    switch(currentCode) {
      case 'CAD':
        return rate = this.CAD;
      case 'USD':
        return rate = this.USD;
      default:
        break;
    }
  }

  factory Rate.fromJson(Map<String, dynamic> json) => _$RateFromJson(json);

  Map<String, dynamic> toJson() => _$RateToJson(this);
}
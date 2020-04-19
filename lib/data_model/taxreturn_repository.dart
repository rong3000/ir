import 'package:intelligent_receipt/data_model/ir_repository.dart';
import 'taxreturn.dart';
import "../user_repository.dart";
import 'package:synchronized/synchronized.dart';
import "webservice.dart";
import "report.dart";

class TaxReturnRepository extends IRRepository {
  List<TaxReturn> taxReturns = new List<TaxReturn>();
  Lock _lock = new Lock();
  bool _dataFetched = false;
  TaxReturnRepository(UserRepository userRepository) : super(userRepository);

  Future<DataResult> getTaxReturns() async {
    DataResult result = new DataResult(false, "Unknown");
    await _lock.synchronized(() async {
      if (_dataFetched) {
        result = DataResult.success(taxReturns);
      } else if ((userRepository == null) || (userRepository.userGuid == null)) {
        // Log an error
        result = DataResult.fail();
      } else {
        result = await webserviceGet(Urls.GetTaxReturns, await getToken(), timeout: 5000);
        if (result.success) {
          Iterable l = result.obj;
          taxReturns = l.map((model) => TaxReturn.fromJson(model)).toList();
          result.obj = taxReturns;
        }
      }

      _dataFetched = result.success;
    });

    return result;
  }

  // Don't cache tax return data for this specific year
  Future<DataResult> getTaxReturn(int year) async {
    DataResult result = await webserviceGet(Urls.GetTaxReturnByYear + year.toString(), await getToken(), timeout: 5000);
    if (result.success) {
      TaxReturn taxReturn = TaxReturn.fromJson(result.obj);
      result.obj = taxReturn;
    }

    return result;
  }

  void updateReport(Report report) {
    for (int i = 0; i< taxReturns.length; i++) {
      for (int j = 0; j< taxReturns[i].receiptGroups.length; j++) {
        if (report.taxReturnGroupId == taxReturns[i].receiptGroups[j].taxReturnGroupId) {
          taxReturns[i].receiptGroups[j] = report;
        }
      }

    }

  }
}
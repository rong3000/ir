import "receipt.dart";
import "webservice.dart";
import "../user_repository.dart";
import "package:quiver/strings.dart";
import 'dart:convert';

class DataRepository {
  List<ReceiptCommon> receipts;
  UserRepository _userRepository;
  String _uID;

  DataRepository(UserRepository userRepository) {
    _userRepository = userRepository;
  }

  Future<List<ReceiptCommon>> GetReceiptsFromServer() async {
    if ((_userRepository == null) || (isEmpty(_userRepository.uid)))
    {
      // Log an error
      return new List<ReceiptCommon>();
    }

    WebServiceResult result = await webserviceGet(Urls.GetReceipts + _userRepository.uid, "");
    if (result.success) {
      Iterable l = json.decode(result.response);
      receipts = l.map((model) => ReceiptCommon.fromJason(model)).toList();
    }

    return receipts;
  }
}
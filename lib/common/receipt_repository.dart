import "receipt.dart";
import "webservice.dart";
import "../user_repository.dart";
import "package:quiver/strings.dart";
import 'dart:convert';

class ReceiptRepository {
  List<ReceiptListItem> receipts;
  UserRepository _userRepository;
  bool _dataFetched = false;

  ReceiptRepository(UserRepository userRepository) {
    _userRepository = userRepository;
  }

  Future<bool> GetReceiptsFromServer({bool forceRefresh = false}) async {
    if (_dataFetched && !forceRefresh) {
      return true;
    }

    if ((_userRepository == null) || (_userRepository.userId <= 0))
    {
      // Log an error
      return false;
    }

    WebServiceResult result = await webserviceGet(Urls.GetReceipts + _userRepository.userId.toString(), "");
    if (result.success) {
      Iterable l = result.jasonObj;
      receipts = l.map((model) => ReceiptListItem.fromJason(model)).toList();
    }

    _dataFetched = result.success;
    return result.success;
  }
}
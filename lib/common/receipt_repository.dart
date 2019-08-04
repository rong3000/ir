import "receipt.dart";
import "webservice.dart";
import "../user_repository.dart";
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ReceiptRepository {
  List<ReceiptListItem> receipts;
  UserRepository _userRepository;
  bool _dataFetched = false;

  ReceiptRepository(UserRepository userRepository) {
    _userRepository = userRepository;
  }

  List<ReceiptListItem> getReceiptItems(ReceeiptStatusType receiptStatus) {
    List<ReceiptListItem> selectedReceipts = new List<ReceiptListItem>();
    for (var i = 0; i < receipts.length; i++) {
      if (receipts[i].statusId == receiptStatus) {
        selectedReceipts.add(receipts[i]);
      }
    }
    return selectedReceipts;
  }

  int getReceiptItemsCount(ReceeiptStatusType receiptStatus) {
    int receiptCount = 0;
    for (var i = 0; i < receipts.length; i++) {
      if (receipts[i].statusId == receiptStatus) {
        receiptCount++;
      }
    }
    return receiptCount;
  }

  Future<bool> getReceiptsFromServer({bool forceRefresh = false}) async {
    //var image = await ImagePicker.pickImage(source: ImageSource.camera);
    //await this.uploadReceiptFile(image);
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

  Future<bool> uploadReceiptFile(File imageFile) async {
    if ((_userRepository == null) || (_userRepository.userId <= 0))
    {
      // Log an error
      return false;
    }

    WebServiceResult result = await uploadFile(Urls.UploadReceiptImages + _userRepository.userId.toString(), "", imageFile);
    if (result.success) {
      var jasonObj = result.jasonObj;
      //receipts = l.map((model) => ReceiptListItem.fromJason(model)).toList();
    }

    return result.success;
  }


}
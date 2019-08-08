import "receipt.dart";
import "webservice.dart";
import "../user_repository.dart";
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import "enums.dart";
export "receipt.dart";

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
      if (receipts[i].statusId == receiptStatus.index) {
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

  Future<Receipt> getReceipt(int receiptId) async {
    Receipt receipt = null;
    WebServiceResult result = await webserviceGet(Urls.GetReceipt + receiptId.toString(), "");
    if (result.success) {
      receipt = Receipt.fromJason(result.jasonObj);
    }

    return receipt;
  }

  Future<Receipt> updateReceipt(Receipt receipt) async {
    Receipt newReceipt = null;
    WebServiceResult result = await webservicePost(Urls.UpdateReceipt, "", jsonEncode(receipt));
    if (result.success) {
      newReceipt = Receipt.fromJason(result.jasonObj);
    }

    return newReceipt;
  }

  Future<Receipt> uploadReceiptImage(File imageFile) async {
    if ((_userRepository == null) || (_userRepository.userId <= 0))
    {
      // Log an error
      return null;
    }

    WebServiceResult result = await uploadFile(Urls.UploadReceiptImages + _userRepository.userId.toString(), "", imageFile);
    if (result.success) {
      Iterable l = result.jasonObj;
      List<Receipt> newReceipts = l.map((model) => Receipt.fromJason(model)).toList();
      if (newReceipts.length > 0) {
        Receipt receipt = newReceipts[0];
        // insert the new receipt into the receipt list
        receipts.add(receipt);
        return receipt;
      } else {
        return null;
      }
    }

    return null;
  }

  Future<bool> deleteReceipts(List<int> receiptIds) async {
    WebServiceResult result = await webservicePost(Urls.DeleteReceipts, "", jsonEncode(receiptIds));
    if (result.success) {
      // Delete the local cache of the receipts
      for (int i = 0; i < receiptIds.length; i++) {
        for (int j = 0; j < receipts.length; j++) {
          if (receipts[j].id == receiptIds[i]) {
            receipts.removeAt(j);
            break;
          }
        }
      }
    }

    return result.success;
  }
}
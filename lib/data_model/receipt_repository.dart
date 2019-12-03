import 'package:flutter/widgets.dart';
import 'package:intelligent_receipt/data_model/ir_repository.dart';
import "receipt.dart";
import 'report_repository.dart';
import "webservice.dart";
import "../user_repository.dart";
import 'dart:io';
import 'dart:convert';
import "enums.dart";
import 'package:synchronized/synchronized.dart';
export "receipt.dart";
export 'data_result.dart';
export 'enums.dart';
import 'message_code.dart';

class amountPair {
  double amount;
  int id;

  amountPair({this.amount, this.id});
}
class ReceiptRepository extends IRRepository {
  List<ReceiptListItem> receipts = new List<ReceiptListItem>();
  List<ReceiptListItem> selectedReceipts = new List<ReceiptListItem>();
  List<ReceiptListItem> cachedReceiptItems;
  List<amountPair> cachedReceiptItemsAmount;
  List<ReceiptListItem> candidateReceiptItems;
  bool _dataFetched = false;
  Lock _lock = new Lock();

  void resetCachedReceiptItems(ReportRepository reportRepository, {int reportID = 0}) {
    cachedReceiptItems = [];
    cachedReceiptItemsAmount = [];
    candidateReceiptItems = [];
    candidateReceiptItems = getReceiptItems(ReceiptStatusType.Reviewed);
    var _receiptsInReportSet = new Set<ReceiptListItem>();
    var _candidateReceiptsSet = new Set<ReceiptListItem>();

    // Only filter out the receipts in the specified report
    for (var i = 0; i < reportRepository.reports.length; i++ ) {
      if (reportRepository.reports[i].id == reportID) {
        _receiptsInReportSet.addAll(
            reportRepository.reports[i].getReceiptList(this));
      }
    }

    _candidateReceiptsSet.addAll(candidateReceiptItems);
    candidateReceiptItems = _candidateReceiptsSet.difference(_receiptsInReportSet).toList();
  }

  List<ReceiptListItem> removeCandidateItems(int id) {
    candidateReceiptItems.removeWhere((ReceiptListItem item){
      return item.id == id;
    });
    return candidateReceiptItems;
  }

  ReceiptRepository(UserRepository userRepository) : super(userRepository);

  ReceiptListItem getReceiptItem(int receiptId) {
    ReceiptListItem receiptListItem;
    for (var i = 0; i < receipts.length; i++) {
      if (receipts[i].id == receiptId) {
        receiptListItem = receipts[i];
        break;
      }
    }
    return receiptListItem;
  }

  List<ReceiptListItem> getReceiptItems(ReceiptStatusType receiptStatus) {
    List<ReceiptListItem> selectedReceipts = new List<ReceiptListItem>();
    _lock.synchronized(() {
      for (var i = 0; i < receipts.length; i++) {
        if (receipts[i].statusId == receiptStatus.index) {
          selectedReceipts.add(receipts[i]);
        }
      }
    });
    return selectedReceipts;
  }

  List<ReceiptListItem> getReceiptItemsByRange(
      ReceiptStatusType receiptStatus, int start, int end) {
    List<ReceiptListItem> selectedReceipts = new List<ReceiptListItem>();
    _lock.synchronized(() {
      for (var i = 0; i < receipts.length; i++) {
        if (receipts[i].statusId == receiptStatus.index) {
          selectedReceipts.add(receipts[i]);
        }
      }
    });
    return selectedReceipts.getRange(start, end).toList();
  }

  int getReceiptItemsCount(ReceiptStatusType receiptStatus) {
    int receiptCount = 0;
    _lock.synchronized(() {
      for (var i = 0; i < receipts.length; i++) {
        if (receipts[i].statusId == receiptStatus.index) {
          receiptCount++;
        }
      }
    });
    return receiptCount;
  }

  Future<DataResult> getReceiptsFromServer({bool forceRefresh = false}) async {
    //var image = await ImagePicker.pickImage(source: ImageSource.camera);
    //await this.uploadReceiptFile(image);
    DataResult result = new DataResult(false, "Unknown");
    await _lock.synchronized(() async {
      if (_dataFetched && !forceRefresh) {
        result = DataResult.success(receipts);
      } else if ((userRepository == null) || (userRepository.userGuid == null)) {
        // Log an error
        result = DataResult.fail();
      } else {
        result = await webserviceGet(Urls.GetReceipts, await getToken(), timeout: 5000);
        if (result.success) {
          Iterable l = result.obj;
          receipts = l.map((model) => ReceiptListItem.fromJason(model)).toList();
          result.obj = receipts;
        }
      }

      _dataFetched = result.success;
    });

    return result;
  }

  Future<DataResult> getReceipt(int receiptId) async {
    DataResult result =
        await webserviceGet(Urls.GetReceipt + receiptId.toString(), await getToken());
    if (result.success) {
      result.obj = Receipt.fromJason(result.obj);
    }

    return result;
  }

  Future<DataResult> updateReceipt(Receipt receipt) async {
    DataResult result =
        await webservicePost(Urls.UpdateReceipt, await getToken(), jsonEncode(receipt));
    if (result.success) {
      Receipt newReceipt = Receipt.fromJason(result.obj);
      _lock.synchronized(() {
        // update local cache
        for (int j = 0; j < receipts.length; j++) {
          if (receipts[j].id == newReceipt.id) {
            receipts[j] = newReceipt;
            break;
          }
        }
      });
    }

    return result;
  }
  
  Future<DataResult> addReceipts(List<Receipt> newReceipts) async {
    DataResult result =
        await webservicePost(Urls.AddReceipts, await getToken(), jsonEncode(newReceipts));
    if (result.success) {
      Iterable l = result.obj;
      var addedReceipts = l.map((model) => ReceiptListItem.fromJason(model)).toList();
      for (var receipt in addedReceipts){
        _lock.synchronized(() {
          receipts.add(receipt);
        });
      }
    }

    return result;
  }

  Future<DataResult> uploadReceiptImage(File imageFile, {receiptTypeId = 1}) async {
    if ((userRepository == null) || (userRepository.userGuid == null)) {
      // Log an error
      return DataResult.fail(msg: "No user logged in.");
    }

    var url = Urls.UploadReceiptImages + receiptTypeId.toString() + "/";
    DataResult result = await uploadFile(
        url,
        await getToken(),
        imageFile, timeout: 50000);
    if (result.success) {
      Iterable l = result.obj;
      List<Receipt> newReceipts =
          l.map((model) => Receipt.fromJason(model)).toList();
      if (newReceipts.length > 0) {
        Receipt receipt = newReceipts[0];
        // insert the new receipt into the receipt list
        _lock.synchronized(() {
          receipts.add(receipt);
        });
        result.obj = receipt;
      } else {
        result.obj = null;
      }
    }

    return result;
  }

  Future<DataResult> deleteReceipts(List<int> receiptIds) async {
    DataResult result =
        await webservicePost(Urls.DeleteReceipts, await getToken(), jsonEncode(receiptIds));
    if (result.success) {
      // Delete the local cache of the receipts
      for (int i = 0; i < receiptIds.length; i++) {
        _lock.synchronized(() {
          for (int j = 0; j < receipts.length; j++) {
            if (receipts[j].id == receiptIds[i]) {
              receipts.removeAt(j);
              break;
            }
          }
        });
      }
    }

    return result;
  }

  Future<Image> getNetworkImage(String url) async {
    final token = await getToken();

    return await getImageFromNetwork(url, token);
  }
}

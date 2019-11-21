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

class amountPair {
  double amount;
  int id;

  amountPair({this.amount, this.id});
}

class ReceiptRepository {
  List<ReceiptListItem> receipts = new List<ReceiptListItem>();
  List<ReceiptListItem> selectedReceipts = new List<ReceiptListItem>();
  List<ReceiptListItem> cachedReceiptItems;
  List<amountPair> cachedReceiptItemsAmount;
  List<ReceiptListItem> candidateReceiptItems;
  UserRepository _userRepository;
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

  ReceiptRepository(UserRepository userRepository) {
    _userRepository = userRepository;
  }

  ReceiptListItem getReceiptItem(int receiptId) {
    ReceiptListItem receiptListItem = null;
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
      }

      if ((_userRepository == null) || (_userRepository.userId <= 0)) {
        // Log an error
        result = DataResult.fail();
      }

      result = await webserviceGet(
          Urls.GetReceipts + _userRepository.userId.toString(), "",
          timeout: 50000);
      if (result.success) {
        Iterable l = result.obj;
        receipts = l.map((model) => ReceiptListItem.fromJason(model)).toList();
        result.obj = receipts;
      }

      _dataFetched = result.success;
    });

    return result;
  }

  Future<DataResult> getReceipt(int receiptId) async {
    DataResult result =
        await webserviceGet(Urls.GetReceipt + receiptId.toString(), "");
    if (result.success) {
      result.obj = Receipt.fromJason(result.obj);
    }

    return result;
  }

  Future<DataResult> updateReceipt(Receipt receipt) async {
    DataResult result =
        await webservicePost(Urls.UpdateReceipt, "", jsonEncode(receipt));
    if (result.success) {
      result.obj = Receipt.fromJason(result.obj);
    }

    return result;
  }
  
  Future<DataResult> addReceipts(List<Receipt> receipts) async {
    DataResult result =
        await webservicePost(Urls.AddReceipts, "", jsonEncode(receipts));
    if (result.success) {
      var receipts = List<Receipt>();
      for (var receipt in result.obj){
        receipts.add(Receipt.fromJason(receipt));
      }
    }

    return result;
  }

  Future<DataResult> uploadReceiptImage(File imageFile) async {
    if ((_userRepository == null) || (_userRepository.userId <= 0)) {
      // Log an error
      return DataResult.fail(msg: "No user logged in.");
    }

    DataResult result = await uploadFile(
        Urls.UploadReceiptImages + _userRepository.userId.toString(),
        "",
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
        await webservicePost(Urls.DeleteReceipts, "", jsonEncode(receiptIds));
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
}

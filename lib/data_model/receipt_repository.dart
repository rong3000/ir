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

class ReceiptRepository {
  List<ReceiptListItem> receipts = new List<ReceiptListItem>();
  List<ReceiptListItem> selectedReceipts = new List<ReceiptListItem>();
  List<ReceiptListItem> cachedReceiptItems;
  List<ReceiptListItem> candidateReceiptItems;
  UserRepository _userRepository;
  bool _dataFetched = false;
  Lock _lock = new Lock();

  void resetCachedReceiptItems(ReportRepository reportRepository) {
    cachedReceiptItems = [];
    candidateReceiptItems = [];
    candidateReceiptItems = getReceiptItems(ReceiptStatusType.Reviewed);
    var _receiptsInReportSet = new Set<ReceiptListItem>();
    var _candidateReceiptsSet = new Set<ReceiptListItem>();

    for (var i = 0; i < reportRepository.reports.length; i++ ) {
      _receiptsInReportSet.addAll(reportRepository.reports[i].getReceiptList(this));
    }

    _candidateReceiptsSet.addAll(candidateReceiptItems);

    candidateReceiptItems = _candidateReceiptsSet.difference(_receiptsInReportSet).toList();
  }

  List<ReceiptListItem> removeCandidateItems(int id) {

    int toBeRemoved;
    for (int i = 0; i < _userRepository.receiptRepository.candidateReceiptItems.length; i++) {
      if (_userRepository.receiptRepository.candidateReceiptItems[i].id == id) {
        toBeRemoved = i;
      }
    }
    candidateReceiptItems.removeAt(toBeRemoved);
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

  List<ReceiptListItem> getSortedReceiptItems(ReceiptStatusType receiptStatus,
      ReceiptSortType type, bool ascending, DateTime fromDate, DateTime toDate) {
    _lock.synchronized(() {
      for (var i = 0; i < receipts.length; i++) {
        if (receipts[i].statusId == receiptStatus.index &&
            receipts[i].uploadDatetime.isAfter(fromDate) &&
            receipts[i].uploadDatetime.isBefore(toDate.add(Duration(days: 1)))) {
          selectedReceipts.add(receipts[i]);
          if (ascending) {
            switch (type) {
              case ReceiptSortType.UploadTime:
                selectedReceipts
                    .sort((a, b) => a.uploadDatetime.compareTo(b.uploadDatetime));
                break;
              case ReceiptSortType.ReceiptTime:
                selectedReceipts.sort(
                        (a, b) => a.receiptDatetime.compareTo(b.receiptDatetime));
                break;
              case ReceiptSortType.CompanyName:
                selectedReceipts.sort(
                        (a, b) => a.companyName.compareTo(b.companyName));
                break;
              case ReceiptSortType.Amount:
                selectedReceipts.sort(
                        (a, b) => a.totalAmount.compareTo(b.totalAmount));
                break;
              case ReceiptSortType.Category:
                selectedReceipts.sort(
                        (a, b) => a.categoryId.compareTo(b.categoryId));
                break;
              default:
                break;
            }
          } else {
            switch (type) {
              case ReceiptSortType.UploadTime:
                selectedReceipts
                    .sort((b, a) => a.uploadDatetime.compareTo(b.uploadDatetime));
                break;
              case ReceiptSortType.ReceiptTime:
                selectedReceipts.sort(
                        (b, a) => a.receiptDatetime.compareTo(b.receiptDatetime));
                break;
              case ReceiptSortType.CompanyName:
                selectedReceipts.sort(
                        (b, a) => a.companyName.compareTo(b.companyName));
                break;
              case ReceiptSortType.Amount:
                selectedReceipts.sort(
                        (b, a) => a.totalAmount.compareTo(b.totalAmount));
                break;
              case ReceiptSortType.Category:
                selectedReceipts.sort(
                        (b, a) => a.categoryId.compareTo(b.categoryId));
                break;
              default:
                break;
            }
          }
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
      result.obj = Receipt.fromJason(result.obj);
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

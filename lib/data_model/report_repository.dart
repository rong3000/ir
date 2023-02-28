import 'package:intelligent_receipt/data_model/ir_repository.dart';
import "report.dart";
import "webservice.dart";
import "../user_repository.dart";
import 'dart:convert';
import "enums.dart";
import 'package:synchronized/synchronized.dart';
export "receipt.dart";
export 'data_result.dart';
export 'enums.dart';

class ReportRepository extends IRRepository {
  List<Report> reports = new List<Report>();
  bool _dataFetched = false;
  Lock _lock = new Lock();

  ReportRepository(UserRepository userRepository) : super(userRepository);

  List<Report> getReportItems(ReportStatusType reportStatus) {
    List<Report> selectedReports = new List<Report>();
    _lock.synchronized(() {
      for (var i = 0; i < reports.length; i++) {
        if (reports[i].isNormalReport() && (reports[i].statusId == reportStatus.index)) {
          selectedReports.add(reports[i]);
        }
      }
    });
    return selectedReports;
  }

  List<Report> getSortedReportItems(ReportStatusType reportStatus, SaleExpenseType saleExpenseType,
    ReportSortType sortType, bool ascending, DateTime fromDate, DateTime toDate) {
    List<Report> selectedReports = new List<Report>();
    _lock.synchronized(() {
      for (var i = 0; i < reports.length; i++) {
        if (!reports[i].isNormalReport()) {
          continue;
        }
        if ((reports[i].statusId == reportStatus.index)
            && (reports[i].reportTypeId == saleExpenseType.index)
            && reports[i].createDateTime.isAfter(fromDate)
            && reports[i].createDateTime.isBefore(toDate.add(Duration(days: 1)))) {
          selectedReports.add(reports[i]);
        }
      }
    });

    switch (sortType) {
      case ReportSortType.CreateTime:
        selectedReports.sort(
                (a, b) => ascending ? a.createDateTime.compareTo(b.createDateTime) :  b.createDateTime.compareTo(a.createDateTime));
        break;
      case ReportSortType.UpdateTime:
        selectedReports.sort(
                (a, b) => ascending ? a.updateDateTime.compareTo(b.updateDateTime) : b.updateDateTime.compareTo(a.updateDateTime));
        break;
      case ReportSortType.GroupName:
        selectedReports.sort(
                (a, b) => ascending ? a.reportName.compareTo(b.reportName) : b.reportName.compareTo(a.reportName));
        break;
      default:
        break;
    }

    return selectedReports;
  }


  List<Report> getReportItemsByRange(ReportStatusType reportStatus, int start, int end) {
    List<Report> selectedReports = new List<Report>();
    _lock.synchronized(() {
      for (var i = 0; i < reports.length; i++) {
        if (reports[i].isNormalReport() && (reports[i].statusId == reportStatus.index)) {
          selectedReports.add(reports[i]);
        }
      }
    });
    return selectedReports.getRange(start, end).toList();
  }

  int getReportItemsCount(ReportStatusType reportStatus) {
    int reportCount = 0;
    _lock.synchronized(() {
      for (var i = 0; i < reports.length; i++) {
        if (reports[i].isNormalReport() && (reports[i].statusId == reportStatus.index)) {
          reportCount++;
        }
      }
    });
    return reportCount;
  }

  Report getReport(int reportId) {
    Report report;
    _lock.synchronized(() {
      for (var i = 0; i < reports.length; i++) {
        if (reports[i].id == reportId) {
          report = reports[i];
          break;
        }
      }
    });
    return report;
  }

  Future<DataResult> getReportsFromServer({bool forceRefresh = false}) async {
    DataResult result = new DataResult(false, "Unknown");
    await _lock.synchronized(() async {
      if (_dataFetched && !forceRefresh) {
        result = DataResult.success(reports);
      } else if ((userRepository == null) || (userRepository.userGuid == null)) {
        // Log an error
        result = DataResult.fail();
      } else {
        result = await webserviceGet(Urls.GetReports, await getToken(), timeout: 5000);
        if (result.success) {
          Iterable l = result.obj;
          reports = l.map((model) => Report.fromJson(model)).toList();
          result.obj = reports;
        }
      }

      _dataFetched = result.success;
    });

    return result;
  }

  Future<DataResult> addReport(Report report) async {
    DataResult result = await webservicePost(Urls.AddReport, await getToken(), jsonEncode(report));
    if (result.success) {
      Report newReport = Report.fromJson(result.obj);
      result.obj = newReport;
      _lock.synchronized(() {
        if (newReport.isNormalReport()) {
          reports.add(newReport);
        }
      });
    }

    return result;
  }

  Future<DataResult> addReceiptToReport(int reportId, int receiptId, {updateLocal: true}) async {
    DataResult result = await webservicePost(Urls.AddReceiptToReport  + reportId.toString() + "/" + receiptId.toString(), await getToken(), "");
    if (result.success) {
      if (updateLocal) {
        Report report = getReport(reportId);
        if ((report != null) && report.isNormalReport()) {
          report.receipts.add(new ReportReceipt(receiptId: receiptId));
        }
      }
    }

    return result;
  }

  Future<DataResult> deleteReport(int reportId, {updateLocal: true}) async {
    DataResult result = await webservicePost(Urls.DeleteReport  + reportId.toString(), await getToken(), "");
    if (result.success) {
      if (updateLocal) {
        reports.removeWhere((r) => r.id == reportId);
      }
    }

    return result;
  }

  Future<DataResult> removeReceiptFromReport(int reportId, int receiptId, {updateLocal: true}) async {
    DataResult result = await webservicePost(Urls.RemoveReceiptFromReport  + reportId.toString() + "/" + receiptId.toString(), await getToken(), "");
    if (result.success) {
      if (updateLocal) {
        Report report = getReport(reportId);
        if (report != null) {
          report.receipts.removeWhere((rid) => rid.receiptId == receiptId);
        }
      }
    }

    return result;
  }

  Future<DataResult> updateReport(Report report, bool updateReceiptList, {updateLocal: true}) async {
    DataResult result = await webservicePost(updateReceiptList ? Urls.UpdateReportWithReceipts : Urls.UpdateReportWithoutReceipts, await getToken(), jsonEncode(report));
    if (result.success) {
      result.obj = Report.fromJson(result.obj);
      if (updateLocal) {
        Report localReport = getReport(report.id);
        if ((localReport != null) && localReport.isNormalReport()) {
          localReport.reportName = report.reportName;
          localReport.description = report.description;
          localReport.statusId = report.statusId;
          if (updateReceiptList) {
            localReport.receipts = report.receipts;
          }
        }
      }
    }

    return result;
  }
}
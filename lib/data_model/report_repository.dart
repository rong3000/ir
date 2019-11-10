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
        if (reports[i].statusId == reportStatus.index) {
          selectedReports.add(reports[i]);
        }
      }
    });
    return selectedReports;
  }

  List<Report> getSortedReportItems(ReportStatusType reportStatus,
      ReportSortType type, bool ascending, DateTime fromDate, DateTime toDate) {
    List<Report> selectedReports = new List<Report>();
    _lock.synchronized(() {
      for (var i = 0; i < reports.length; i++) {
        if (reports[i].statusId == reportStatus.index
            && reports[i].createDateTime.isAfter(fromDate)
            && reports[i].createDateTime.isBefore(toDate.add(Duration(days: 1)))) {
          selectedReports.add(reports[i]);
          if (ascending) {
            switch (type) {
              case ReportSortType.CreateTime:
                selectedReports
                    .sort((a, b) => a.createDateTime.compareTo(b.createDateTime));
                break;
              case ReportSortType.UpdateTime:
                selectedReports.sort(
                        (a, b) => a.updateDateTime.compareTo(b.updateDateTime));
                break;
              case ReportSortType.GroupName:
                selectedReports.sort(
                        (a, b) => a.reportName.compareTo(b.reportName));
                break;
              default:
                break;
            }
          } else {
            switch (type) {
              case ReportSortType.CreateTime:
                selectedReports
                    .sort((b, a) => a.createDateTime.compareTo(b.createDateTime));
                break;
              case ReportSortType.UpdateTime:
                selectedReports.sort(
                        (b, a) => a.updateDateTime.compareTo(b.updateDateTime));
                break;
              case ReportSortType.GroupName:
                selectedReports.sort(
                        (b, a) => a.reportName.compareTo(b.reportName));
                break;
              default:
                break;
            }
          }
        }
      }
    });
    return selectedReports;
  }


  List<Report> getReportItemsByRange(ReportStatusType reportStatus, int start, int end) {
    List<Report> selectedReports = new List<Report>();
    _lock.synchronized(() {
      for (var i = 0; i < reports.length; i++) {
        if (reports[i].statusId == reportStatus.index) {
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
        if (reports[i].statusId == reportStatus.index) {
          reportCount++;
        }
      }
    });
    return reportCount;
  }

  Report getReport(int reportId) {
    Report report = null;
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
      }

      if ((userRepository == null) || (userRepository.userId <= 0))
      {
        // Log an error //TODO: better check
        result = DataResult.fail();
      }

      result = await webserviceGet(Urls.GetReports + userRepository.userId.toString(), "", timeout: 5000);
      if (result.success) {
        Iterable l = result.obj;
        reports = l.map((model) => Report.fromJason(model)).toList();
        result.obj = reports;
      }

      _dataFetched = result.success;
    });

    return result;
  }

  Future<DataResult> addReport(Report report) async {
    DataResult result = await webservicePost(Urls.AddReport  + userRepository.userId.toString(), "", jsonEncode(report));
    if (result.success) {
      Report newReport = Report.fromJason(result.obj);
      result.obj = newReport;
      _lock.synchronized(() {
        reports.add(newReport);
      });
    }

    return result;
  }

  Future<DataResult> addReceiptToReport(int reportId, int receiptId, {updateLocal: true}) async {
    DataResult result = await webservicePost(Urls.AddReceiptToReport  + reportId.toString() + "/" + receiptId.toString(), "", "");
    if (result.success) {
      if (updateLocal) {
        Report report = getReport(reportId);
        if (report != null) {
          report.receiptIds.add(reportId);
        }
      }
    }

    return result;
  }

  Future<DataResult> deleteReport(int reportId, {updateLocal: true}) async {
    DataResult result = await webservicePost(Urls.DeleteReport  + reportId.toString(), "", "");
    if (result.success) {
      if (updateLocal) {
        reports.removeWhere((r) => r.id == reportId);
      }
    }

    return result;
  }

  Future<DataResult> removeReceiptFromReport(int reportId, int receiptId, {updateLocal: true}) async {
    DataResult result = await webservicePost(Urls.RemoveReceiptFromReport  + reportId.toString() + "/" + receiptId.toString(), "", "");
    if (result.success) {
      if (updateLocal) {
        Report report = getReport(reportId);
        if (report != null) {
          report.receiptIds.removeWhere((rid) => rid == receiptId);
        }
      }
    }

    return result;
  }

  Future<DataResult> updateReport(Report report, bool updateReceiptList, {updateLocal: true}) async {
    DataResult result = await webservicePost(updateReceiptList ? Urls.UpdateReportWithReceipts : Urls.UpdateReportWithoutReceipts, "", jsonEncode(report));
    if (result.success) {
      result.obj = Report.fromJason(result.obj);
      if (updateLocal) {
        Report localReport = getReport(report.id);
        localReport.reportName = report.reportName;
        localReport.description = report.description;
        localReport.statusId = report.statusId;
        if (updateReceiptList) {
          localReport.receiptIds = report.receiptIds;
        }
      }
    }

    return result;
  }
}
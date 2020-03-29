import 'package:equatable/equatable.dart';
import 'package:intelligent_receipt/data_model/archived_receipt_models/archivedreceiptdatarange.dart';
import 'package:intelligent_receipt/data_model/receipt.dart';
import 'package:meta/meta.dart';

@immutable
abstract class ArchivedReceiptsState extends Equatable{
  ArchivedReceiptsState([List props = const []]) : super(props);
}

class GetArchiveMetaDataInitial extends ArchivedReceiptsState {
  GetArchiveMetaDataInitial() : super();

  @override
  String toString() => 'GetArchiveMetaData initial state';
}

class GetArchiveDataLoading extends ArchivedReceiptsState {
  GetArchiveDataLoading() : super([]);

  @override
  String toString() => 'GetArchiveMetaData Loading';
}

class GetArchiveMetaDataSuccessState extends ArchivedReceiptsState {
  final ArchivedReceiptDataRange dataRange;

  GetArchiveMetaDataSuccessState({@required this.dataRange}) : super([dataRange]);

  @override
  String toString() => 'GetArchiveMetaData Successful';
}

class GetArchiveMetaDataFailState extends ArchivedReceiptsState {
  final ArchivedReceiptDataRange dataRange;

  GetArchiveMetaDataFailState({@required this.dataRange}) : super([dataRange]);

  @override
  String toString() => 'GetArchiveMetaData Failed';
}


class GetArchivedReceiptsSuccessState extends ArchivedReceiptsState {
  final List<ReceiptListItem> receipts;

  GetArchivedReceiptsSuccessState({@required this.receipts}) : super([receipts]);

  @override
  String toString() => 'GetArchive Receipts Successful';
}

class GetArchivedReceiptsFailState extends ArchivedReceiptsState {
  final List<ReceiptListItem> receipts;

  GetArchivedReceiptsFailState({@required this.receipts}) : super([receipts]);

  @override
  String toString() => 'Get Archived Receipts Failed';
}

class UnArchivedReceiptSuccessState extends ArchivedReceiptsState {
  final int receiptId;

  UnArchivedReceiptSuccessState({@required this.receiptId}) : super([receiptId]);

  @override
  String toString() => 'GetArchive Receipts Successful';
}

class UnArchivedReceiptFailState extends ArchivedReceiptsState {
  final int receiptId;

  UnArchivedReceiptFailState({@required this.receiptId}) : super([receiptId]);

  @override
  String toString() => 'GetArchive Receipts Successful';
}

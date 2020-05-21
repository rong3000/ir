
import 'package:equatable/equatable.dart';
import 'package:intelligent_receipt/data_model/enums.dart';
import 'package:intelligent_receipt/data_model/receipt.dart';
import 'package:meta/meta.dart';

@immutable
abstract class ArchivedReceiptsEvent extends Equatable{
  ArchivedReceiptsEvent([List props = const []]) : super(props);
}

class GetArchiveMetaData extends ArchivedReceiptsEvent {
  final SaleExpenseType saleExpenseType;
  GetArchiveMetaData(this.saleExpenseType) : super();

  @override
  String toString() => 'Get Archive Meta Data';
}

class GetArchivedReceipts extends ArchivedReceiptsEvent {
  final String yearMonth;
  final SaleExpenseType saleExpenseType;
  
  GetArchivedReceipts(this.yearMonth, this.saleExpenseType) : super([yearMonth]);

  @override
  String toString() => 'Get Archived receipts for $yearMonth';
}

class UnArchivedReceipt extends ArchivedReceiptsEvent {
//  final List<ReceiptListItem> receipts;
  final int receiptId;
  
  UnArchivedReceipt(this.receiptId) : super([receiptId]);

  @override
  String toString() => 'Un Archive receipt with id $receiptId';
}

class DeleteReceipt extends ArchivedReceiptsEvent {
//  final List<ReceiptListItem> receipts;
  final int receiptId;

  DeleteReceipt(this.receiptId) : super([receiptId]);

  @override
  String toString() => 'Delete receipt with id $receiptId';
}

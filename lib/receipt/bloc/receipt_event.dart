import 'package:equatable/equatable.dart';
import 'package:intelligent_receipt/data_model/receipt.dart';
import 'package:meta/meta.dart';

@immutable
abstract class ReceiptEvent extends Equatable {
  ReceiptEvent([List props = const []]) : super(props);
}

class ManualReceiptUpload extends ReceiptEvent {
  final Receipt receipt;

  ManualReceiptUpload({@required this.receipt}) : super([receipt]);

  @override
  String toString() => 'ReceiptUpload { receiptID :${receipt.id}'; 
}


class ManualReceiptUpdate extends ReceiptEvent {
  final Receipt receipt;

  ManualReceiptUpdate({@required this.receipt}) : super([receipt]);

  @override
  String toString() => 'ReceiptUpdate { receiptID :${receipt.id}'; 
}
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:intelligent_receipt/data_model/receipt.dart';
import 'package:meta/meta.dart';

@immutable
abstract class ReceiptEvent extends Equatable {
  ReceiptEvent([List props = const []]) : super(props);
}

class ReceiptUploaded extends ReceiptEvent {
  Receipt receipt;
  File image;

  ReceiptUploaded({@required this.receipt, @required this.image}) : super([receipt, image]);

  @override
  String toString() => 'ReceiptUploaded { receiptID :${receipt.id}'; 
}
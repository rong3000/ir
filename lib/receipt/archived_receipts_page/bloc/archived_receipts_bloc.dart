import 'package:bloc/bloc.dart';
import 'package:intelligent_receipt/data_model/receipt_repository.dart';
import 'archived_receipts_events.dart';
import 'archived_receipts_state.dart';
import 'package:meta/meta.dart';

class ArchivedReceiptsBloc extends Bloc<ArchivedReceiptsEvent, ArchivedReceiptsState> {
  ReceiptRepository _receiptRepository;

  ArchivedReceiptsBloc({
    @required ReceiptRepository receiptRepository,
  })  : assert(receiptRepository != null),
        _receiptRepository = receiptRepository;

  @override
  ArchivedReceiptsState get initialState => GetArchiveMetaDataInitial();

  @override
  Stream<ArchivedReceiptsState> mapEventToState(ArchivedReceiptsEvent event) async* {
    if (event is GetArchiveMetaData) {
      yield* _getArchivedReceiptsMetaData(event);
    }
    else if (event is GetArchivedReceipts){
      yield*  _handleGetArchivedReceipts(event);
    }
    else if (event is UnArchivedReceipt){
      yield*  _handleUnArchivedReceipt(event);
    } else if (event is DeleteReceipt) {
      yield* _handleDeleteReceipt(event);
    }
    // More cases here for different events
  }

  Stream<ArchivedReceiptsState> _getArchivedReceiptsMetaData(GetArchiveMetaData event) async* {
    yield GetArchiveDataLoading();

    var result = await _receiptRepository.getArchivedReceiptMetaData();

    if (result.success){
      yield GetArchiveMetaDataSuccessState(dataRange: result.obj);
    } else {
      yield GetArchiveMetaDataFailState(dataRange: result.obj);
    }
  }

  Stream<ArchivedReceiptsState> _handleGetArchivedReceipts(GetArchivedReceipts event) async* {
    yield GetArchiveDataLoading();

    var result = await _receiptRepository.getArchivedReceipts(event.yearMonth);

    if (result.success){
      yield GetArchivedReceiptsSuccessState(receipts: result.obj);
    } else {
      yield GetArchivedReceiptsFailState(receipts: []);
    }
  }

  Stream<ArchivedReceiptsState> _handleUnArchivedReceipt(UnArchivedReceipt event) async* {
    var result = await _receiptRepository.unArchiveReceipt(event.receiptId);

    if (result.success){
      yield UnArchivedReceiptSuccessState(receiptId: event.receiptId);
    } else {
      yield UnArchivedReceiptFailState(receiptId: event.receiptId);
    }
  }

  Stream<ArchivedReceiptsState> _handleDeleteReceipt(DeleteReceipt event) async* {
    List<int> receiptIds = new List<int>();
    receiptIds.add(event.receiptId);
    var result = await _receiptRepository.deleteReceipts(receiptIds);

    if (result.success){
      yield DeleteReceiptSuccessState(receiptId: event.receiptId);
    } else {
      yield DeleteReceiptFailState(receiptId: event.receiptId, description: result.message);
    }
  }
}
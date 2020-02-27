import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intelligent_receipt/data_model/GeneralUtility.dart';
import 'package:intelligent_receipt/data_model/receipt_repository.dart';
import 'package:intelligent_receipt/translations/global_translations.dart';
import 'package:intelligent_receipt/user_repository.dart';
import 'dart:io';
import "package:rflutter_alert/rflutter_alert.dart";
import 'dart:async';
import 'package:image_cropper/image_cropper.dart';
import '../add_edit_reciept_manual/add_edit_receipt_manual.dart';
import 'package:intelligent_receipt/data_model/exception_handlers/unsupported_version.dart';
import 'package:intelligent_receipt/data_model/http_statuscode.dart';
import 'package:intelligent_receipt/main_screen/bloc/bloc.dart';
import 'package:intelligent_receipt/data_model/GeneralUtility.dart';


class UploadReceiptImage extends StatefulWidget {
  final UserRepository _userRepository;
  final String title;
  File imageFile;

  UploadReceiptImage(
      {Key key, @required UserRepository userRepository, this.title, this.imageFile})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(key: key);

  @override
  _UploadReceiptImageState createState() => _UploadReceiptImageState();
}

enum AppState {
  free,
  picked,
  cropped,
}

class _UploadReceiptImageState extends State<UploadReceiptImage> {
  UserRepository get _userRepository => widget._userRepository;
  AppState state;
  File imageFileToCrop;
  Future<DataResult> _uploadReceiptFulture;

  @override
  void initState() {
    super.initState();
    imageFileToCrop = widget.imageFile;
    state = AppState.picked;
  }

  void _uploadReceipt(File imageFile) async {
    _uploadReceiptFulture = _userRepository.receiptRepository.uploadReceiptImage(imageFile);
  }

  void showAlert(String message, AlertType alertType) {
    Alert(
      context: context,
      type: alertType,
      title: "RFLUTTER ALERT",
      desc: message,
      buttons: [
        DialogButton(
          child: Text(
            allTranslations.text('app.upload-receipt-alert.button-text'),
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () => Navigator.pop(context),
          width: 120,
        )
      ],
    ).show();
  }

  Icon getIcon(AlertType alertType) {
    Color color = Colors.blue;
    IconData iconData = Icons.info;

    if (alertType == AlertType.error) {
      color = Colors.red;
      iconData = Icons.error;
    } else if (alertType == AlertType.warning) {
      color = Colors.orange;
      iconData = Icons.warning;
    }

    return new Icon(
      iconData,
      color: color,
      size: 50,
    );
  }

  Widget _getResultWidget(String message, {AlertType alertType: AlertType.info, Receipt receipt, bool showReviewButtons : true}) {
    return Center(
            child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                decoration: new BoxDecoration(
                  image: new DecorationImage(
                    colorFilter: new ColorFilter.mode(
                        Colors.black.withOpacity(0.1), BlendMode.dstATop),
                    image: new MemoryImage(imageFileToCrop.readAsBytesSync()),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      getIcon(alertType),
                      Text(message,
                          style: TextStyle(
                              color: Colors.indigo,
                              fontSize: 16)),
                      Container(
                        height: 16,
                      ),
                      (showReviewButtons) ? Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          RaisedButton(
                            textColor: Colors.white,
                            padding: const EdgeInsets.all(0.0),
                            child: Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: <Color>[
                                    Color(0xFF0D47A1),
                                    Color(0xFF1976D2),
                                    Color(0xFF42A5F5),
                                  ],
                                ),
                              ),
                              padding: const EdgeInsets.all(10.0),
                              child: Text(
                                 allTranslations.text('app.upload-receipt-screen.review-now-label'),
                                  style: TextStyle(fontSize: 16)
                              ),
                            ),

                            onPressed: () {
                              Navigator.of(context).pop();
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) {
                                  return AddEditReiptForm(receipt);
                                }),
                              );
                            },
                          ),
                          Container (
                            width: 16
                          ),
                          RaisedButton(
                            textColor: Colors.white,
                            padding: const EdgeInsets.all(0.0),
                            child: Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: <Color>[
                                    Color(0xFF0D47A1),
                                    Color(0xFF1976D2),
                                    Color(0xFF42A5F5),
                                  ],
                                ),
                              ),
                              padding: const EdgeInsets.all(10.0),
                              child: Text(
                                  allTranslations.text('app.upload-receipt-screen.review-later-label'),
                                  style: TextStyle(fontSize: 16)
                              ),
                            ),

                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),

                        ]
                      ) : Container(),
                      Container(
                        height: MediaQuery.of(context).size.height / 5,
                      ),
                    ])));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
          child: (imageFileToCrop != null)
              ? (state == AppState.cropped
                  ? FutureBuilder<DataResult>(
                      future: _uploadReceiptFulture,
                      builder: (BuildContext context,
                          AsyncSnapshot<DataResult> snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.none:
                            return new Text(allTranslations.text('app.upload-receipt-screen.press-to-start-label'));
                          case ConnectionState.waiting:
                            return _getResultWidget(allTranslations.text('app.upload-receipt-screen.submitting-label'), showReviewButtons: false);
                          default:
                            if (snapshot.hasError)
                              return _getResultWidget('${allTranslations.text('app.upload-receipt-screen.error-prefix')}: ${snapshot.error}', showReviewButtons: false);
                            else {
                              DataResult dataResult = snapshot.data;
                              if (dataResult.success) {
                                BlocProvider.of<MainScreenBloc>(context).dispatch(ShowUnreviewedReceiptEvent());
                                Receipt receipt = dataResult.obj as Receipt;
                                if (receipt == null ||
                                    receipt.decodeStatus == DecodeStatusType.Unknown.index) {
                                  // Show unknown error
                                  return _getResultWidget(allTranslations.text('app.upload-receipt-screen.unknown-error-label')
                                      );
                                } else if (receipt.decodeStatus == DecodeStatusType.ExtractTextFailed.index) {
                                  // Show extracted text failure error
                                  return _getResultWidget(
                                      allTranslations.text('app.upload-receipt-screen.extract-text-failed-message'),
                                      receipt: receipt);
                                } else if (receipt.decodeStatus == DecodeStatusType.MaybeNotValidReceipt.index) {
                                  // Show image maybe not a valid receipt error
                                  return _getResultWidget(
                                      allTranslations.text('app.upload-receipt-screen.maybe-not-valid-message'),
                                      receipt: receipt);
                                } else if ((receipt.decodeStatus == DecodeStatusType.UnrecognizedFormat.index) ||
                                           (receipt.decodeStatus == DecodeStatusType.PartiallyDecoded.index)) {
                                  // Show unrecognized format error
                                  return _getResultWidget(
                                      allTranslations.text('app.upload-receipt-screen.unrecognized-format-message'),
                                      receipt: receipt);
                                } else {
                                  // Show add or update receipt page
                                  return _getResultWidget(
                                       allTranslations.text('app.upload-receipt-screen.recognized-success-message'),
                                      receipt: receipt);
                                }
                              } else {
                                if (snapshot.data.messageCode == HTTPStatusCode.UNSUPPORTED_VERSION) {
                                  return UnsupportedVersion();
                                }
                                // Show error message
                                return _getResultWidget(
                                    allTranslations.text('app.upload-receipt-screen.general-error-message') +
                                        dataResult.message, showReviewButtons: false);
                              }
                            }
                        }
                      },
                    )
                  : Image.file(imageFileToCrop))
              : Container(),
        ),
        floatingActionButton: state == AppState.cropped
            ? null
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  FloatingActionButton(
                    heroTag: "camera",
                    onPressed: () {
                      if (state == AppState.free)
                        {
//                          _pickImageCamera();
                        }
                      else if (state == AppState.picked) {_cropImage();}
                    },
                    child: _buildButtonIconCamera(),
                  ),
                  state == AppState.picked
                      ? FloatingActionButton(
                          heroTag: "continue",
                          onPressed: () {
                            setState(() {
                              state = AppState.cropped;
                            });
                          },
                          child: Icon(Icons.check),
                        )
                      : FloatingActionButton(
                          heroTag: "gallery",
                          onPressed: () {
                            if (state == AppState.free)
                              {
//                                _pickImageGallery();
                              }
                            else if (state == AppState.picked) {_cropImage();}
                          },
                          child: _buildButtonIconGallery(),
                        ),
                ],
              ));
  }

  Widget _buildButtonIconCamera() {
    if (state == AppState.free)
      return Icon(Icons.camera);
    else if (state == AppState.picked)
      return Icon(Icons.crop);
    else if (state == AppState.cropped)
      return null;
    else
      return Container();
  }

  Widget _buildButtonIconGallery() {
    if (state == AppState.free)
      return Icon(Icons.photo);
    else if (state == AppState.picked)
      return null;
    else if (state == AppState.cropped)
      return null;
    else
      return Container();
  }

  Future<Null> _cropImage() async {
    File compressedFile = await compressImage(imageFileToCrop);
    File croppedFile = await ImageCropper.cropImage(
      sourcePath: compressedFile.path,
      aspectRatioPresets: Platform.isAndroid
          ? [
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9
            ]
          : [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio5x3,
              CropAspectRatioPreset.ratio5x4,
              CropAspectRatioPreset.ratio7x5,
              CropAspectRatioPreset.ratio16x9
            ],
      androidUiSettings: AndroidUiSettings(
          toolbarTitle: allTranslations.text('app.image-cropper.title'),
          toolbarColor: Colors.deepOrange,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false),
    );
    if (croppedFile != null) {
      imageFileToCrop = croppedFile;
      setState(() {
        _uploadReceipt(imageFileToCrop);
        state = AppState.cropped;
      });
    }
    compressedFile.delete();
  }
}

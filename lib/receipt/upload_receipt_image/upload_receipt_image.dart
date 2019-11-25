import 'package:flutter/material.dart';
import 'package:intelligent_receipt/data_model/receipt_repository.dart';
import 'package:intelligent_receipt/user_repository.dart';
import 'dart:io';
import "package:rflutter_alert/rflutter_alert.dart";
import 'dart:async';
import 'package:image_cropper/image_cropper.dart';
import '../add_edit_reciept_manual/add_edit_receipt_manual.dart';

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

  @override
  void initState() {
    super.initState();
    imageFileToCrop = widget.imageFile;
    state = AppState.picked;
  }

  Future<DataResult> _uploadReceipt(File imageFile) async {
//    imageFile = await ImagePicker.pickImage(
//        source: (widget._imageSource == IRImageSource.Gallary)
//            ? ImageSource.gallery
//            : ImageSource.camera,
//        maxWidth: 600);
//    File croppedFile = await ImageCropper.cropImage(
//      sourcePath: image.path,
//        ratioX: 1.0,
//        ratioY: 1.0,
//        maxWidth: 512,
//        maxHeight: 512);

    DataResult dataResult =
        await _userRepository.receiptRepository.uploadReceiptImage(imageFile);
    return dataResult;
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
            "OK, Got it",
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

  Widget _getResultWidget(String message, {AlertType alertType: AlertType.info, Receipt receipt}) {
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
                              //fontWeight: FontWeight.bold,
                              fontSize: 16)),
                      Container(
                        height: 16,
                      ),
                      (true) ? Row(
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
                              child: const Text(
                                  'Review Now',
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
                              child: const Text(
                                  'Review Later',
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
                      future:
                          _uploadReceipt(imageFileToCrop), // a Future<String> or null
                      builder: (BuildContext context,
                          AsyncSnapshot<DataResult> snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.none:
                            return new Text('Press button to start');
                          case ConnectionState.waiting:
                            return _getResultWidget('Submitting receipt, will be ready soon ...');
                          default:
                            if (snapshot.hasError)
                              return _getResultWidget('Error: ${snapshot.error}');
                            else {
                              DataResult dataResult = snapshot.data;
                              if (dataResult.success) {
                                Receipt receipt = dataResult.obj as Receipt;
                                if (receipt == null ||
                                    receipt.decodeStatus == DecodeStatusType.Unknown.index) {
                                  // Show unknown error
                                  return _getResultWidget(
                                      "We encounter an unknown error when submitting the receipt, please resubmit the receipt.");
                                } else if (receipt.decodeStatus == DecodeStatusType.ExtractTextFailed.index) {
                                  // Show extracted text failure error
                                  return _getResultWidget(
                                      "The receipt has been submitted, but failed to extract the text from the image. Please double check whether this is a valid receipt.\n\n"
                                          "Press 'Review Now' button to manually enter receipt information now.\n"
                                          "Press 'Review Later' button to review the receipt later, which is listed in 'Receipts\\Unreviewed' tab.",
                                      receipt: receipt);
                                } else if (receipt.decodeStatus == DecodeStatusType.MaybeNotValidReceipt.index) {
                                  // Show image maybe not a valid receipt error
                                  return _getResultWidget(
                                      "This maybe not a valid receipt. Please double check.\n\n"
                                          "Press 'Review Now' button to manually enter receipt information now.\n"
                                          "Press 'Review Later' button to review the receipt later, which is listed in 'Receipts\\Unreviewed' tab.",
                                      receipt: receipt);
                                } else if ((receipt.decodeStatus == DecodeStatusType.UnrecognizedFormat.index) ||
                                           (receipt.decodeStatus == DecodeStatusType.PartiallyDecoded.index)) {
                                  // Show unrecognized format error
                                  return _getResultWidget(
                                      "The receipt image has been submitted, we are now recognizing it, and will notify you after we recognize it.\n\n"
                                          "Press 'Review Now' button to manually enter receipt information now.\n"
                                          "Press 'Review Later' button to review the receipt later, which is listed in 'Receipts\\Unreviewed' tab.",
                                      receipt: receipt);
                                } else {
                                  // Show add or update receipt page
                                  return _getResultWidget(
                                      "The receipt image has been submitted and recognized.\n\n"
                                          "Press 'Review Now' button to verify receipt information now.\n"
                                          "Press 'Review Later' button to review the receipt later, which is listed in 'Receipts\\Unreviewed' tab.",
                                      receipt: receipt);
                                }
                              } else {
                                // Show error message
                                return _getResultWidget(
                                    "We encounter an error when submitting the receipt: " +
                                        dataResult.message);
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

//  Future<Null> _pickImageCamera() async {
//    imageFile =
//        await ImagePicker.pickImage(source: ImageSource.camera, maxWidth: 600);
//    if (imageFile != null) {
//      setState(() {
//        state = AppState.picked;
//      });
//    }
//  }
//
//  Future<Null> _pickImageGallery() async {
//    imageFile =
//        await ImagePicker.pickImage(source: ImageSource.gallery, maxWidth: 600);
//    if (imageFile != null) {
//      setState(() {
//        state = AppState.picked;
//      });
//    }
//  }

  Future<Null> _cropImage() async {
    File croppedFile = await ImageCropper.cropImage(
      sourcePath: imageFileToCrop.path,
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
          toolbarTitle: 'Cropper',
          toolbarColor: Colors.deepOrange,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false),
    );
    if (croppedFile != null) {
      imageFileToCrop = croppedFile;
      setState(() {
        state = AppState.cropped;
      });
    }
  }

//  void _clearImage() {
//    imageFile = null;
//    setState(() {
//      state = AppState.free;
//    });
//  }
}

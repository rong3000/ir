import 'package:flutter/material.dart';
import 'package:intelligent_receipt/data_model/receipt_repository.dart';
import 'package:intelligent_receipt/user_repository.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import "package:rflutter_alert/rflutter_alert.dart";
import 'dart:async';
import 'package:image_cropper/image_cropper.dart';

class UploadReceiptImage extends StatefulWidget {
  final UserRepository _userRepository;
  final String title;

  UploadReceiptImage(
      {Key key, @required UserRepository userRepository, this.title})
      : assert(userRepository != null),
        _userRepository = userRepository,
        super(key: key) {}

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
  File imageFile;

  @override
  void initState() {
    super.initState();
    state = AppState.free;
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
      size: 80,
    );
  }

  Widget getErrorPage(String titleTxt, String message,
      {AlertType alertType: AlertType.info}) {
    return Scaffold(
        appBar: AppBar(title: Text(titleTxt)),
        body: Center(
            child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                decoration: new BoxDecoration(
                  image: new DecorationImage(
                    colorFilter: new ColorFilter.mode(
                        Colors.black.withOpacity(0.1), BlendMode.dstATop),
                    image: new MemoryImage(imageFile.readAsBytesSync()),
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
                    ]))));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
          child: (imageFile != null)
              ? (state == AppState.cropped
                  ? FutureBuilder<DataResult>(
                      future:
                          _uploadReceipt(imageFile), // a Future<String> or null
                      builder: (BuildContext context,
                          AsyncSnapshot<DataResult> snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.none:
                            return new Text('Press button to start');
                          case ConnectionState.waiting:
                            return new Text(
                                'Submitting receipt, will be ready soon ...');
                          default:
                            if (snapshot.hasError)
                              return getErrorPage(
                                  "Error", 'Error: ${snapshot.error}');
                            else {
                              DataResult dataResult = snapshot.data;
                              if (dataResult.success) {
                                Receipt receipt = dataResult.obj as Receipt;
                                if (receipt == null ||
                                    receipt.decodeStatus ==
                                        DecodeStatusType.Unknown.index) {
                                  // Show unknown error
                                  return getErrorPage("Error",
                                      "We encounter an unknown error when submitting the receipt, please resubmit the receipt.");
                                } else if (receipt.decodeStatus ==
                                    DecodeStatusType.ExtractTextFailed.index) {
                                  // Show extracted text failure error
                                  return getErrorPage("Extract Text Error",
                                      "Failed to extract the text from the image.");
                                } else if (receipt.decodeStatus ==
                                    DecodeStatusType
                                        .MaybeNotValidReceipt.index) {
                                  // Show image maybe not a valid receipt error
                                  return getErrorPage("Invalid Receipt",
                                      "This maybe not a valid receipt, please double check.");
                                } else if (receipt.decodeStatus ==
                                    DecodeStatusType.UnrecognizedFormat.index) {
                                  // Show unrecognized format error
                                  return getErrorPage("Recognizing",
                                      "The receipt image has been submitted, we are now recognizing it, and will notify you after we recognize it.");
                                } else {
                                  // Show add or update receipt page
                                  return Text(
                                      "Receipt was uploaded successfully");
                                }
                              } else {
                                // Show error message
                                return getErrorPage(
                                    "Error",
                                    "We encounter an error when submitting the receipt: " +
                                        dataResult.message);
                              }
                            }
                        }
                      },
                    )
                  : Image.file(imageFile))
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
                        _pickImageCamera();
                      else if (state == AppState.picked) _cropImage();
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
                              _pickImageGallery();
                            else if (state == AppState.picked) _cropImage();
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

  Future<Null> _pickImageCamera() async {
    imageFile =
        await ImagePicker.pickImage(source: ImageSource.camera, maxWidth: 600);
    if (imageFile != null) {
      setState(() {
        state = AppState.picked;
      });
    }
  }

  Future<Null> _pickImageGallery() async {
    imageFile =
        await ImagePicker.pickImage(source: ImageSource.gallery, maxWidth: 600);
    if (imageFile != null) {
      setState(() {
        state = AppState.picked;
      });
    }
  }

  Future<Null> _cropImage() async {
    File croppedFile = await ImageCropper.cropImage(
      sourcePath: imageFile.path,
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
      imageFile = croppedFile;
      setState(() {
        state = AppState.cropped;
      });
    }
  }

  void _clearImage() {
    imageFile = null;
    setState(() {
      state = AppState.free;
    });
  }
}

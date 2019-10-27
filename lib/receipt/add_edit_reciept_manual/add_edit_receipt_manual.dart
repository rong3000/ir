import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intelligent_receipt/data_model/category.dart';
import 'package:intelligent_receipt/data_model/currency.dart';
import 'package:intelligent_receipt/data_model/receipt.dart';
import 'package:intelligent_receipt/data_model/report_repository.dart';
import 'package:intelligent_receipt/helper_widgets/date_time_picker.dart';
import 'package:intelligent_receipt/receipt/bloc/receipt_bloc.dart';
import 'package:intelligent_receipt/receipt/bloc/receipt_event.dart';
import 'package:intelligent_receipt/user_repository.dart';

class AddEditReiptForm extends StatefulWidget {
  final Receipt _receiptItem;

  AddEditReiptForm(this._receiptItem);
  
  @override
  State<StatefulWidget> createState() {
    var isNew = _receiptItem == null;
    Receipt receipt;
    
    if (isNew) {
      receipt = Receipt()
        ..receiptDatetime = DateTime.now()
        ..receiptTypeId = 0
        ..productName = ""
        ..gstInclusive = true
        ..totalAmount = 0
        ..companyName = ""
        ..warrantyPeriod = 0
        ..notes = ""
        ..categoryId = 1;
    }
    else {
      receipt = _receiptItem;
    }

    return _AddEditReiptFormState(receipt, isNew);
  }
}

class _AddEditReiptFormState extends State<AddEditReiptForm> {
  final _formKey = GlobalKey<FormState>();
  final pageTitleEdit = 'Edit Receipt';
  final pageTitleNew = 'Create Receipt';

  var isNew;
  File receiptImageFile;
  Image receiptImage;
  Receipt receipt;
  Currency defaultCurrency;
  var currenciesList = List<Currency>();
  var categoryList = List<Category>();
  UserRepository _userRepository;
  ReceiptBloc _receiptBloc;

  _AddEditReiptFormState(this.receipt, this.isNew) {
    defaultCurrency = Currency();
    defaultCurrency.code = 'AUD';
    if (this.receipt.categoryId < 1) {
      this.receipt.categoryId = 1;
    }

    if (!isNew){
      var imageData = UriData.parse(receipt.image);
      var bytes = imageData.contentAsBytes();
      receiptImage = Image.memory(bytes);
    }
  }

  @override
  void initState() {
    _receiptBloc = BlocProvider.of<ReceiptBloc>(context);

    _userRepository = RepositoryProvider.of<UserRepository>(context);
    defaultCurrency = _userRepository.settingRepository.getDefaultCurrency() ??
        defaultCurrency;
    currenciesList = _userRepository.settingRepository.getCurrencies();
    categoryList = _userRepository.categoryRepository.categories;

    if (categoryList.length == 0) {
      _userRepository.categoryRepository.getCategoriesFromServer(forceRefresh: true).then((value) {
        this.setState(() {
          categoryList = _userRepository.categoryRepository.categories;
          receipt.categoryId = categoryList[0].id;
        });
      });
    }

    if (currenciesList.length == 0) {
      _userRepository.settingRepository.getCurrenciesFromServer().then((value) {
        this.setState(() {
          currenciesList = _userRepository.settingRepository.getCurrencies();
          defaultCurrency = _userRepository.settingRepository.getDefaultCurrency() ??
            defaultCurrency;
        });
      });
    }
    super.initState();
  }

  void _deleteReceipt() {
    // TODO handle delete/clear
  }

  void _saveForm() {
    if (this._formKey.currentState.validate()) {
      this._formKey.currentState.save();
    }

    this.receipt.userId = this._userRepository.userId;
    
    //common save logic
    this.receipt.statusId = ReceiptStatusType.Reviewed.index;
    this.receipt.statusUpdateDatetime = DateTime.now();
    
    this.receipt.decodeStatus = DecodeStatusType.Success.index;
    this.receipt.receiptTypeId = 0;
    
    // if this is not null we have a new receipt OR have changed the existing image
    // either way send the base64 image to be saved/updated
    if (receiptImageFile != null){
      this.receipt.imageFileExtension = this.receiptImageFile.path.substring(this.receiptImageFile.path.lastIndexOf('.') + 1).trim();

      var imageStream = this.receiptImageFile?.readAsBytesSync();
      this.receipt.image = imageStream != null ? base64Encode(imageStream) : null;
    }
    else {
      // No update to image, set null so existing image is not re-sent to api for update
      this.receipt.image = null;
    }
    
    // new logic
    if (isNew){
      this.receipt.uploadDatetime = DateTime.now();

      _receiptBloc.dispatch(ManualReceiptUpload(receipt: this.receipt));
    } else {
      //TODO: update if not new
      
        _receiptBloc.dispatch(ManualReceiptUpdate(receipt: this.receipt));
    }
    
  }

  String textFieldValidator(value) {
    if (value.isEmpty) {
      return 'Value required';
    }
    return null;
  }

  List<DropdownMenuItem<String>> _getCurrencyCodesList() {
    var list = List<DropdownMenuItem<String>>();

    //Handle none returned
    if (currenciesList.length > 0) {
      for (var currency in currenciesList) {
        list.add(DropdownMenuItem<String>(
            value: currency.code, child: Text(currency.code)));
      }
    }

    return list;
  }

  List<DropdownMenuItem<int>> _getCategorylist() {
    var list = List<DropdownMenuItem<int>>();
    for (var cat in categoryList) {
      list.add(
        DropdownMenuItem<int>(value: cat.id, child: Text(cat.categoryName)),
      );
    }
    return list;
  }

  Future<ImageSource> _getImageSource() async {
    return showDialog<ImageSource>(
      context: context,
      barrierDismissible: true, // Allow to be closed without selecting option
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Image Source'),
          actions: <Widget>[
            FlatButton(
              child: Text('Camera'),
              onPressed: () {
                Navigator.of(context).pop(ImageSource.camera);
              },
            ),
            FlatButton(
              child: Text('Gallery'),
              onPressed: () {
                Navigator.of(context).pop(ImageSource.gallery);
              },
            ),
          ],
        );
      },
    );
  }

  _selectImage(ImageSource imageSource) async {
    var source = await _getImageSource();
    if (source != null) {
      var ri = await ImagePicker.pickImage(source: source, maxWidth: 600);
      setState(() {
        receiptImageFile = ri;
        receiptImage = Image.file(ri);
      });
    }
  }

  List<Widget> _getImageWidgets() {
    var widgets = List<Widget>();
      
    if (receiptImage != null) {
      widgets.add(
        Expanded(
          flex: 5,
          child: GestureDetector(
            onTap: () {
              _showFullImage(receiptImage);
            },
            child: ClipRect(
              child: Align(
                alignment: Alignment.topCenter,
                heightFactor: .6,
                child: receiptImage,
              ),
            ),
          ),
        ),
      );
    }

    widgets.add(
      Expanded(
        flex: 5,
        child: GestureDetector(
            onTap: () {
              _selectImage(ImageSource.gallery);
            },
            child: Column(
              children: <Widget>[
                Icon(
                  Icons.image,
                  size: 60,
                  semanticLabel: 'Select New Image',
                ),
                Text('Select New Image')
              ],
            )),
      ),
    );

    return widgets;
  }

  Future<void> _showFullImage(Widget childImage) async {
    await showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            children: <Widget>[
              SimpleDialogOption(
                child: childImage,
              ),
              SimpleDialogOption(
                child: FlatButton(
                  child: Text('Close'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isNew ? pageTitleNew : pageTitleEdit),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              _deleteReceipt();
            },
          ),
          IconButton(
            icon: const Icon(Icons.done),
            onPressed: () {
              this._saveForm();
            },
          )
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: ListView(
          children: <Widget>[
            Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  IRDateTimePicker(
                    labelText: 'Purchase Date',
                    selectedDate: receipt.receiptDatetime,
                    selectDate: (newValue) {
                      setState(() {
                        receipt.receiptDatetime = newValue;
                      });
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Flexible(
                        flex: 7,
                        child: Padding(
                          padding: EdgeInsets.only(top: 5),
                          child: TextFormField(
                            decoration:
                                InputDecoration(labelText: 'Total Amount'),
                            initialValue: receipt.totalAmount.toString(),
                            validator: textFieldValidator,
                            onSaved: (String value) {
                              receipt.totalAmount = double.tryParse(value);
                            },
                          ),
                        ),
                      ),
                      Flexible(
                        flex: 3,
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(labelText: 'Currency Code'),
                          items: _getCurrencyCodesList(),
                          value: defaultCurrency.code,
                          onSaved: (String value) {
                            receipt.currencyCode = value;
                          },
                          onChanged: (String newValue) {
                            setState(() {
                              defaultCurrency = currenciesList
                                  .singleWhere((curr) => curr.code == newValue);
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  FormField<bool>(
                    builder: (formState) => CheckboxListTile(
                      title: const Text('GST Inclusive'),
                      value: receipt.gstInclusive,
                      onChanged: (newValue) {
                        setState(() {
                          receipt.gstInclusive = !receipt.gstInclusive;
                        });
                      },
                    ),
                    onSaved: (newValue) {
                      receipt.gstInclusive = receipt.gstInclusive;
                    },
                  ),
                  DropdownButtonFormField<int>(
                    decoration: InputDecoration(labelText: 'Category'),
                    items: _getCategorylist(),
                    value: receipt.categoryId,
                    onSaved: (int value) {
                      receipt.categoryId = value;
                    },
                    onChanged: (int newValue) {
                      setState(() {
                        receipt.categoryId = newValue;
                      });
                    },
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Shop/Vendor'),
                    initialValue: receipt.companyName,
                    validator: textFieldValidator,
                    onSaved: (String value) {
                      receipt.companyName = value;
                    },
                  ),
                  TextFormField(
                    initialValue: receipt.productName,
                    validator: textFieldValidator,
                    decoration: InputDecoration(labelText: 'Product Name'),
                    onSaved: (String value) {
                      receipt.productName = value;
                    },
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text('Warranty Period'),
                      ),
                      FormField<double>(
                        builder: (formFieldState) => Slider.adaptive(
                          value: receipt.warrantyPeriod,
                          divisions: receipt.warrantyPeriod < 24 ? 20 : 5,
                          min: 0,
                          max: 60,
                          label:
                              '${receipt.warrantyPeriod < 24 ? receipt.warrantyPeriod : receipt.warrantyPeriod / 12} ${receipt.warrantyPeriod < 24 ? "months" : "years"}',
                          onChanged: (newValue) {
                            setState(() {
                              receipt.warrantyPeriod = newValue;
                            });
                          },
                        ),
                        onSaved: (double newValue) {
                          receipt.warrantyPeriod = receipt.warrantyPeriod;
                        },
                      ),
                    ],
                  ),
                  TextFormField(
                    decoration: InputDecoration(labelText: 'Notes'),
                    initialValue: receipt.notes,
                    onSaved: (String value) {
                      receipt.notes = value;
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Row(children: _getImageWidgets()),
            ),
          ],
        ),
      ),
    );
  }
}

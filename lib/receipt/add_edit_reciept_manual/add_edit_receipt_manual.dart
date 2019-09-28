import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intelligent_receipt/data_model/category.dart';
import 'package:intelligent_receipt/data_model/currency.dart';
import 'package:intelligent_receipt/data_model/receipt.dart';
import 'package:intelligent_receipt/helper_widgets/date_time_picker.dart';
import 'package:intelligent_receipt/user_repository.dart';

class AddEditReiptForm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: pass this in from review button
    var receipt = Receipt();
    receipt.receiptDatetime = DateTime(2018, 10, 5);
    receipt.productName = 'Petrol';
    receipt.currencyCode = 'AUD';
    receipt.totalAmount = 120;
    receipt.categoryId = categoryList[0].id;
    receipt.companyName = 'Bobs shop';
    receipt.notes = 'Notes text';
    receipt.warrantyPeriod = 36;
    receipt.gstInclusive = true;
    return _AddEditReiptFormState(receipt);
  }
}

class _AddEditReiptFormState extends State<AddEditReiptForm> {
  final _formKey = GlobalKey<FormState>();
  final pageTitleEdit = 'Edit Receipt';
  final pageTitleNew = 'Create Receipt';

  var isNew = true;
  File receiptImage;
  Receipt receipt;
  Currency defaultCurrency;
  var currenciesList = List<Currency>();
  UserRepository _userRepository;

  _AddEditReiptFormState(this.receipt) {
    isNew = this.receipt == null;
    if (isNew) {
      this.receipt = Receipt();
      receipt.receiptDatetime = DateTime.now();
      receipt.totalAmount = 0;
      receipt.categoryId = categoryList[2].id;
      receipt.warrantyPeriod = 0;
      receipt.gstInclusive = true;
    }
  }

  @override
  void initState() {
    _userRepository = RepositoryProvider.of<UserRepository>(context);
    defaultCurrency = _userRepository.settingRepository.getDefaultCurrency();
    super.initState();
  }

  void _deleteReceipt() {
    // TODO handle delete/clear
  }

  void _saveForm() {
    if (this._formKey.currentState.validate()) {
      this._formKey.currentState.save();
    }
    // TODO: Dispatch save action
  }

  String textFieldValidator(value) {
    if (value.isEmpty) {
      return 'Value required';
    }
    return null;
  }

  List<DropdownMenuItem<String>> _getCurrencyCodesList() {
    var list = List<DropdownMenuItem<String>>();
    currenciesList = _userRepository.settingRepository.getCurrencies();

    //Handle none returned
    if (currenciesList.length == 0) {
      currenciesList.add(defaultCurrency);
    }

    for (var currency in currenciesList) {
      list.add(DropdownMenuItem<String>(
          value: currency.code, child: Text(currency.code)));
    }
    return list;
  }

  List<DropdownMenuItem<int>> _getCategorylist() {
    var list = List<DropdownMenuItem<int>>();
    for (var cat in categoryList) {
      list.add(
          DropdownMenuItem<int>(value: cat.id, child: Text(cat.categoryName)));
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
        receiptImage = ri;
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
                child: Image.file(receiptImage, fit: BoxFit.cover),
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

  Future<void> _showFullImage(File image) async {
    await showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            children: <Widget>[
              SimpleDialogOption(
                child: Image.file(image, width: 500,),
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
                          decoration:
                              InputDecoration(labelText: 'Currency Code'),
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

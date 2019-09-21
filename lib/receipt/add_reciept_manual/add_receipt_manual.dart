import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intelligent_receipt/data_model/category.dart';
import 'package:intelligent_receipt/data_model/enums.dart';
import 'package:intelligent_receipt/data_model/receipt.dart';
import 'package:intelligent_receipt/user_repository.dart';
import 'package:intl/intl.dart';

class AddReceiptForm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: pass this in from edit exisiting
    var receipt = Receipt();
    receipt.receiptDatetime = DateTime(2018, 10, 5);
    receipt.productName = 'Petrol';
    receipt.currencyCode = 'AUD';
    receipt.totalAmount = 120;
    receipt.categoryId = CategoryName.Travel.index;
    receipt.companyName = 'Bobs shop';
    receipt.notes = 'Notes text';
    return _AddReceiptFormState(null);
  }
}

class _AddReceiptFormState extends State<AddReceiptForm> {
  final _formKey = GlobalKey<FormState>();
  final pageTitleEdit = 'Edit Receipt';
  final pageTitleNew = 'Create Receipt';
  
  var isNew = true;
  Receipt receipt;
  var defaultCurrencyValue = 'AUD';
  var defaultCategoryValue = categoryMapping[CategoryName.Undecided];
  UserRepository _userRepository;


  _AddReceiptFormState(this.receipt) {
    isNew = this.receipt == null;
    if (isNew) {
      this.receipt = Receipt();
    }
  }

  @override
  void initState() {
    super.initState();
    _userRepository = RepositoryProvider.of<UserRepository>(context);
  }
  
  void deleteReceipt() {
    // TODO handle delete/clear
  }

  void saveForm() {
    if (this._formKey.currentState.validate()) {
      this._formKey.currentState.save();
    }
  }

  String textFieldValidator(value) {
    if (value.isEmpty) {
      return 'Value required';
    }
    return null;
  }

  List<DropdownMenuItem<String>> getCurrencyCodesList() {
    var list = List<DropdownMenuItem<String>>();
    
    var currenciesList = _userRepository.settingRepository.getCurrencies();

    for (var currency in currenciesList) {
      list.add(DropdownMenuItem<String>(value: currency.code, child: Text(currency.code)));
    }


    return list;
  }

  List<DropdownMenuItem<String>> getCategorylist() {
    var list = List<DropdownMenuItem<String>>();
    for (var key in categoryMapping.keys) {
      list.add(DropdownMenuItem<String>(
          value: categoryMapping[key], child: Text(categoryMapping[key])));
    }
    return list;
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
              deleteReceipt();
            },
          ),
          IconButton(
            icon: const Icon(Icons.done),
            onPressed: () {
              this.saveForm();
            },
          )
        ],
      ),
      body: ListView(children: <Widget>[
        Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              DateTimePickerFormField(
                editable: false,
                inputType: InputType.date,
                initialDate: DateTime.now(),
                format: DateFormat("yyyy-MM-dd"),
                decoration: InputDecoration(labelText: 'Purchase Date'),
                initialValue: isNew ? DateTime.now() : receipt.receiptDatetime,
                onSaved: (DateTime value) {
                  this.receipt.receiptDatetime = value;
                },
              ),
              TextFormField(
                initialValue: receipt.productName,
                validator: textFieldValidator,
                decoration: InputDecoration(labelText: 'Product Name'),
                onSaved: (String value) {
                  this.receipt.productName = value;
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Flexible(
                    flex: 7,
                    child: TextFormField(
                      decoration: InputDecoration(labelText: 'Total Amount'),
                      initialValue:
                          isNew ? '0' : receipt.totalAmount.toString(),
                      validator: textFieldValidator,
                      onSaved: (String value) {
                        this.receipt.totalAmount = double.tryParse(value);
                      },
                    ),
                  ),
                  Flexible(
                    flex: 3,
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(labelText: 'Currency Code'),
                      items: getCurrencyCodesList(),
                      value: defaultCurrencyValue,
                      onSaved: (String value) {
                        this.receipt.currencyCode = value;
                      },
                      onChanged: (String newValue) {
                        setState(() {
                          defaultCurrencyValue = newValue;
                        });
                      },
                    ),
                  ),
                ],
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Category'),
                items: getCategorylist(),
                value: defaultCategoryValue,
                onSaved: (String value) {
                  this.receipt.currencyCode = value;
                },
                onChanged: (String newValue) {
                  setState(() {
                    defaultCategoryValue = newValue;
                  });
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Shop/Vendor'),
                initialValue: receipt.companyName,
                validator: textFieldValidator,
                onSaved: (String value) {
                  this.receipt.companyName = value;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Notes'),
                initialValue: receipt.notes,
                onSaved: (String value) {
                  this.receipt.notes = value;
                },
              ),
            ],
          ),
        ),
        Row(
          children: <Widget>[
            Expanded(
              flex: 5,
              child: ClipRect(
                child: Align(
                  alignment: Alignment.topCenter,
                  heightFactor: .4,
                  child: Image.asset('assets/test.jpg', fit: BoxFit.cover), // TODO: load image from db or display 'no image selected'
                ),
            ),
            ),
            Expanded(
              child: Icon(Icons.image),
              flex: 5,
            )
          ],
        )
      ]),
    );
  }
}

import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intelligent_receipt/data_model/receipt.dart';
import 'package:intl/intl.dart';

class AddReceiptForm extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: pass this in from edit exisiting
    var receipt = Receipt();
    receipt.receiptDatetime = DateTime(2018, 10, 5);
    return AddReceiptFormState(receipt);
  }
}

enum ReceiptFormFields {
  PurchaseDate,
  ProductName,
  Price,
  Currency,
  Category,
  Vendor,
  Notes,
  WarrantyPeriod,
  ReturnPeriod
}

class AddReceiptFormState extends State<AddReceiptForm> {
  final _formKey = GlobalKey<FormState>();
  final pageTitleEdit = 'Edit Receipt';
  final pageTitleNew = 'Create Receipt';
  var isNew = true;
  Receipt receipt;

  AddReceiptFormState(this.receipt) {
    isNew = this.receipt == null;
  }

  String textFieldValidator(value) {
    if (value.isEmpty) {
      return 'Enter Text';
    }
    return null;
  }

  String getInitialValue(ReceiptFormFields formField) {
    if (isNew) {
      return null;
    }
    switch (formField) {
      case ReceiptFormFields.ProductName:
        return receipt.productName;
        break;

      case ReceiptFormFields.PurchaseDate:
        return receipt.receiptDatetime.toString();
        break;
      case ReceiptFormFields.Price:
        // TODO: Handle this case.
        break;
      case ReceiptFormFields.Currency:
        // TODO: Handle this case.
        break;
      case ReceiptFormFields.Category:
        // TODO: Handle this case.
        break;
      case ReceiptFormFields.Vendor:
        // TODO: Handle this case.
        break;
      case ReceiptFormFields.Notes:
        // TODO: Handle this case.
        break;
      case ReceiptFormFields.WarrantyPeriod:
        // TODO: Handle this case.
        break;
      case ReceiptFormFields.ReturnPeriod:
        // TODO: Handle this case.
        break;
    }
  }

  // DateTime getDate(BuildContext context){
  //   var date = showDatePicker(context: context, initialDate: DateTime.now());
  //   return date.then(onValue);
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isNew ? pageTitleNew : pageTitleEdit),
      ),
      body: Center(
        child: Form(
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
              ),
              TextFormField(
                initialValue: getInitialValue(ReceiptFormFields.ProductName),
                validator: textFieldValidator,
                decoration: InputDecoration(labelText: 'Product Name'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:intl/intl.dart';
import 'dart:io';
import 'package:intl/date_symbol_data_local.dart';

DateFormat getDateFormatForYMD() {
  String currentLocale = Platform.localeName;
  if (currentLocale == null) {
    currentLocale = "en_AU";
  }

  // Get the moment, we hard code the data format; but later we will intialize date format based on locale or setting
  return DateFormat("dd/MM/yyyy");
}

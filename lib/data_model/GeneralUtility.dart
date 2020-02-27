import 'package:intl/intl.dart';
import 'dart:io';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

DateFormat getDateFormatForYMD() {
  String currentLocale = Platform.localeName;
  if (currentLocale == null) {
    currentLocale = "en_AU";
  }

  // Get the moment, we hard code the data format; but later we will intialize date format based on locale or setting
  return DateFormat("dd/MM/yyyy");
}

Future<File> compressImage(File originalImage) async {
  int origFileSize = originalImage.lengthSync();
  File compressedFile = null;
  // Compress image to a temporary file
  String dir = (await getTemporaryDirectory()).path;
  var uuid = Uuid();
  String tmpFilePath =  dir + "/" + uuid.v1() + ".jpg";

  print("Original file size: " + origFileSize.toString());
  if (origFileSize <= 500000) {
  // Don't compress a file, if it is less than 500KB
  compressedFile = await originalImage.copy(tmpFilePath);
  } else if (origFileSize <= 1000000) {
  compressedFile = await FlutterImageCompress.compressAndGetFile(originalImage.path, tmpFilePath, quality: 90);
  } else if (origFileSize <= 3000000) {
  compressedFile = await FlutterImageCompress.compressAndGetFile(originalImage.path, tmpFilePath, quality: 80);
  } else if (origFileSize <= 5000000) {
  compressedFile = await FlutterImageCompress.compressAndGetFile(originalImage.path, tmpFilePath, quality: 60);
  } else {
  compressedFile = await FlutterImageCompress.compressAndGetFile(originalImage.path, tmpFilePath, quality: 40);
  }
  print("Compressed file size: " + compressedFile.lengthSync().toString());

  return compressedFile;
}
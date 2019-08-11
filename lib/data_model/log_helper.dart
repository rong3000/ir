import 'package:f_logs/model/flog/flog.dart';
import 'dart:developer' as developer;
import 'dart:convert';
import 'package:logging/logging.dart';

// Mainly use this log for run time logging, log exception scenarios
class LogHepper {
  static void init() {
  }

  static void info(Object message, {String module: "", saveToFile: false}) async{

    String messageStr = message == null ? "" : jsonEncode(message);
    developer.log(messageStr, name: module, level: Level.INFO.value);
    if (saveToFile) {
      FLog.info(text: messageStr, className: module, methodName: "");
    }
  }

  static void warning(Object message, {String module: "", saveToFile: false}) async{
    String messageStr = message == null ? "" : jsonEncode(message);
    developer.log(messageStr, name: module, level: Level.WARNING.value);
    if (saveToFile) {
      FLog.warning(text: messageStr, className: module, methodName: "");
    }
  }

  static void error(Object message, {String module: "", saveToFile: false}) async{
    String messageStr = message == null ? "" : jsonEncode(message);
    developer.log(messageStr, name: module, level: Level.SEVERE.value);
    if (saveToFile) {
      FLog.error(text: messageStr, className: module, methodName: "");
    }
  }
}
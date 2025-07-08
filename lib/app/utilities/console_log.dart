import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

enum LogType { debug, error, info, warning, trace }

// Log something into console log on debug or development mode
void cl(
  dynamic text, {
  String? title,
  Object? json,
  LogType type = LogType.info,
}) {
  if (!kDebugMode) return;

  var logger = Logger(printer: PrettyPrinter());

  var message =
      '${title != null ? ('$title :') : ''}$text ${json != null ? jsonPrettier(json) : ''}';

  if (type == LogType.debug) {
    return logger.d(message);
  }

  if (type == LogType.error) {
    return logger.e(message);
  }

  if (type == LogType.info) {
    return logger.i(message);
  }

  if (type == LogType.warning) {
    return logger.w(message);
  }

  if (type == LogType.trace) {
    return logger.t(message);
  }
}

String jsonPrettier(Object? jsonObject) {
  var encoder = const JsonEncoder.withIndent('     ');
  return encoder.convert(jsonObject);
}

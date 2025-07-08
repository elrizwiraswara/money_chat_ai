import 'package:intl/intl.dart';

// For develompment purpose
String dateNow = DateTime.now().toIso8601String();

// DateTime Formatter
class DateFormatter {
  DateFormatter._();

  static DateTime subtractMonths(DateTime date, int months) {
    int newYear = date.year;
    int newMonth = date.month - months;

    // Handle negative months by adjusting year
    while (newMonth <= 0) {
      newMonth += 12;
      newYear -= 1;
    }

    // Get the last day of the target month
    final lastDayOfNewMonth = DateTime(newYear, newMonth + 1, 0).day;

    // Preserve time components while adjusting day if necessary
    final newDay = date.day > lastDayOfNewMonth ? lastDayOfNewMonth : date.day;

    return DateTime(
      newYear,
      newMonth,
      newDay,
      date.hour,
      date.minute,
      date.second,
      date.millisecond,
      date.microsecond,
    );
  }

  static DateTime addMonths(DateTime date, int monthsToAdd) {
    // Calculate new year and month
    int totalMonths = date.month + monthsToAdd;
    int newYear = date.year + ((totalMonths - 1) ~/ 12);
    int newMonth = ((totalMonths - 1) % 12) + 1;

    // Get the last day of the target month
    final lastDayOfNewMonth = DateTime(newYear, newMonth + 1, 0).day;

    // Preserve time components while adjusting day if necessary
    final newDay = date.day > lastDayOfNewMonth ? lastDayOfNewMonth : date.day;

    return DateTime(
      newYear,
      newMonth,
      newDay,
      date.hour,
      date.minute,
      date.second,
      date.millisecond,
      date.microsecond,
    );
  }

  static String normal(String iso8601String) {
    var parsedDate = DateTime.tryParse(iso8601String);

    if (parsedDate == null) {
      return '(Invalid date format)';
    }

    return DateFormat('d MMMM y').format(parsedDate);
  }

  static String normalWithClock(String iso8601String) {
    var parsedDate = DateTime.tryParse(iso8601String);

    if (parsedDate == null) {
      return '(Invalid date format)';
    }

    return DateFormat('d MMMM y • HH:mm').format(parsedDate);
  }

  static String slashDateWithClock(String iso8601String) {
    var parsedDate = DateTime.tryParse(iso8601String);

    if (parsedDate == null) {
      return '(Invalid date format)';
    }

    return DateFormat('dd/MM/y • HH:mm').format(parsedDate);
  }

  static String onlyMonthAndYear(String iso8601String) {
    var parsedDate = DateTime.tryParse(iso8601String);

    if (parsedDate == null) {
      return '(Invalid date format)';
    }

    return DateFormat('MMMM yyyy').format(parsedDate);
  }
}

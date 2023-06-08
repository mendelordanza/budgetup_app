import 'package:intl/intl.dart';

import '../presentation/date_filter/date_bottom_sheet.dart';

removeTimeFromDate(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}

getMonthFromDate(DateTime date) {
  return DateFormat.MMMM().format(date);
}

getYearFromDate(DateTime date) {
  return DateFormat.y().format(date);
}

formatDate(DateTime date, String pattern) {
  final formatter =
      DateFormat(pattern); // Replace with your desired date format
  return formatter.format(date);
}

getStartDate(DateTime date) {
  // Get the first day of the week (Sunday)
  final startOfWeek = date.subtract(Duration(days: date.weekday - 1));

  return startOfWeek;
}

getEndDate(DateTime date) {
  // Get the first day of the week (Sunday)
  final startOfWeek = date.subtract(Duration(days: date.weekday - 1));

  // Get the last day of the week (Saturday)
  final endOfWeek = startOfWeek.add(Duration(days: 6));

  return endOfWeek;
}

String getMonthText(DateFilterType dateFilterType, DateTime date) {
  switch (dateFilterType) {
    case DateFilterType.daily:
      if (date.day == DateTime.now().day) {
        return "Today";
      } else {
        return "${formatDate(date, 'MMM dd, yyyy')}";
      }
    case DateFilterType.weekly:
      if (DateTime.now().isAfter(getStartDate(date)) &&
          DateTime.now().isBefore(getEndDate(date))) {
        return "This week";
      } else {
        return "${formatDate(getStartDate(date), 'MM/dd/yyyy')} - ${formatDate(getEndDate(date), 'MM/dd/yyyy')}";
      }
    case DateFilterType.monthly:
      if (date.month == DateTime.now().month) {
        return "This month";
      } else {
        return getMonthFromDate(date);
      }
    case DateFilterType.yearly:
      if (date.year == DateTime.now().year) {
        return "This year";
      } else {
        return getYearFromDate(date);
      }
  }
}

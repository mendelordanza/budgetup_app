import 'package:intl/intl.dart';

removeTimeFromDate(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}

getMonthFromDate(DateTime date) {
  return DateFormat.MMMM().add_y().format(date);
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

getFirstDayOfMonth(DateTime date) {
  return DateTime(date.year, date.month, 1);
}

DateTime getLastDayOfMonth(DateTime date) {
  return DateTime(date.year, date.month + 1, 0);
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
        return "${formatDate(getStartDate(date), 'MMM dd, yyyy')} - ${formatDate(getEndDate(date), 'MMM dd, yyyy')}";
      }
    case DateFilterType.monthly:
      if (date.month == DateTime.now().month) {
        return "This month - ${formatDate(date, 'MMMM yyyy')}";
      } else {
        return "${formatDate(date, 'MMMM yyyy')}";
      }
  }
}

enum DateFilterType {
  daily,
  weekly,
  monthly,
}

class DateSelection {
  final String label;
  final DateFilterType type;

  DateSelection(this.label, this.type);
}

DateFilterType dateFilterTypeFromString(String value) {
  return DateFilterType.values
      .firstWhere((e) => e.toString().split('.').last == value);
}

String getDayOfMonthSuffix(int dayNum) {
  if (!(dayNum >= 1 && dayNum <= 31)) {
    throw Exception('Invalid day of month');
  }

  if (dayNum >= 11 && dayNum <= 13) {
    return 'th';
  }

  switch (dayNum % 10) {
    case 1:
      return 'st';
    case 2:
      return 'nd';
    case 3:
      return 'rd';
    default:
      return 'th';
  }
}

List<DateTime> generateMonthList(int year) {
  List<DateTime> months = [];
  for (int i = 1; i <= 12; i++) {
    DateTime lastDayOfMonth = DateTime(year, i + 1, 0);
    months.add(lastDayOfMonth);
  }
  return months;
}

List<DateTime> getPrevMonths(int year) {
  final now = DateTime.now();
  final currentYear = now.year;
  final currentMonth = now.month;

  if (year > currentYear) {
    return List.empty();
  } else if (year == currentYear) {
    return List<DateTime>.generate(currentMonth, (index) {
      return DateTime(now.year, (index + 1) + 1, 0);
    }).reversed.toList();
  } else {
    return List<DateTime>.generate(12, (index) {
      return DateTime(year, (index + 1) + 1, 0);
    }).reversed.toList();
  }
}

bool isWithin30Days(DateTime date) {
  DateTime currentDate = DateTime.now();
  DateTime thirtyDaysFromNow = currentDate.add(Duration(days: 30));

  return date.isAfter(currentDate) && date.isBefore(thirtyDaysFromNow);
}

int getNextMonthDate(DateTime currentDate) {
  int currentMonth = currentDate.month;

  // Calculate the next month
  int nextMonth = currentMonth + 1;

  if (nextMonth > 12) {
    nextMonth = 1;
  }

  // Handle the case where the current date has already passed
  if (currentDate.day > 1) {
    nextMonth -= 1;
    if (nextMonth == 0) {
      nextMonth = 12;
    }
  }

  return nextMonth;
}

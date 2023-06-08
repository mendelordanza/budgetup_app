import 'package:shared_preferences/shared_preferences.dart';

import 'date_helper.dart';

class SharedPrefs {
  static SharedPreferences? _preferences;

  static Future init() async =>
      _preferences = await SharedPreferences.getInstance();

  static const String KEY_IS_FINISHED = "key_is_finished";
  static const String KEY_FIRST_INSTALL = "key_first_install";
  static const String KEY_EXPENSE_SELECTED_DATE = "key_expense_selected_date";
  static const String KEY_EXPENSE_DATE_FILTER = "key_expense_date_filter";
  static const String KEY_RECURRING_SELECTED_DATE =
      "key_recurring_selected_date";
  static const String KEY_RECURRING_DATE_FILTER = "key_recurring_date_filter";

  Future setFinishedOnboarding(bool isFinished) async {
    await _preferences?.setBool(KEY_IS_FINISHED, isFinished);
  }

  bool? getFinishedOnboarding() => _preferences?.getBool(KEY_IS_FINISHED);

  Future setExpenseSelectedDate(String dateString) async {
    await _preferences?.setString(KEY_EXPENSE_SELECTED_DATE, dateString);
  }

  String getExpenseSelectedDate() =>
      _preferences?.getString(KEY_EXPENSE_SELECTED_DATE) ??
      DateTime.now().toIso8601String();

  Future setSelectedDateFilterType(DateFilterType dateFilterType) async {
    await _preferences?.setString(KEY_EXPENSE_DATE_FILTER, dateFilterType.name);
  }

  String getSelectedDateFilterType() =>
      _preferences?.getString(KEY_EXPENSE_DATE_FILTER) ??
      DateFilterType.monthly.name;

  Future setRecurringSelectedDate(String dateString) async {
    await _preferences?.setString(KEY_RECURRING_SELECTED_DATE, dateString);
  }

  String getRecurringSelectedDate() =>
      _preferences?.getString(KEY_RECURRING_SELECTED_DATE) ??
      DateTime.now().toIso8601String();

  Future setRecurringSelectedDateFilterType(
      DateFilterType dateFilterType) async {
    await _preferences?.setString(
        KEY_RECURRING_DATE_FILTER, dateFilterType.name);
  }

  String getRecurringSelectedDateFilterType() =>
      _preferences?.getString(KEY_RECURRING_DATE_FILTER) ??
      DateFilterType.monthly.name;
}

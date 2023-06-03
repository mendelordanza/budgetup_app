
import 'package:budgetup_app/presentation/date_filter/date_bottom_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  static SharedPreferences? _preferences;

  static Future init() async =>
      _preferences = await SharedPreferences.getInstance();

  static const String KEY_IS_FINISHED = "key_is_finished";
  static const String KEY_FIRST_INSTALL = "key_first_install";
  static const String KEY_DATE_FILTER = "key_date_filter";
  static const String KEY_SELECTED_DATE = "key_selected_date";

  Future setFinishedOnboarding(bool isFinished) async {
    await _preferences?.setBool(KEY_IS_FINISHED, isFinished);
  }

  bool? getFinishedOnboarding() => _preferences?.getBool(KEY_IS_FINISHED);

  Future setSelectedDate(String dateString) async {
    await _preferences?.setString(KEY_SELECTED_DATE, dateString);
  }

  String getSelectedDate() => _preferences?.getString(KEY_SELECTED_DATE) ?? "";

  Future setSelectedDateFilterType(DateFilterType dateFilterType) async {
    await _preferences?.setString(KEY_DATE_FILTER, dateFilterType.name);
  }

  String getSelectedDateFilterType() =>
      _preferences?.getString(KEY_DATE_FILTER) ?? "";
}

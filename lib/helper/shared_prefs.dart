import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  static SharedPreferences? _preferences;

  static Future init() async =>
      _preferences = await SharedPreferences.getInstance();

  static const String KEY_IS_FINISHED = "key_is_finished";
  static const String KEY_FIRST_INSTALL = "key_first_install";

  Future setFinishedOnboarding(bool isFinished) async {
    await _preferences?.setBool(KEY_IS_FINISHED, isFinished);
  }

  bool? getFinishedOnboarding() => _preferences?.getBool(KEY_IS_FINISHED);

  Future setFirstInstall(bool firstInstall) async {
    await _preferences?.setBool(KEY_FIRST_INSTALL, firstInstall);
  }

  bool getFirstInstall() => _preferences?.getBool(KEY_FIRST_INSTALL) ?? true;
}

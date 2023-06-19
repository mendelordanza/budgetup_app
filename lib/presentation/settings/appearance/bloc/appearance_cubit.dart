import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import '../../../../helper/shared_prefs.dart';
import '../appearance_page.dart';

part 'appearance_state.dart';

AppearanceType appearanceTypeFromString(String value) {
  return AppearanceType.values
      .firstWhere((e) => e.toString().split('.').last == value);
}

class AppearanceCubit extends Cubit<AppearanceState> {
  final SharedPrefs sharedPrefs;

  AppearanceCubit({
    required this.sharedPrefs,
  }) : super(AppearanceInitial()) {
    loadCurrentApperance();
  }

  loadCurrentApperance() {
    switch (appearanceTypeFromString(sharedPrefs.getAppearance())) {
      case AppearanceType.dark:
        emit(AppearanceLoaded(themeMode: ThemeMode.dark));
        break;
      case AppearanceType.light:
        emit(AppearanceLoaded(themeMode: ThemeMode.light));
        break;
      case AppearanceType.system:
        emit(AppearanceLoaded(themeMode: ThemeMode.system));
        break;
    }
  }

  setAppearance(AppearanceType appearance) {
    sharedPrefs.setAppearance(appearance.name);
    switch (appearance) {
      case AppearanceType.dark:
        emit(AppearanceLoaded(themeMode: ThemeMode.dark));
        break;
      case AppearanceType.light:
        emit(AppearanceLoaded(themeMode: ThemeMode.light));
        break;
      case AppearanceType.system:
        emit(AppearanceLoaded(themeMode: ThemeMode.system));
        break;
    }
  }
}

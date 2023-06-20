part of 'appearance_cubit.dart';

@immutable
abstract class AppearanceState {}

class AppearanceInitial extends AppearanceState {}

class AppearanceLoaded extends AppearanceState {
  final ThemeMode themeMode;

  AppearanceLoaded({this.themeMode = ThemeMode.system});
}

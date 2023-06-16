part of 'convert_currency_cubit.dart';

@immutable
abstract class ConvertCurrencyState {}

class ConvertCurrencyInitial extends ConvertCurrencyState {}

class ConvertedCurrencyLoaded extends ConvertCurrencyState {
  final String currencyCode;
  final double currencyRate;

  ConvertedCurrencyLoaded(this.currencyCode, this.currencyRate);
}

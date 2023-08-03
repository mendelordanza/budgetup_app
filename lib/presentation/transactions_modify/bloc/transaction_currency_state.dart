part of 'transaction_currency_bloc.dart';

@immutable
abstract class TransactionCurrencyState {}

class TransactionCurrencyInitial extends TransactionCurrencyState {}

class LoadingTxnCurrency extends TransactionCurrencyState {}

class TxnCurrencyLoaded extends TransactionCurrencyState {
  final String currencyCode;
  final String currencySymbol;
  final double currencyRate;

  TxnCurrencyLoaded(
    this.currencyCode,
    this.currencySymbol,
    this.currencyRate,
  );
}

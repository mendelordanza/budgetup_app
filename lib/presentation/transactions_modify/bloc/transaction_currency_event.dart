part of 'transaction_currency_bloc.dart';

@immutable
abstract class TransactionCurrencyEvent {}

class LoadTxnCurrency extends TransactionCurrencyEvent {}

class SelectTxnCurrency extends TransactionCurrencyEvent {
  final String currencyCode;
  final String currencySymbol;

  SelectTxnCurrency(
    this.currencyCode,
    this.currencySymbol,
  );
}

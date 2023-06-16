part of 'expense_txn_bloc.dart';

abstract class ExpenseTxnEvent {
  const ExpenseTxnEvent();
}

//Transactions
//Load Transactions
class LoadExpenseTxns extends ExpenseTxnEvent {
  final int categoryId;

  LoadExpenseTxns({required this.categoryId});
}

//Convert
class ConvertTxn extends ExpenseTxnEvent {
  final String currencyCode;
  final double currencyRate;

  ConvertTxn({
    required this.currencyCode,
    required this.currencyRate,
  });
}

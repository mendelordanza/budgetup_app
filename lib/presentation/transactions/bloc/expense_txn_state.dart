part of 'expense_txn_bloc.dart';

abstract class ExpenseTxnState {
  const ExpenseTxnState();
}

class ExpenseTxnInitial extends ExpenseTxnState {}

class ExpenseTxnLoaded extends ExpenseTxnState {
  final double total;
  final List<ExpenseTxn> expenseTxns;

  ExpenseTxnLoaded({
    this.total = 0.00,
    required this.expenseTxns,
  });
}

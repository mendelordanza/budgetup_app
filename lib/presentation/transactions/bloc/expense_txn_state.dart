part of 'expense_txn_bloc.dart';

abstract class ExpenseTxnState {
  const ExpenseTxnState();
}

class ExpenseTxnInitial extends ExpenseTxnState {
}

class ExpenseTxnLoaded extends ExpenseTxnState {
  final List<ExpenseTxn> expenseTxns;

  ExpenseTxnLoaded({
    required this.expenseTxns,
  });
}
part of 'transactions_modify_bloc.dart';

@immutable
abstract class TransactionsModifyState {}

class TransactionsModifyInitial extends TransactionsModifyState {}

class ExpenseTxnAdded extends TransactionsModifyState {
  final ExpenseCategory expenseCategory;

  ExpenseTxnAdded(this.expenseCategory);
}

class ExpenseTxnEdited extends TransactionsModifyState {
  final ExpenseCategory expenseCategory;

  ExpenseTxnEdited(this.expenseCategory);
}

class ExpenseTxnRemoved extends TransactionsModifyState {
  final ExpenseCategory expenseCategory;

  ExpenseTxnRemoved(this.expenseCategory);
}

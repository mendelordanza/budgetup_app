part of 'transactions_modify_bloc.dart';

@immutable
abstract class TransactionsModifyEvent {}

//Add Transaction
class AddExpenseTxn extends TransactionsModifyEvent {
  final ExpenseCategory expenseCategory;
  final ExpenseTxn expenseTxn;

  AddExpenseTxn({required this.expenseCategory, required this.expenseTxn});
}

//Edit Transaction
class EditExpenseTxn extends TransactionsModifyEvent {
  final ExpenseCategory expenseCategory;
  final ExpenseTxn expenseTxn;

  EditExpenseTxn({required this.expenseCategory, required this.expenseTxn});
}

//Remove Transaction
class RemoveExpenseTxn extends TransactionsModifyEvent {
  final ExpenseCategory expenseCategory;
  final ExpenseTxn expenseTxn;

  RemoveExpenseTxn({required this.expenseCategory, required this.expenseTxn});
}

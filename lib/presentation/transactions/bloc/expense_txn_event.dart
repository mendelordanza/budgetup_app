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

//Add Transaction
class AddExpenseTxn extends ExpenseTxnEvent {
  final ExpenseCategory expenseCategory;
  final ExpenseTxn expenseTxn;

  AddExpenseTxn({required this.expenseCategory, required this.expenseTxn});
}

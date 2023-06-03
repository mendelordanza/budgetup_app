part of 'expense_bloc.dart';

abstract class ExpenseEvent {
  const ExpenseEvent();
}

//Load Categories
class LoadExpenseCategories extends ExpenseEvent {
  final DateTime selectedDate;

  LoadExpenseCategories(this.selectedDate);
}

//Add Expense Category
class AddExpenseCategory extends ExpenseEvent {
  final ExpenseCategory expenseCategory;

  AddExpenseCategory({required this.expenseCategory});
}

//Edit Expense Category
class EditExpenseCategory extends ExpenseEvent {
  final ExpenseCategory expenseCategory;

  EditExpenseCategory({required this.expenseCategory});
}

//Remove Expense Category
class RemoveExpenseCategory extends ExpenseEvent {
  final ExpenseCategory expenseCategory;

  RemoveExpenseCategory({required this.expenseCategory});
}

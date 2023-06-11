part of 'expenses_modify_bloc.dart';

@immutable
abstract class ModifyExpensesEvent {}

//Add Expense Category
class AddExpenseCategory extends ModifyExpensesEvent {
  final ExpenseCategory expenseCategory;

  AddExpenseCategory({required this.expenseCategory});
}

//Edit Expense Category
class EditExpenseCategory extends ModifyExpensesEvent {
  final ExpenseCategory expenseCategory;

  EditExpenseCategory({required this.expenseCategory});
}

//Remove Expense Category
class RemoveExpenseCategory extends ModifyExpensesEvent {
  final ExpenseCategory expenseCategory;

  RemoveExpenseCategory({required this.expenseCategory});
}
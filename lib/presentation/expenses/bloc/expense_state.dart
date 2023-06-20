part of 'expense_bloc.dart';

abstract class ExpenseState {
  const ExpenseState();
}

//Categories
class ExpenseCategoryInitial extends ExpenseState {}

class ExpenseCategoryLoaded extends ExpenseState {
  final List<ExpenseCategory> expenseCategories;
  final double total;
  final double totalBudget;

  ExpenseCategoryLoaded(
      {required this.expenseCategories,
      this.total = 0.00,
      this.totalBudget = 0.00});
}

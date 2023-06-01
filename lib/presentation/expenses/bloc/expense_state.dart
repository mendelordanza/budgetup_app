part of 'expense_bloc.dart';

abstract class ExpenseState {
  const ExpenseState();
}

//Categories
class ExpenseCategoryInitial extends ExpenseState {}

class ExpenseCategoryLoaded extends ExpenseState {
  final List<ExpenseCategory> expenseCategories;

  ExpenseCategoryLoaded({required this.expenseCategories});
}

part of 'expense_bloc.dart';

abstract class ExpenseEvent {
  const ExpenseEvent();
}

//Load Categories
class LoadExpenseCategories extends ExpenseEvent {
  final DateFilterType? dateFilterType;
  final DateTime? selectedDate;

  LoadExpenseCategories({this.dateFilterType, this.selectedDate});
}


class ViewCategory extends ExpenseEvent {
  final ExpenseCategory expenseCategory;

  ViewCategory({required this.expenseCategory});
}

//Convert Expense Budget
class ConvertExpenseBudget extends ExpenseEvent {
  final String currencyCode;
  final double currencyRate;

  ConvertExpenseBudget({
    required this.currencyCode,
    required this.currencyRate,
  });
}

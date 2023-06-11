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

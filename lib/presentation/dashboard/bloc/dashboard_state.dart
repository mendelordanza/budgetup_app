part of 'dashboard_cubit.dart';

@immutable
abstract class DashboardState {}

class DashboardInitial extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final double overallTotal;

  final ExpenseCategory? mostSpentCategory;

  final List<ExpenseCategory> expensesCategories;
  final double expensesTotal;

  final List<RecurringBill> paidRecurringBills;
  final double recurringBillTotal;

  DashboardLoaded({
    this.overallTotal = 0.00,
    this.mostSpentCategory,
    required this.expensesCategories,
    this.expensesTotal = 0.00,
    required this.paidRecurringBills,
    this.recurringBillTotal = 0.00,
  });
}

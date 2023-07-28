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

  final double initialSalary;
  final double remainingSalary;

  DashboardLoaded({
    required this.expensesCategories,
    required this.paidRecurringBills,
    this.overallTotal = 0.00,
    this.mostSpentCategory,
    this.expensesTotal = 0.00,
    this.recurringBillTotal = 0.00,
    this.initialSalary = 0.00,
    this.remainingSalary = 0.00,
  });
}

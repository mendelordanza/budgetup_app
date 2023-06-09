part of 'dashboard_cubit.dart';

@immutable
abstract class DashboardState {}

class DashboardInitial extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final List<ExpenseCategory> dashboardCategories;
  final double dashboardTotal;

  final List<RecurringBill> paidRecurringBills;
  final double recurringBillTotal;

  DashboardLoaded({
    required this.dashboardCategories,
    this.dashboardTotal = 0.0,
    required this.paidRecurringBills,
    this.recurringBillTotal = 0.0,
  });
}

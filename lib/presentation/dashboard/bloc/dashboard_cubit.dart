import 'package:bloc/bloc.dart';
import 'package:budgetup_app/data/expenses_repository.dart';
import 'package:meta/meta.dart';

import '../../../data/recurring_bills_repository.dart';
import '../../../domain/expense_category.dart';
import '../../../domain/recurring_bill.dart';
import '../../../helper/date_helper.dart';

part 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final ExpensesRepository expensesRepository;
  final RecurringBillsRepository recurringBillsRepository;

  DashboardCubit({
    required this.expensesRepository,
    required this.recurringBillsRepository,
  }) : super(DashboardInitial());

  getSummary() async {
    final dashboardCategories =
        await expensesRepository.getExpenseCategoriesByDate(DateTime.now());

    var dashboardTotal = 0.0;
    dashboardCategories.forEach((element) {
      dashboardTotal +=
          element.getTotal(DateFilterType.monthly, DateTime.now());
    });

    final paidRecurringBills =
        await recurringBillsRepository.getPaidRecurringBills(DateTime.now());

    var recurringBillTotal = 0.0;
    paidRecurringBills.forEach((element) {
      recurringBillTotal += element.amount ?? 0.0;
    });

    emit(
      DashboardLoaded(
        dashboardCategories: dashboardCategories,
        dashboardTotal: dashboardTotal,
        paidRecurringBills: paidRecurringBills,
        recurringBillTotal: recurringBillTotal,
      ),
    );
  }
}

import 'package:bloc/bloc.dart';
import 'package:budgetup_app/data/expenses_repository.dart';
import 'package:budgetup_app/helper/shared_prefs.dart';
import 'package:meta/meta.dart';

import '../../../data/recurring_bills_repository.dart';
import '../../../data/salary_repository.dart';
import '../../../domain/expense_category.dart';
import '../../../domain/recurring_bill.dart';
import '../../../helper/date_helper.dart';

part 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final SharedPrefs sharedPrefs;
  final ExpensesRepository expensesRepository;
  final RecurringBillsRepository recurringBillsRepository;
  final SalaryRepository salaryRepository;

  DashboardCubit({
    required this.sharedPrefs,
    required this.expensesRepository,
    required this.recurringBillsRepository,
    required this.salaryRepository,
  }) : super(DashboardInitial());

  getSummary(DateTime date) async {
    final dashboardCategories =
        await expensesRepository.getExpenseCategoriesByDate(date);

    //MOST SPENT CATEGORY
    ExpenseCategory? mostSpentCategory;
    if (dashboardCategories.isNotEmpty) {
      mostSpentCategory = dashboardCategories.reduce((value, element) {
        final a = value.getTotalByDate(DateFilterType.monthly, date);
        final b = element.getTotalByDate(DateFilterType.monthly, date);
        if (a > b) {
          return value;
        } else {
          return element;
        }
      });
    }

    var expensesTotal = 0.0;
    dashboardCategories.forEach((element) {
      final totalByDate = element.getTotalByDate(DateFilterType.monthly, date);
      expensesTotal += totalByDate;
    });

    final paidRecurringBills = await recurringBillsRepository
        .getPaidRecurringBills(DateFilterType.monthly, date);

    var recurringBillTotal = 0.0;
    paidRecurringBills.forEach((element) {
      recurringBillTotal += element.amount ?? 0.0;
    });

    //SALARY
    var initialSalary = 0.00;
    var remainingSalary = 0.00;
    final salary = await salaryRepository.getSalaryByDate(date);
    if (salary != null) {
      initialSalary = salary.amount ?? 0.00;
      remainingSalary = initialSalary - expensesTotal - recurringBillTotal;
    }

    emit(
      DashboardLoaded(
        overallTotal: expensesTotal + recurringBillTotal,
        mostSpentCategory: mostSpentCategory,
        expensesCategories: dashboardCategories,
        expensesTotal: expensesTotal,
        paidRecurringBills: paidRecurringBills,
        recurringBillTotal: recurringBillTotal,
        initialSalary: initialSalary,
        remainingSalary: remainingSalary,
      ),
    );
  }
}

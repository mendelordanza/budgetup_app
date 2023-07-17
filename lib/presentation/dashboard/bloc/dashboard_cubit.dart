import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:budgetup_app/data/expenses_repository.dart';
import 'package:budgetup_app/helper/shared_prefs.dart';
import 'package:budgetup_app/presentation/recurring_modify/bloc/recurring_modify_bloc.dart';
import 'package:budgetup_app/presentation/transactions_modify/bloc/transactions_modify_bloc.dart';
import 'package:meta/meta.dart';

import '../../../data/recurring_bills_repository.dart';
import '../../../domain/expense_category.dart';
import '../../../domain/recurring_bill.dart';
import '../../../helper/date_helper.dart';

part 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final SharedPrefs sharedPrefs;
  final ExpensesRepository expensesRepository;
  final RecurringBillsRepository recurringBillsRepository;
  final TransactionsModifyBloc transactionsModifyBloc;
  final RecurringModifyBloc recurringModifyBloc;
  StreamSubscription? _expenseTxnSubscription;

  DashboardCubit({
    required this.sharedPrefs,
    required this.expensesRepository,
    required this.recurringBillsRepository,
    required this.transactionsModifyBloc,
    required this.recurringModifyBloc,
  }) : super(DashboardInitial());

  @override
  Future<void> close() async {
    _expenseTxnSubscription?.cancel();
    return super.close();
  }

  getSummary(DateTime date) async {
    final dashboardCategories =
        await expensesRepository.getExpenseCategoriesByDate(date);

    final mostSpentCategory = dashboardCategories.reduce((value, element) {
      final a = value.getTotalByDate(DateFilterType.monthly, date);
      final b = element.getTotalByDate(DateFilterType.monthly, date);
      if (a > b) {
        return value;
      } else {
        return element;
      }
    });

    final convertedMostSpentCategory = mostSpentCategory.copy(
        budget: sharedPrefs.getCurrencyCode() == "USD"
            ? (mostSpentCategory.budget ?? 0.00)
            : (mostSpentCategory.budget ?? 0.00) *
                sharedPrefs.getCurrencyRate(),
        expenseTransactions: mostSpentCategory.expenseTransactions?.map((txn) {
          final convertedAmount = sharedPrefs.getCurrencyCode() == "USD"
              ? (txn.amount ?? 0.00)
              : (txn.amount ?? 0.00) * sharedPrefs.getCurrencyRate();
          final newTxn = txn.copy(
            amount: convertedAmount,
          );
          return newTxn;
        }).toList());

    final convertedCategories = dashboardCategories.map((category) {
      final convertedBudget = sharedPrefs.getCurrencyCode() == "USD"
          ? (category.budget ?? 0.00)
          : (category.budget ?? 0.00) * sharedPrefs.getCurrencyRate();

      final convertedTxns = category.expenseTransactions?.map((txn) {
        final convertedAmount = sharedPrefs.getCurrencyCode() == "USD"
            ? (txn.amount ?? 0.00)
            : (txn.amount ?? 0.00) * sharedPrefs.getCurrencyRate();
        final newTxn = txn.copy(
          amount: convertedAmount,
        );
        return newTxn;
      }).toList();

      final newCategory = category.copy(
        budget: convertedBudget,
        expenseTransactions: convertedTxns,
      );

      return newCategory;
    }).toList();

    var expensesTotal = 0.0;
    convertedCategories.forEach((element) {
      final totalByDate = element.getTotalByDate(DateFilterType.monthly, date);
      expensesTotal += totalByDate;
    });

    final paidRecurringBills =
        await recurringBillsRepository.getPaidRecurringBills(date);

    final convertedPaidRecurringBills = paidRecurringBills.map((bill) {
      final convertedAmount = sharedPrefs.getCurrencyCode() == "USD"
          ? (bill.amount ?? 0.00)
          : (bill.amount ?? 0.00) * sharedPrefs.getCurrencyRate();
      return bill.copy(amount: convertedAmount);
    }).toList();

    var recurringBillTotal = 0.0;
    convertedPaidRecurringBills.forEach((element) {
      recurringBillTotal += element.amount ?? 0.0;
    });

    emit(
      DashboardLoaded(
        overallTotal: expensesTotal + recurringBillTotal,
        mostSpentCategory: convertedMostSpentCategory,
        expensesCategories: convertedCategories,
        expensesTotal: expensesTotal,
        paidRecurringBills: convertedPaidRecurringBills,
        recurringBillTotal: recurringBillTotal,
      ),
    );
  }
}

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:budgetup_app/data/expenses_repository.dart';
import 'package:budgetup_app/presentation/transactions_modify/bloc/transactions_modify_bloc.dart';
import 'package:meta/meta.dart';

import '../../../data/recurring_bills_repository.dart';
import '../../../domain/expense_category.dart';
import '../../../domain/recurring_bill.dart';
import '../../../helper/date_helper.dart';

part 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final ExpensesRepository expensesRepository;
  final RecurringBillsRepository recurringBillsRepository;
  final TransactionsModifyBloc transactionsModifyBloc;
  StreamSubscription? _expenseTxnSubscription;

  DashboardCubit({
    required this.expensesRepository,
    required this.recurringBillsRepository,
    required this.transactionsModifyBloc,
  }) : super(DashboardInitial()) {
    _expenseTxnSubscription = transactionsModifyBloc.stream.listen((state) {
      if (state is ExpenseTxnAdded ||
          state is ExpenseTxnEdited ||
          state is ExpenseTxnRemoved) {
        getSummary();
      }
    });
  }

  @override
  Future<void> close() async {
    _expenseTxnSubscription?.cancel();
    return super.close();
  }

  getSummary() async {
    final dashboardCategories =
        await expensesRepository.getExpenseCategoriesByDate(DateTime.now());

    var expensesTotal = 0.0;
    dashboardCategories.forEach((element) {
      expensesTotal +=
          element.getTotalByDate(DateFilterType.monthly, DateTime.now());
    });

    final paidRecurringBills =
        await recurringBillsRepository.getPaidRecurringBills(DateTime.now());

    var recurringBillTotal = 0.0;
    paidRecurringBills.forEach((element) {
      recurringBillTotal += element.amount ?? 0.0;
    });

    emit(
      DashboardLoaded(
        overallTotal: expensesTotal + recurringBillTotal,
        expensesCategories: dashboardCategories,
        expensesTotal: expensesTotal,
        paidRecurringBills: paidRecurringBills,
        recurringBillTotal: recurringBillTotal,
      ),
    );
  }
}

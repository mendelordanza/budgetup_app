import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:budgetup_app/data/recurring_bills_repository.dart';
import 'package:budgetup_app/data/salary_repository.dart';
import 'package:budgetup_app/domain/salary.dart';
import 'package:budgetup_app/helper/shared_prefs.dart';
import 'package:meta/meta.dart';

import '../../../data/expenses_repository.dart';
import '../../../helper/date_helper.dart';
import '../../recurring_modify/bloc/recurring_modify_bloc.dart';
import '../../settings/currency/bloc/convert_currency_cubit.dart';
import '../../transactions_modify/bloc/transactions_modify_bloc.dart';

part 'salary_event.dart';

part 'salary_state.dart';

class SalaryBloc extends Bloc<SalaryEvent, SalaryState> {
  final SalaryRepository salaryRepository;
  final ExpensesRepository expensesRepository;
  final RecurringBillsRepository recurringBillsRepository;
  final TransactionsModifyBloc transactionsModifyBloc;
  final RecurringModifyBloc recurringModifyBloc;
  final ConvertCurrencyCubit convertCurrencyCubit;
  StreamSubscription? _expenseTxnSubscription;
  StreamSubscription? _currencySubscription;
  StreamSubscription? _recurringSubscription;
  final SharedPrefs sharedPrefs;

  @override
  Future<void> close() {
    _expenseTxnSubscription?.cancel();
    _currencySubscription?.cancel();
    _recurringSubscription?.cancel();
    return super.close();
  }

  SalaryBloc({
    required this.salaryRepository,
    required this.expensesRepository,
    required this.recurringBillsRepository,
    required this.transactionsModifyBloc,
    required this.recurringModifyBloc,
    required this.convertCurrencyCubit,
    required this.sharedPrefs,
  }) : super(SalaryInitial()) {
    _currencySubscription = convertCurrencyCubit.stream.listen((state) {
      if (state is ConvertedCurrencyLoaded) {
        add(LoadSalary(
            selectedDate: DateTime.parse(sharedPrefs.getSelectedDate())));
      }
    });

    _expenseTxnSubscription = transactionsModifyBloc.stream.listen((state) {
      if (state is ExpenseTxnAdded ||
          state is ExpenseTxnEdited ||
          state is ExpenseTxnRemoved) {
        add(LoadSalary(
            selectedDate: DateTime.parse(sharedPrefs.getSelectedDate())));
      }
    });

    _recurringSubscription = recurringModifyBloc.stream.listen((state) {
      add(LoadSalary(
          selectedDate: DateTime.parse(sharedPrefs.getSelectedDate())));
    });

    on<LoadSalary>((event, emit) async {
      final salary = await salaryRepository.getSalaryByDate(event.selectedDate);
      final convertedSalary = salary?.copy(
          amount: sharedPrefs.getCurrencyCode() == "USD"
              ? (salary.amount ?? 0.00)
              : (salary.amount ?? 0.00) * sharedPrefs.getCurrencyRate());

      //YOUR EXPENSES
      final dashboardCategories = await expensesRepository
          .getExpenseCategoriesByDate(event.selectedDate);
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
        final totalByDate =
            element.getTotalByDate(DateFilterType.monthly, event.selectedDate);
        expensesTotal += totalByDate;
      });

      final paidRecurringBills = await recurringBillsRepository
          .getPaidRecurringBills(DateFilterType.monthly, event.selectedDate);

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

      final remainingSalary = (convertedSalary?.amount ?? 0.00) -
          expensesTotal -
          recurringBillTotal;

      emit(SalaryLoaded(
        salary: convertedSalary,
        totalExpense: expensesTotal,
        totalPaidBills: recurringBillTotal,
        remainingSalary: remainingSalary.isNegative ? 0.00 : remainingSalary,
      ));
    });
    on<AddSalary>((event, emit) async {
      if (state is SalaryLoaded) {
        final data = state as SalaryLoaded;

        await salaryRepository.saveSalary(event.salary);

        final convertedSalary = event.salary.copy(
            amount: sharedPrefs.getCurrencyCode() == "USD"
                ? (event.salary.amount ?? 0.00)
                : (event.salary.amount ?? 0.00) *
                    sharedPrefs.getCurrencyRate());

        final remainingSalary = (convertedSalary.amount ?? 0.00) -
            data.totalExpense -
            data.totalPaidBills;

        emit(SalaryLoaded(
          salary: convertedSalary,
          totalExpense: data.totalExpense,
          totalPaidBills: data.totalPaidBills,
          remainingSalary: remainingSalary.isNegative ? 0.00 : remainingSalary,
        ));
      }
    });
  }
}

import 'dart:async';

import 'package:budgetup_app/helper/date_helper.dart';
import 'package:budgetup_app/helper/shared_prefs.dart';
import 'package:budgetup_app/presentation/expenses_modify/bloc/expenses_modify_bloc.dart';
import 'package:budgetup_app/presentation/settings/currency/bloc/convert_currency_cubit.dart';
import 'package:budgetup_app/presentation/transactions_modify/bloc/transactions_modify_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/expenses_repository.dart';
import '../../../domain/expense_category.dart';

part 'expense_event.dart';

part 'expense_state.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final SharedPrefs sharedPrefs;
  final ExpensesRepository expensesRepository;
  final ModifyExpensesBloc modifyExpensesBloc;
  final TransactionsModifyBloc transactionsModifyBloc;
  final ConvertCurrencyCubit convertCurrencyCubit;
  StreamSubscription? _expenseSubscription;
  StreamSubscription? _expenseTxnSubscription;
  StreamSubscription? _currencySubscription;

  ExpenseBloc({
    required this.expensesRepository,
    required this.modifyExpensesBloc,
    required this.transactionsModifyBloc,
    required this.convertCurrencyCubit,
    required this.sharedPrefs,
  }) : super(ExpenseCategoryInitial()) {
    _currencySubscription = convertCurrencyCubit.stream.listen((state) {
      if (state is ConvertedCurrencyLoaded) {
        add(ConvertExpenseBudget(
            currencyCode: state.currencyCode,
            currencyRate: state.currencyRate));
      }
    });

    _expenseSubscription = modifyExpensesBloc.stream.listen((state) {
      if (state is ExpenseAdded ||
          state is ExpenseEdited ||
          state is ExpenseRemoved) {
        add(LoadExpenseCategories());
      }
    });

    _expenseTxnSubscription = transactionsModifyBloc.stream.listen((state) {
      if (state is ExpenseTxnAdded ||
          state is ExpenseTxnEdited ||
          state is ExpenseTxnRemoved) {
        add(LoadExpenseCategories());
      }
    });

    on<LoadExpenseCategories>((event, emit) async {
      final categories = await expensesRepository.getExpenseCategories();

      final convertedCategories = categories.map((category) {
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

      var total = 0.00;
      convertedCategories.forEach((element) {
        total += element.getTotalByDate(
            event.dateFilterType ?? DateFilterType.monthly,
            event.selectedDate ?? DateTime.now());
      });

      var budget = 0.00;
      convertedCategories.forEach((element) {
        budget += element.budget ?? 0.00;
      });

      emit(ExpenseCategoryLoaded(
        expenseCategories: convertedCategories,
        total: total,
        totalBudget: budget,
      ));
    });
    on<ConvertExpenseBudget>((event, emit) async {
      final categories = await expensesRepository.getExpenseCategories();

      final updatedCategories = categories.map((category) {
        final convertedBudget = event.currencyCode == "USD"
            ? (category.budget ?? 0.00)
            : (category.budget ?? 0.00) * event.currencyRate;

        final convertedTxns = category.expenseTransactions?.map((txn) {
          final convertedAmount = event.currencyCode == "USD"
              ? (txn.amount ?? 0.00)
              : (txn.amount ?? 0.00) * event.currencyRate;
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

      var total = 0.00;
      updatedCategories.forEach((element) {
        total += element.getTotalByDate(DateFilterType.monthly, DateTime.now());
      });

      var budget = 0.00;
      updatedCategories.forEach((element) {
        budget += element.budget ?? 0.00;
      });

      emit(ExpenseCategoryLoaded(
        expenseCategories: updatedCategories,
        total: total,
        totalBudget: budget,
      ));
    });
  }

  @override
  Future<void> close() {
    _expenseSubscription?.cancel();
    _expenseTxnSubscription?.cancel();
    _currencySubscription?.cancel();
    return super.close();
  }
}

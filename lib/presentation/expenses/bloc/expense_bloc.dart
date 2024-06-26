import 'dart:async';

import 'package:budgetup_app/helper/date_helper.dart';
import 'package:budgetup_app/helper/shared_prefs.dart';
import 'package:budgetup_app/helper/string.dart';
import 'package:budgetup_app/presentation/expenses_modify/bloc/expenses_modify_bloc.dart';
import 'package:budgetup_app/presentation/settings/currency/bloc/convert_currency_cubit.dart';
import 'package:budgetup_app/presentation/transactions_modify/bloc/transactions_modify_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:home_widget/home_widget.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../../data/expenses_repository.dart';
import '../../../domain/expense_category.dart';
import '../../../helper/constant.dart';

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

      var total = 0.00;
      var todayTotal = 0.00;
      var thisMonthTotal = 0.00;
      var thisWeekTotal = 0.00;
      categories.forEach((element) {
        total += element.getTotalByDate(
            event.dateFilterType ?? DateFilterType.monthly,
            event.selectedDate ?? DateTime.now());

        //For Widget
        thisMonthTotal +=
            element.getTotalByDate(DateFilterType.monthly, DateTime.now());
        thisWeekTotal +=
            element.getTotalByDate(DateFilterType.weekly, DateTime.now());
        todayTotal +=
            element.getTotalByDate(DateFilterType.daily, DateTime.now());
      });

      _setupWidget(
          todayTotal: todayTotal,
          thisMonthTotal: thisMonthTotal,
          thisWeekTotal: thisWeekTotal);

      var budget = 0.00;
      categories.forEach((element) {
        budget += element.budget ?? 0.00;
      });

      emit(ExpenseCategoryLoaded(
        expenseCategories: categories,
        total: total,
        totalBudget: budget,
      ));
    });
    on<ConvertExpenseBudget>((event, emit) async {
      final categories = await expensesRepository.getExpenseCategories();

      var total = 0.00;
      var todayTotal = 0.00;
      var thisMonthTotal = 0.00;
      var thisWeekTotal = 0.00;
      categories.forEach((element) {
        total += element.getTotalByDate(DateFilterType.monthly, DateTime.now());

        //For Widget
        thisMonthTotal +=
            element.getTotalByDate(DateFilterType.monthly, DateTime.now());
        thisWeekTotal +=
            element.getTotalByDate(DateFilterType.weekly, DateTime.now());
        todayTotal +=
            element.getTotalByDate(DateFilterType.daily, DateTime.now());
      });

      _setupWidget(
          todayTotal: todayTotal,
          thisMonthTotal: thisMonthTotal,
          thisWeekTotal: thisWeekTotal);

      var budget = 0.00;
      categories.forEach((element) {
        budget += element.budget ?? 0.00;
      });

      emit(ExpenseCategoryLoaded(
        expenseCategories: categories,
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

  _setupWidget({
    required double todayTotal,
    required double thisMonthTotal,
    required double thisWeekTotal,
  }) async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      final isSubscribed = customerInfo.entitlements.active[entitlementId] !=
              null &&
          customerInfo.entitlements.active[entitlementId]!.isSandbox == false;
      print("SEND!");
      Future.wait([
        HomeWidget.saveWidgetData<String>(
            'todayTotal', decimalFormatterWithSymbol(number: todayTotal)),
        HomeWidget.saveWidgetData<String>(
            'thisMonthTotal', decimalFormatterWithSymbol(number: thisMonthTotal)),
        HomeWidget.saveWidgetData<String>(
            'thisWeekTotal', decimalFormatterWithSymbol(number: thisWeekTotal)),
        HomeWidget.saveWidgetData<bool>('isSubscribed', isSubscribed),
      ]);
    } on PlatformException catch (exception) {
      debugPrint('Error Sending Data. $exception');
    }

    try {
      HomeWidget.updateWidget(
          name: 'TotalSpentWidgetProvider', iOSName: 'BudgetUpWidget');
    } on PlatformException catch (exception) {
      debugPrint('Error Updating Widget. $exception');
    }
  }
}

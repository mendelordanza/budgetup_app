import 'dart:async';

import 'package:budgetup_app/helper/date_helper.dart';
import 'package:budgetup_app/presentation/expenses_modify/bloc/expenses_modify_bloc.dart';
import 'package:budgetup_app/presentation/transactions_modify/bloc/transactions_modify_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/expenses_repository.dart';
import '../../../domain/expense_category.dart';

part 'expense_event.dart';

part 'expense_state.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final ExpensesRepository expensesRepository;
  final ModifyExpensesBloc modifyExpensesBloc;
  StreamSubscription? _expenseSubscription;
  final TransactionsModifyBloc transactionsModifyBloc;
  StreamSubscription? _expenseTxnSubscription;

  ExpenseBloc({
    required this.expensesRepository,
    required this.modifyExpensesBloc,
    required this.transactionsModifyBloc,
  }) : super(ExpenseCategoryInitial()) {
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
      categories.forEach((element) {
        total += element.getTotalByDate(
            event.dateFilterType ?? DateFilterType.monthly,
            event.selectedDate ?? DateTime.now());
      });

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
    return super.close();
  }
}

import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:budgetup_app/domain/expense_category.dart';
import 'package:meta/meta.dart';

import '../../../data/expenses_repository.dart';
import '../../expenses_modify/bloc/expenses_modify_bloc.dart';

part 'single_category_state.dart';

class SingleCategoryCubit extends Cubit<SingleCategoryState> {
  final ExpensesRepository expensesRepository;
  final ModifyExpensesBloc modifyExpensesBloc;
  StreamSubscription? _expenseSubscription;

  SingleCategoryCubit({
    required this.expensesRepository,
    required this.modifyExpensesBloc,
  }) : super(SingleCategoryInitial()) {
    _expenseSubscription = modifyExpensesBloc.stream.listen((state) {
      if (state is ExpenseEdited) {
        getCategory(state.updatedCategory);
      }
    });
  }

  getCategory(ExpenseCategory category) async {
    emit(SingleCategoryLoaded(category));
  }

  @override
  Future<void> close() {
    _expenseSubscription?.cancel();
    return super.close();
  }
}

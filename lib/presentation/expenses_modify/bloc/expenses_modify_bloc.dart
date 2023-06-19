import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../data/expenses_repository.dart';
import '../../../domain/expense_category.dart';
import '../../../helper/shared_prefs.dart';

part 'expenses_modify_event.dart';

part 'expenses_modify_state.dart';

class ModifyExpensesBloc
    extends Bloc<ModifyExpensesEvent, ModifyExpensesState> {
  final ExpensesRepository expensesRepository;
  final SharedPrefs sharedPrefs;

  ModifyExpensesBloc({
    required this.expensesRepository,
    required this.sharedPrefs,
  }) : super(ModifyExpensesInitial()) {
    on<AddExpenseCategory>((event, emit) async {
      //Save to DB
      await expensesRepository.saveCategory(event.expenseCategory);
      emit(ExpenseAdded());
    });
    on<EditExpenseCategory>((event, emit) async {
      //Save to DB
      await expensesRepository.saveCategory(event.expenseCategory);
      final convertedExpenseBudget = event.expenseCategory.copy(
          budget: sharedPrefs.getCurrencyCode() == "USD"
              ? (event.expenseCategory.budget ?? 0.00)
              : (event.expenseCategory.budget ?? 0.00) *
                  sharedPrefs.getCurrencyRate());
      emit(ExpenseEdited(convertedExpenseBudget));
    });
    on<RemoveExpenseCategory>((event, emit) async {
      await expensesRepository.deleteCategory(event.expenseCategory.id!);
      emit(ExpenseRemoved());
    });
  }
}

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../data/expenses_repository.dart';
import '../../../domain/expense_category.dart';

part 'expenses_modify_event.dart';

part 'expenses_modify_state.dart';

class ModifyExpensesBloc
    extends Bloc<ModifyExpensesEvent, ModifyExpensesState> {
  final ExpensesRepository expensesRepository;

  ModifyExpensesBloc({
    required this.expensesRepository,
  }) : super(ModifyExpensesInitial()) {
    on<AddExpenseCategory>((event, emit) async {
      //Save to DB
      await expensesRepository.saveCategory(event.expenseCategory);
      emit(ExpenseAdded());
    });
    on<EditExpenseCategory>((event, emit) async {
      //Save to DB
      await expensesRepository.saveCategory(event.expenseCategory);
      emit(ExpenseEdited());
    });
    on<RemoveExpenseCategory>((event, emit) async {
      await expensesRepository.deleteCategory(event.expenseCategory.id!);
      emit(ExpenseRemoved());
    });
  }
}

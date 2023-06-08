import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/expenses_repository.dart';
import '../../../domain/expense_category.dart';

part 'expense_event.dart';

part 'expense_state.dart';

class ExpenseBloc extends Bloc<ExpenseEvent, ExpenseState> {
  final ExpensesRepository expensesRepository;

  ExpenseBloc({
    required this.expensesRepository,
  }) : super(ExpenseCategoryInitial()) {
    on<LoadExpenseCategories>((event, emit) async {
      final categories = await expensesRepository.getExpenseCategories();

      emit(ExpenseCategoryLoaded(
        expenseCategories: categories,
      ));
    });
    on<AddExpenseCategory>((event, emit) async {
      if (state is ExpenseCategoryLoaded) {
        final state = this.state as ExpenseCategoryLoaded;

        //Save to DB
        expensesRepository.saveCategory(event.expenseCategory);

        //Emit state
        emit(
          ExpenseCategoryLoaded(
            expenseCategories: List.from(state.expenseCategories)
              ..add(event.expenseCategory),
          ),
        );
      }
    });
    on<EditExpenseCategory>((event, emit) async {
      if (state is ExpenseCategoryLoaded) {
        final state = this.state as ExpenseCategoryLoaded;

        //Save to DB
        expensesRepository.saveCategory(event.expenseCategory);

        //Emit state
        emit(
          ExpenseCategoryLoaded(
            expenseCategories: List.from(state.expenseCategories),
          ),
        );
      }
    });
    on<RemoveExpenseCategory>((event, emit) async {
      if (state is ExpenseCategoryLoaded) {
        final state = this.state as ExpenseCategoryLoaded;

        //Remove from DB
        if (event.expenseCategory.id != null) {
          expensesRepository.deleteCategory(event.expenseCategory.id!);

          //Emit state
          emit(
            ExpenseCategoryLoaded(
              expenseCategories: List.from(state.expenseCategories)
                ..remove(event.expenseCategory),
            ),
          );
        }
      }
    });
  }
}

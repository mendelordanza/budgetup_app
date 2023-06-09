import 'package:budgetup_app/helper/date_helper.dart';
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

      var total = 0.0;
      categories.forEach((element) {
        total += element.getTotal(DateFilterType.monthly, DateTime.now());
      });

      emit(ExpenseCategoryLoaded(
        total: total,
        expenseCategories: categories,
      ));
    });
    on<AddExpenseCategory>((event, emit) async {
      if (state is ExpenseCategoryLoaded) {
        final state = this.state as ExpenseCategoryLoaded;

        //Save to DB
        expensesRepository.saveCategory(event.expenseCategory);

        List<ExpenseCategory> newList = List.from(state.expenseCategories)
          ..add(event.expenseCategory);

        var total = 0.0;
        newList.forEach((element) {
          total += element.getTotal(DateFilterType.monthly, DateTime.now());
        });

        //Emit state
        emit(
          ExpenseCategoryLoaded(
            total: total,
            expenseCategories: newList,
          ),
        );
      }
    });
    on<EditExpenseCategory>((event, emit) async {
      if (state is ExpenseCategoryLoaded) {
        final state = this.state as ExpenseCategoryLoaded;

        //Save to DB
        expensesRepository.saveCategory(event.expenseCategory);

        List<ExpenseCategory> newList = List.from(state.expenseCategories);

        var total = 0.0;
        newList.forEach((element) {
          total += element.getTotal(DateFilterType.monthly, DateTime.now());
        });

        //Emit state
        emit(
          ExpenseCategoryLoaded(
            total: total,
            expenseCategories: newList,
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

          List<ExpenseCategory> newList = List.from(state.expenseCategories)
            ..remove(event.expenseCategory);

          var total = 0.0;
          newList.forEach((element) {
            total += element.getTotal(DateFilterType.monthly, DateTime.now());
          });

          //Emit state
          emit(
            ExpenseCategoryLoaded(
              total: total,
              expenseCategories: newList,
            ),
          );
        }
      }
    });
  }
}

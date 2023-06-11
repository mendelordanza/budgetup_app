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
      expensesRepository.saveCategory(event.expenseCategory);

      emit(ExpenseAdded());

      // if (state is ExpenseCategoryLoaded) {
      //   final state = this.state as ExpenseCategoryLoaded;
      //
      //   //Save to DB
      //   expensesRepository.saveCategory(event.expenseCategory);
      //
      //   List<ExpenseCategory> newList = List.from(state.expenseCategories)
      //     ..add(event.expenseCategory);
      //
      //   var total = 0.0;
      //   newList.forEach((element) {
      //     total +=
      //         element.getTotalByDate(DateFilterType.monthly, DateTime.now());
      //   });
      //
      //   //Emit state
      //   emit(
      //     ExpenseCategoryLoaded(
      //       total: total,
      //       expenseCategories: newList,
      //     ),
      //   );
      // }
    });
    on<EditExpenseCategory>((event, emit) async {
      //Save to DB
      expensesRepository.saveCategory(event.expenseCategory);

      emit(ExpenseEdited());

      // if (state is ExpenseCategoryLoaded) {
      //   final state = this.state as ExpenseCategoryLoaded;
      //
      //   //Save to DB
      //   expensesRepository.saveCategory(event.expenseCategory);
      //
      //   List<ExpenseCategory> newList = List.from(state.expenseCategories);
      //
      //   var total = 0.0;
      //   newList.forEach((element) {
      //     total +=
      //         element.getTotalByDate(DateFilterType.monthly, DateTime.now());
      //   });
      //
      //   //Emit state
      //   emit(
      //     ExpenseCategoryLoaded(
      //       total: total,
      //       expenseCategories: newList,
      //     ),
      //   );
      // }
    });
    on<RemoveExpenseCategory>((event, emit) async {
      expensesRepository.deleteCategory(event.expenseCategory.id!);

      emit(ExpenseRemoved());

      // if (state is ExpenseCategoryLoaded) {
      //   final state = this.state as ExpenseCategoryLoaded;
      //
      //   //Remove from DB
      //   if (event.expenseCategory.id != null) {
      //     expensesRepository.deleteCategory(event.expenseCategory.id!);
      //
      //     List<ExpenseCategory> newList = List.from(state.expenseCategories)
      //       ..remove(event.expenseCategory);
      //
      //     var total = 0.0;
      //     newList.forEach((element) {
      //       total +=
      //           element.getTotalByDate(DateFilterType.monthly, DateTime.now());
      //     });
      //
      //     //Emit state
      //     emit(
      //       ExpenseCategoryLoaded(
      //         total: total,
      //         expenseCategories: newList,
      //       ),
      //     );
      //   }
      // }
    });
  }
}


import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/expenses_repository.dart';
import '../../../domain/expense_category.dart';
import '../../../domain/expense_txn.dart';

part 'expense_txn_event.dart';

part 'expense_txn_state.dart';

class ExpenseTxnBloc extends Bloc<ExpenseTxnEvent, ExpenseTxnState> {
  final ExpensesRepository expensesRepository;

  ExpenseTxnBloc({
    required this.expensesRepository,
  }) : super(ExpenseTxnInitial()) {
    on<LoadExpenseTxns>((event, emit) async {
      final txns = await expensesRepository.getExpenseTxns(event.categoryId);

      emit(ExpenseTxnLoaded(
        expenseTxns: txns,
      ));
    });
    on<AddExpenseTxn>((event, emit) async {
      if (state is ExpenseTxnLoaded) {
        final state = this.state as ExpenseTxnLoaded;

        expensesRepository.addTransaction(
            event.expenseCategory, event.expenseTxn);

        emit(
          ExpenseTxnLoaded(
            expenseTxns: List.from(state.expenseTxns)..add(event.expenseTxn),
          ),
        );
      }
    });
    on<EditExpenseTxn>((event, emit) async {
      if (state is ExpenseTxnLoaded) {
        final state = this.state as ExpenseTxnLoaded;

        expensesRepository.editTransaction(event.expenseTxn);

        emit(
          ExpenseTxnLoaded(
            expenseTxns: List.from(state.expenseTxns)..add(event.expenseTxn),
          ),
        );
      }
    });
    on<RemoveExpenseTxn>((event, emit) async {
      if (state is ExpenseTxnLoaded) {
        final state = this.state as ExpenseTxnLoaded;

        //Remove from DB
        if (event.expenseTxn.id != null) {
          expensesRepository.deleteTransaction(event.expenseTxn.id!);

          //Emit state
          emit(
            ExpenseTxnLoaded(
              expenseTxns: List.from(state.expenseTxns)
                ..remove(event.expenseTxn),
            ),
          );
        }
      }
    });
  }
}

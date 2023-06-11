
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../data/expenses_repository.dart';
import '../../../domain/expense_category.dart';
import '../../../domain/expense_txn.dart';

part 'transactions_modify_event.dart';

part 'transactions_modify_state.dart';

class TransactionsModifyBloc
    extends Bloc<TransactionsModifyEvent, TransactionsModifyState> {
  final ExpensesRepository expensesRepository;

  TransactionsModifyBloc({
    required this.expensesRepository,
  }) : super(TransactionsModifyInitial()) {
    on<AddExpenseTxn>((event, emit) async {
      expensesRepository.addTransaction(
          event.expenseCategory, event.expenseTxn);
      emit(ExpenseTxnAdded(event.expenseCategory));
    });
    on<EditExpenseTxn>((event, emit) async {
      expensesRepository.editTransaction(event.expenseTxn);
      emit(ExpenseTxnEdited(event.expenseCategory));
    });
    on<RemoveExpenseTxn>((event, emit) async {
      expensesRepository.deleteTransaction(event.expenseTxn.id!);
      emit(ExpenseTxnRemoved(event.expenseCategory));
    });
  }
}

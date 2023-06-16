import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../data/expenses_repository.dart';
import '../../../domain/expense_category.dart';
import '../../../domain/expense_txn.dart';
import '../../../helper/shared_prefs.dart';

part 'transactions_modify_event.dart';

part 'transactions_modify_state.dart';

class TransactionsModifyBloc
    extends Bloc<TransactionsModifyEvent, TransactionsModifyState> {
  final ExpensesRepository expensesRepository;
  final SharedPrefs sharedPrefs;

  TransactionsModifyBloc({
    required this.expensesRepository,
    required this.sharedPrefs,
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
      await expensesRepository.deleteTransaction(event.expenseTxn.id!);
      emit(ExpenseTxnRemoved(event.expenseCategory));
    });
  }
}

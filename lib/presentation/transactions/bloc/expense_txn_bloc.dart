import 'dart:async';

import 'package:budgetup_app/presentation/transactions_modify/bloc/transactions_modify_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/expenses_repository.dart';
import '../../../domain/expense_txn.dart';

part 'expense_txn_event.dart';

part 'expense_txn_state.dart';

class ExpenseTxnBloc extends Bloc<ExpenseTxnEvent, ExpenseTxnState> {
  final ExpensesRepository expensesRepository;
  final TransactionsModifyBloc transactionsModifyBloc;
  StreamSubscription? _expenseTxnSubscription;

  ExpenseTxnBloc({
    required this.expensesRepository,
    required this.transactionsModifyBloc,
  }) : super(ExpenseTxnInitial()) {
    _expenseTxnSubscription = transactionsModifyBloc.stream.listen((state) {
      print("STATE: $state");
      if (state is ExpenseTxnAdded) {
        add(LoadExpenseTxns(categoryId: state.expenseCategory.id!));
      } else if (state is ExpenseTxnEdited) {
        add(LoadExpenseTxns(categoryId: state.expenseCategory.id!));
      } else if (state is ExpenseTxnRemoved) {
        add(LoadExpenseTxns(categoryId: state.expenseCategory.id!));
      }
    });

    on<LoadExpenseTxns>((event, emit) async {
      final txns = await expensesRepository.getExpenseTxns(event.categoryId);

      var total = 0.00;
      txns.forEach((e) {
        total += e.amount ?? 0.00;
      });

      emit(ExpenseTxnLoaded(
        total: total,
        expenseTxns: txns,
      ));
    });
  }

  @override
  Future<void> close() async {
    _expenseTxnSubscription?.cancel();
    return super.close();
  }
}

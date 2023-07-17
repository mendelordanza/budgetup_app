import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:budgetup_app/domain/expense_category.dart';
import 'package:budgetup_app/domain/expense_txn.dart';
import 'package:meta/meta.dart';

import '../../../data/expenses_repository.dart';
import '../../../helper/shared_prefs.dart';
import '../../transactions_modify/bloc/transactions_modify_bloc.dart';

part 'all_txns_state.dart';

class AllTxnsCubit extends Cubit<AllTxnsState> {
  final ExpensesRepository expensesRepository;
  final SharedPrefs sharedPrefs;
  final TransactionsModifyBloc transactionsModifyBloc;
  StreamSubscription? _expenseTxnSubscription;

  AllTxnsCubit({
    required this.expensesRepository,
    required this.sharedPrefs,
    required this.transactionsModifyBloc,
  }) : super(AllTxnsInitial()) {
    _expenseTxnSubscription = transactionsModifyBloc.stream.listen((state) {
      if (state is ExpenseTxnAdded ||
          state is ExpenseTxnEdited ||
          state is ExpenseTxnRemoved) {
        getTxns();
      }
    });

    getTxns();
  }

  getTxns() async {
    final txns = await expensesRepository.getAllTransactions();
    final categories = await expensesRepository.getExpenseCategories();

    final convertedTxns = txns.map((txn) {
      final convertedAmount = sharedPrefs.getCurrencyCode() == "USD"
          ? (txn.amount ?? 0.00)
          : (txn.amount ?? 0.00) * sharedPrefs.getCurrencyRate();
      final newTxn = txn.copy(
        amount: convertedAmount,
      );
      return newTxn;
    }).toList();

    emit(
      AllTxnsLoaded(
        categories: categories,
        transactions: convertedTxns,
      ),
    );
  }

  @override
  Future<void> close() {
    _expenseTxnSubscription?.cancel();
    return super.close();
  }
}

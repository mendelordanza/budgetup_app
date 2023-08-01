import 'dart:async';

import 'package:budgetup_app/presentation/transactions_modify/bloc/transactions_modify_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/expenses_repository.dart';
import '../../../domain/expense_txn.dart';
import '../../../helper/shared_prefs.dart';
import '../../settings/currency/bloc/convert_currency_cubit.dart';

part 'expense_txn_event.dart';

part 'expense_txn_state.dart';

class ExpenseTxnBloc extends Bloc<ExpenseTxnEvent, ExpenseTxnState> {
  final SharedPrefs sharedPrefs;
  final ExpensesRepository expensesRepository;
  final TransactionsModifyBloc transactionsModifyBloc;
  final ConvertCurrencyCubit convertCurrencyCubit;
  StreamSubscription? _expenseTxnSubscription;
  StreamSubscription? _currencySubscription;

  ExpenseTxnBloc({
    required this.expensesRepository,
    required this.transactionsModifyBloc,
    required this.convertCurrencyCubit,
    required this.sharedPrefs,
  }) : super(ExpenseTxnInitial()) {
    _currencySubscription = convertCurrencyCubit.stream.listen((state) {
      if (state is ConvertedCurrencyLoaded) {
        add(ConvertTxn(
            currencyCode: state.currencyCode,
            currencyRate: state.currencyRate));
      }
    });

    _expenseTxnSubscription = transactionsModifyBloc.stream.listen((state) {
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
    on<ConvertTxn>((event, emit) async {
      if (state is ExpenseTxnLoaded) {
        final currentState = state as ExpenseTxnLoaded;

        var total = 0.00;
        currentState.expenseTxns.forEach((e) {
          total += e.amount ?? 0.00;
        });

        emit(ExpenseTxnLoaded(
          expenseTxns: currentState.expenseTxns,
          total: total,
        ));
      }
    });
  }

  @override
  Future<void> close() async {
    _expenseTxnSubscription?.cancel();
    _currencySubscription?.cancel();
    return super.close();
  }
}

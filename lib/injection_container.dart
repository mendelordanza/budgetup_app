import 'package:budgetup_app/data/expenses_repository.dart';
import 'package:budgetup_app/data/local/isar_service.dart';
import 'package:budgetup_app/data/recurring_bills_repository.dart';
import 'package:budgetup_app/helper/shared_prefs.dart';
import 'package:budgetup_app/presentation/date_filter/bloc/date_filter_bloc.dart';
import 'package:budgetup_app/presentation/expenses/bloc/expense_bloc.dart';
import 'package:budgetup_app/presentation/recurring/bloc/recurring_bill_bloc.dart';
import 'package:budgetup_app/presentation/recurring_date_filter/bloc/recurring_date_filter_bloc.dart';
import 'package:budgetup_app/presentation/transactions/bloc/expense_txn_bloc.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

Future<void> setup() async {
  //Bloc
  getIt.registerFactory(
    () => ExpenseBloc(expensesRepository: getIt()),
  );
  getIt.registerFactory(
    () => ExpenseTxnBloc(expensesRepository: getIt()),
  );
  getIt.registerFactory(
    () => RecurringBillBloc(recurringBillsRepo: getIt()),
  );
  getIt.registerFactory(
    () => DateFilterBloc(sharedPrefs: getIt()),
  );
  getIt.registerFactory(
    () => RecurringDateFilterBloc(sharedPrefs: getIt()),
  );

  //Repository
  getIt.registerLazySingleton(() => ExpensesRepository(isarService: getIt()));
  getIt.registerLazySingleton(
      () => RecurringBillsRepository(isarService: getIt()));

  //Data
  getIt.registerLazySingleton<SharedPrefs>(() => SharedPrefs());
  getIt.registerLazySingleton<IsarService>(() => IsarService());
}

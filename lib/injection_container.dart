import 'package:budgetup_app/data/expenses_repository.dart';
import 'package:budgetup_app/data/local/isar_service.dart';
import 'package:budgetup_app/domain/expense_txn.dart';
import 'package:budgetup_app/helper/shared_prefs.dart';
import 'package:budgetup_app/presentation/expenses/bloc/expense_bloc.dart';
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

  //Repository
  getIt.registerLazySingleton(() => ExpensesRepository(isarService: getIt()));

  //Data
  getIt.registerLazySingleton<SharedPrefs>(() => SharedPrefs());
  getIt.registerLazySingleton<IsarService>(() => IsarService());
}

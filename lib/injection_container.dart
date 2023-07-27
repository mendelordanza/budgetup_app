import 'package:budgetup_app/data/currency_repository.dart';
import 'package:budgetup_app/data/expenses_repository.dart';
import 'package:budgetup_app/data/http_service.dart';
import 'package:budgetup_app/data/local/backup/file_manager.dart';
import 'package:budgetup_app/data/local/isar_service.dart';
import 'package:budgetup_app/data/notification_service.dart';
import 'package:budgetup_app/data/recurring_bills_repository.dart';
import 'package:budgetup_app/data/salary_repository.dart';
import 'package:budgetup_app/helper/shared_prefs.dart';
import 'package:budgetup_app/presentation/dashboard/bloc/dashboard_cubit.dart';
import 'package:budgetup_app/presentation/expense_date_filter/bloc/date_filter_bloc.dart';
import 'package:budgetup_app/presentation/expenses/bloc/all_txns_cubit.dart';
import 'package:budgetup_app/presentation/expenses/bloc/expense_bloc.dart';
import 'package:budgetup_app/presentation/expenses/bloc/single_category_cubit.dart';
import 'package:budgetup_app/presentation/expenses_modify/bloc/expenses_modify_bloc.dart';
import 'package:budgetup_app/presentation/landing/bloc/onboarding_cubit.dart';
import 'package:budgetup_app/presentation/recurring/bloc/recurring_bill_bloc.dart';
import 'package:budgetup_app/presentation/recurring_date_filter/bloc/recurring_date_filter_bloc.dart';
import 'package:budgetup_app/presentation/recurring_modify/bloc/recurring_modify_bloc.dart';
import 'package:budgetup_app/presentation/salary/bloc/salary_bloc.dart';
import 'package:budgetup_app/presentation/settings/appearance/bloc/appearance_cubit.dart';
import 'package:budgetup_app/presentation/settings/currency/bloc/convert_currency_cubit.dart';
import 'package:budgetup_app/presentation/transactions/bloc/expense_txn_bloc.dart';
import 'package:budgetup_app/presentation/transactions_modify/bloc/transactions_modify_bloc.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

Future<void> setup() async {
  //Bloc
  getIt.registerLazySingleton(
    () => DashboardCubit(
      sharedPrefs: getIt(),
      expensesRepository: getIt(),
      recurringBillsRepository: getIt(),
    ),
  );
  getIt.registerLazySingleton(
    () => TransactionsModifyBloc(
      expensesRepository: getIt(),
      sharedPrefs: getIt(),
    ),
  );
  getIt.registerLazySingleton(
    () => ExpenseTxnBloc(
      expensesRepository: getIt(),
      transactionsModifyBloc: getIt(),
      convertCurrencyCubit: getIt(),
      sharedPrefs: getIt(),
    ),
  );
  getIt.registerLazySingleton(
    () => ModifyExpensesBloc(
      expensesRepository: getIt(),
      sharedPrefs: getIt(),
    ),
  );
  getIt.registerLazySingleton(
    () => ExpenseBloc(
      expensesRepository: getIt(),
      modifyExpensesBloc: getIt(),
      transactionsModifyBloc: getIt(),
      convertCurrencyCubit: getIt(),
      sharedPrefs: getIt(),
    ),
  );
  getIt.registerLazySingleton(
    () => RecurringModifyBloc(
      recurringBillsRepo: getIt(),
      notificationService: getIt(),
    ),
  );
  getIt.registerLazySingleton(
    () => RecurringBillBloc(
      recurringBillsRepo: getIt(),
      recurringModifyBloc: getIt(),
      convertCurrencyCubit: getIt(),
      sharedPrefs: getIt(),
    ),
  );
  getIt.registerLazySingleton(
    () => ConvertCurrencyCubit(
      currencyRepository: getIt(),
      sharedPrefs: getIt(),
    ),
  );
  getIt.registerLazySingleton(
    () => SingleCategoryCubit(
      expensesRepository: getIt(),
      modifyExpensesBloc: getIt(),
    ),
  );
  getIt.registerFactory(
    () => AppearanceCubit(sharedPrefs: getIt()),
  );
  getIt.registerFactory(
    () => OnboardingCubit(sharedPrefs: getIt()),
  );
  getIt.registerFactory(
    () => ExpenseDateFilterBloc(sharedPrefs: getIt()),
  );
  getIt.registerFactory(
    () => RecurringDateFilterBloc(sharedPrefs: getIt()),
  );
  getIt.registerFactory(
    () => AllTxnsCubit(
      expensesRepository: getIt(),
      sharedPrefs: getIt(),
      transactionsModifyBloc: getIt(),
    ),
  );
  getIt.registerFactory(
    () => SalaryBloc(
      expensesRepository: getIt(),
      sharedPrefs: getIt(),
      recurringBillsRepository: getIt(),
      salaryRepository: getIt(),
      transactionsModifyBloc: getIt(),
      convertCurrencyCubit: getIt(),
      recurringModifyBloc: getIt(),
    ),
  );

  //Repository
  getIt.registerLazySingleton(() => ExpensesRepository(isarService: getIt()));
  getIt.registerLazySingleton(
      () => RecurringBillsRepository(isarService: getIt()));
  getIt.registerLazySingleton(() => CurrencyRepository(
        httpService: getIt(),
        isarService: getIt(),
      ));
  getIt.registerLazySingleton(() => SalaryRepository(isarService: getIt()));

  //Data
  getIt.registerLazySingleton<SharedPrefs>(() => SharedPrefs());
  getIt.registerLazySingleton<IsarService>(() => IsarService());
  getIt.registerLazySingleton<HttpService>(() => HttpService());
  getIt.registerLazySingleton<FileManager>(() => FileManager());

  getIt.registerLazySingleton<NotificationService>(() => NotificationService());
}

import 'dart:io';

import 'package:budgetup_app/data/notification_service.dart';
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
import 'package:budgetup_app/presentation/transactions_modify/bloc/transaction_currency_bloc.dart';
import 'package:budgetup_app/presentation/transactions_modify/bloc/transactions_modify_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'helper/constant.dart';
import 'helper/my_themes.dart';
import 'helper/route.dart';
import 'helper/route_strings.dart';
import 'injection_container.dart' as di;
import 'injection_container.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  tz.initializeTimeZones();
  await di.setup();
  await SharedPrefs.init();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final notificationService = getIt<NotificationService>();
  final sharedPrefs = getIt<SharedPrefs>();

  initPlatformState() async {
    await Purchases.setLogLevel(LogLevel.debug);
    if (Platform.isAndroid) {
      final configuration = PurchasesConfiguration(googleApiKey);
      await Purchases.configure(configuration);
    } else if (Platform.isIOS) {
      final configuration = PurchasesConfiguration(appleApiKey);
      await Purchases.configure(configuration);
    }
  }

  notificationPermission() {
    notificationService.flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestPermission();
  }

  shouldShowReview() async {
    var counter = sharedPrefs.getShouldShowReview();
    if (counter >= 5) {
      final inAppReview = InAppReview.instance;
      if (await inAppReview.isAvailable()) {
        inAppReview.requestReview();
        sharedPrefs.setShouldShowReview(0);
      }
    } else {
      sharedPrefs.setShouldShowReview(counter++);
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initPlatformState();
      notificationPermission();
      shouldShowReview();
      notificationService.initNotification();
    });
    super.initState();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => getIt<DashboardCubit>(),
          ),
          BlocProvider(
            create: (context) => getIt<ModifyExpensesBloc>(),
          ),
          BlocProvider(
            create: (context) => getIt<ExpenseBloc>(),
          ),
          BlocProvider(
            create: (context) => getIt<TransactionsModifyBloc>(),
          ),
          BlocProvider(
            create: (context) => getIt<ExpenseTxnBloc>(),
          ),
          BlocProvider(
            create: (context) => getIt<RecurringModifyBloc>(),
          ),
          BlocProvider(
            create: (context) => getIt<RecurringBillBloc>(),
          ),
          BlocProvider(
            create: (context) => getIt<ExpenseDateFilterBloc>(),
          ),
          BlocProvider(
            create: (context) => getIt<RecurringDateFilterBloc>(),
          ),
          BlocProvider(
            create: (context) => getIt<ConvertCurrencyCubit>(),
          ),
          BlocProvider(
            create: (context) => getIt<SingleCategoryCubit>(),
          ),
          BlocProvider(
            create: (context) => getIt<AppearanceCubit>(),
          ),
          BlocProvider(
            create: (context) => getIt<OnboardingCubit>(),
          ),
          BlocProvider(
            create: (context) => getIt<AllTxnsCubit>(),
          ),
          BlocProvider(
            create: (context) => getIt<SalaryBloc>(),
          ),
          BlocProvider(
            create: (context) => getIt<TransactionCurrencyBloc>(),
          ),
        ],
        child: BlocBuilder<AppearanceCubit, AppearanceState>(
          builder: (context, state) {
            if (state is AppearanceLoaded) {
              return app(state.themeMode);
            }
            return app(ThemeMode.system);
          },
        ));
  }

  Widget app(ThemeMode themeMode) {
    return MaterialApp(
      title: 'BudgetUp',
      themeMode: themeMode,
      theme: MyThemes.lightTheme,
      darkTheme: MyThemes.darkTheme,
      onGenerateRoute: RouteGenerator.generateRoute,
      initialRoute: RouteStrings.landing,
    );
  }
}

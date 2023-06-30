import 'dart:io';

import 'package:budgetup_app/data/notification_service.dart';
import 'package:budgetup_app/data/recurring_bills_repository.dart';
import 'package:budgetup_app/helper/shared_prefs.dart';
import 'package:budgetup_app/presentation/dashboard/bloc/dashboard_cubit.dart';
import 'package:budgetup_app/presentation/expense_date_filter/bloc/date_filter_bloc.dart';
import 'package:budgetup_app/presentation/expenses/bloc/expense_bloc.dart';
import 'package:budgetup_app/presentation/expenses/bloc/single_category_cubit.dart';
import 'package:budgetup_app/presentation/expenses_modify/bloc/expenses_modify_bloc.dart';
import 'package:budgetup_app/presentation/landing/bloc/onboarding_cubit.dart';
import 'package:budgetup_app/presentation/recurring/bloc/recurring_bill_bloc.dart';
import 'package:budgetup_app/presentation/recurring_date_filter/bloc/recurring_date_filter_bloc.dart';
import 'package:budgetup_app/presentation/recurring_modify/add_recurring_bill_page.dart';
import 'package:budgetup_app/presentation/recurring_modify/bloc/recurring_modify_bloc.dart';
import 'package:budgetup_app/presentation/settings/appearance/bloc/appearance_cubit.dart';
import 'package:budgetup_app/presentation/settings/currency/bloc/convert_currency_cubit.dart';
import 'package:budgetup_app/presentation/transactions/bloc/expense_txn_bloc.dart';
import 'package:budgetup_app/presentation/transactions_modify/bloc/transactions_modify_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:home_widget/home_widget.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:workmanager/workmanager.dart';

import 'helper/constant.dart';
import 'helper/my_themes.dart';
import 'helper/route.dart';
import 'helper/route_strings.dart';
import 'injection_container.dart' as di;
import 'injection_container.dart';
import 'package:timezone/data/latest.dart' as tz;

@pragma("vm:entry-point")
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) {
    final now = DateTime.now();
    return Future.wait<bool?>([
      HomeWidget.saveWidgetData(
        'title',
        'Updated from Background',
      ),
      HomeWidget.saveWidgetData(
        'message',
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
      ),
      HomeWidget.updateWidget(
        name: 'HomeWidgetExampleProvider',
        iOSName: 'HomeWidgetExample',
      ),
    ]).then((value) {
      return !value.contains(false);
    });
  });
}

/// Called when Doing Background Work initiated from Widget
@pragma("vm:entry-point")
void backgroundCallback(Uri? data) async {
  print(data);

  await HomeWidget.saveWidgetData<String>('_date', "Sample");
  await HomeWidget.saveWidgetData<String>('_title', "Sample");
  await HomeWidget.saveWidgetData<String>('_balance', "Sample");
  await HomeWidget.updateWidget(
      name: 'HomeWidgetExampleProvider', iOSName: 'HomeWidgetExample');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Workmanager().initialize(callbackDispatcher, isInDebugMode: true);

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

  ensureScheduledNotifications() async {
    final recurringRepo = getIt<RecurringBillsRepository>();
    final recurringBills = await recurringRepo.getRecurringBills();
    recurringBills.forEach((recurring) {
      notificationService.scheduleNotification(
        0,
        "Have you paid your bill yet?",
        "${recurring.title} amounting to ${recurring.amount}",
        recurring.reminderDate!.toIso8601String(),
        recurring.interval ?? RecurringBillInterval.monthly.name,
      );
    });
  }

  @override
  void initState() {
    initPlatformState();
    notificationPermission();
    notificationService.initNotification();
    //ensureScheduledNotifications();
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

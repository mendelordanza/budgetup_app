import 'package:budgetup_app/helper/shared_prefs.dart';
import 'package:budgetup_app/presentation/expense_date_filter/bloc/date_filter_bloc.dart';
import 'package:budgetup_app/presentation/expenses/bloc/expense_bloc.dart';
import 'package:budgetup_app/presentation/recurring/bloc/recurring_bill_bloc.dart';
import 'package:budgetup_app/presentation/recurring_date_filter/bloc/recurring_date_filter_bloc.dart';
import 'package:budgetup_app/presentation/transactions/bloc/expense_txn_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'helper/my_themes.dart';
import 'helper/route.dart';
import 'helper/route_strings.dart';
import 'injection_container.dart' as di;
import 'injection_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await di.setup();
  await SharedPrefs.init();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => getIt<ExpenseBloc>(),
        ),
        BlocProvider(
          create: (context) => getIt<ExpenseTxnBloc>(),
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
      ],
      child: MaterialApp(
        title: 'BudgetUp',
        themeMode: ThemeMode.system,
        theme: MyThemes.lightTheme,
        darkTheme: MyThemes.darkTheme,
        onGenerateRoute: RouteGenerator.generateRoute,
        initialRoute: RouteStrings.landing,
      ),
    );
  }
}

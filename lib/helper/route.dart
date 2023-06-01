import 'dart:io';

import 'package:budgetup_app/domain/expense_category.dart';
import 'package:budgetup_app/helper/route_strings.dart';
import 'package:budgetup_app/presentation/expenses/add_expense_category_page.dart';
import 'package:budgetup_app/presentation/expenses/expenses_page.dart';
import 'package:budgetup_app/presentation/transactions/bloc/expense_txn_bloc.dart';
import 'package:budgetup_app/presentation/transactions/expense_txn_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../injection_container.dart';

class RouteGenerator {
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case RouteStrings.landing:
        return _navigate(
          builder: (_) => ExpensesPage(),
        );
      case RouteStrings.addExpense:
        if (args is ExpenseCategory?) {
          return _navigate(
            builder: (_) => AddExpenseCategoryPage(
              expenseCategory: args,
            ),
          );
        } else {
          return _errorRoute();
        }
      case RouteStrings.transactions:
        if (args is ExpenseCategory) {
          if (args.id != null) {
            return _navigate(
              builder: (_) => BlocProvider(
                create: (context) => getIt<ExpenseTxnBloc>()
                  ..add(LoadExpenseTxns(categoryId: args.id!)),
                child: ExpenseTxnPage(
                  expenseCategory: args,
                ),
              ),
            );
          }
          return _errorRoute();
        } else {
          return _errorRoute();
        }
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic>? _navigate({required WidgetBuilder builder}) {
    if (Platform.isAndroid) {
      return MaterialPageRoute(builder: builder);
    } else {
      return CupertinoPageRoute(builder: builder);
    }
  }

  static Route<dynamic>? _errorRoute() {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: Text("Navigation Error"),
        ),
        body: Center(
          child: Text("Something went wrong."),
        ),
      ),
    );
  }
}

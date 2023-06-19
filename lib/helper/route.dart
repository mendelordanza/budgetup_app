import 'dart:io';

import 'package:budgetup_app/domain/expense_category.dart';
import 'package:budgetup_app/domain/recurring_bill.dart';
import 'package:budgetup_app/helper/route_strings.dart';
import 'package:budgetup_app/presentation/home_page.dart';
import 'package:budgetup_app/presentation/recurring_modify/add_recurring_bill_page.dart';
import 'package:budgetup_app/presentation/settings/appearance/appearance_page.dart';
import 'package:budgetup_app/presentation/settings/settings_page.dart';
import 'package:budgetup_app/presentation/settings/summary/summary_page.dart';
import 'package:budgetup_app/presentation/transactions_modify/add_expense_txn_page.dart';
import 'package:budgetup_app/presentation/transactions/expense_txn_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../presentation/expenses_modify/add_expense_category_page.dart';

class RouteGenerator {
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case RouteStrings.landing:
        return _navigate(
          builder: (_) => HomePage(),
        );
      case RouteStrings.settings:
        return _navigate(
          builder: (_) => SettingsPage(),
        );
      case RouteStrings.summary:
        return _navigate(
          builder: (_) => SummaryPage(),
        );
      case RouteStrings.appearance:
        return _navigate(
          builder: (_) => ApperancePage(),
        );
      case RouteStrings.addCategory:
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
          return _navigate(
            builder: (_) => ExpenseTxnPage(
              expenseCategory: args,
            ),
          );
        } else {
          return _errorRoute();
        }
      case RouteStrings.addTransaction:
        if (args is ExpenseTxnArgs) {
          return _navigate(
            builder: (_) => AddExpenseTxnPage(
              args: args,
            ),
          );
        } else {
          return _errorRoute();
        }
      case RouteStrings.addRecurringBill:
        if (args is RecurringBill?) {
          return _navigate(
            builder: (_) => AddRecurringBillPage(
              recurringBill: args,
            ),
          );
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

import 'dart:io';

import 'package:budgetup_app/domain/expense_category.dart';
import 'package:budgetup_app/domain/recurring_bill.dart';
import 'package:budgetup_app/helper/route_strings.dart';
import 'package:budgetup_app/presentation/dashboard/dashboard_page.dart';
import 'package:budgetup_app/presentation/landing/landing_page.dart';
import 'package:budgetup_app/presentation/recurring_modify/add_recurring_bill_page.dart';
import 'package:budgetup_app/presentation/settings/appearance/appearance_page.dart';
import 'package:budgetup_app/presentation/settings/debug/debug_page.dart';
import 'package:budgetup_app/presentation/settings/settings_page.dart';
import 'package:budgetup_app/presentation/settings/widget/add_as_widget_page.dart';
import 'package:budgetup_app/presentation/summary/summary_page.dart';
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
          builder: (_) => LandingPage(),
        );
      case RouteStrings.settings:
        return CustomPageRoute(
          page: SettingsPage(),
          offset: Offset(1.0, 0.0),
        );
      case RouteStrings.summary:
        return CustomPageRoute(
          page: SummaryPage(),
          offset: Offset(-1.0, 0.0),
        );
      case RouteStrings.summaryDetail:
        if (args is DateTime) {
          return CustomPageRoute(
            page: DashboardPage(date: args),
            offset: Offset(-1.0, 0.0),
          );
        } else {
          return _errorRoute();
        }
      case RouteStrings.appearance:
        return _navigate(
          builder: (_) => ApperancePage(),
        );
      case RouteStrings.widget:
        return _navigate(
          builder: (_) => AddAsWidgetPage(),
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
      case RouteStrings.debug:
        return _navigate(
          builder: (_) => DebugPage(),
        );
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

class CustomPageRoute extends PageRouteBuilder {
  final Widget page;
  final Offset offset;

  CustomPageRoute({
    required this.page,
    required this.offset,
  }) : super(
          pageBuilder: (BuildContext context, Animation<double> animation,
              Animation<double> secondaryAnimation) {
            return page;
          },
          transitionsBuilder: (BuildContext context,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
              Widget child) {
            return SlideTransition(
              position: Tween(
                begin: offset,
                // Start position of the slide (from left)
                end: Offset.zero, // End position of the slide (to center)
              ).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOut, // Replace with your desired curve
                ),
              ),
              child: child,
            );
          },
        );
}

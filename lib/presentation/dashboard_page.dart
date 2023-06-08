import 'package:budgetup_app/helper/date_helper.dart';
import 'package:budgetup_app/presentation/recurring/bloc/recurring_bill_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../helper/colors.dart';
import 'expenses/bloc/expense_bloc.dart';

class DashboardPage extends HookWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    useEffect(() {
      context.read<RecurringBillBloc>().add(LoadRecurringBills());
    }, []);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Material(
                shape: ContinuousRectangleBorder(
                  borderRadius: BorderRadius.circular(40.0),
                ),
                color: Theme.of(context).cardColor,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Total"),
                      Text("PHP 1,000.00"),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 4.0,
                        ),
                        decoration: BoxDecoration(
                          color: red.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: Text("PHP 30.00 higher than last month"),
                      )
                    ],
                  ),
                ),
              ),
              _yourExpenses(),
              _billsPaid(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _yourExpenses() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text("Your Expenses"),
            BlocBuilder<ExpenseBloc, ExpenseState>(
              builder: (context, state) {
                if (state is ExpenseCategoryLoaded) {
                  if (state.expenseCategories.isNotEmpty) {
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: state.expenseCategories.length,
                      itemBuilder: (context, index) {
                        final item = state.expenseCategories[index];
                        return Row(
                          children: [
                            Expanded(child: Text("${item.title}")),
                            Text(
                                "${item.getTotal(DateFilterType.monthly, DateTime.now())}")
                          ],
                        );
                      },
                    );
                  } else {
                    return Center(
                      child: Text("Empty Categories"),
                    );
                  }
                }
                return Text("Empty categories");
              },
            ),
            Divider(),
            Row(
              children: [
                Expanded(
                  child: Text("TOTAL"),
                ),
                Text("PHP 7,200.00"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _billsPaid() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text("Bills you've paid"),
            BlocBuilder<RecurringBillBloc, RecurringBillState>(
              builder: (context, state) {
                print("CURR STATE: ${state}");
                if (state is RecurringBillsLoaded) {
                  if (state.paidRecurringBills.isNotEmpty) {
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: state.paidRecurringBills.length,
                      itemBuilder: (context, index) {
                        final item = state.paidRecurringBills[index];
                        return Row(
                          children: [
                            Expanded(child: Text(item.title ?? "hello")),
                            Text("${item.amount}"),
                          ],
                        );
                      },
                    );
                  } else {
                    return Center(
                      child: Text("Empty Categories"),
                    );
                  }
                }
                return Text("Empty categories");
              },
            ),
            Divider(),
            Row(
              children: [
                Expanded(
                  child: Text("TOTAL"),
                ),
                Text("PHP 7,200.00"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

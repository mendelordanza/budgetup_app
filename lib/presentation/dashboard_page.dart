import 'package:budgetup_app/helper/date_helper.dart';
import 'package:budgetup_app/presentation/recurring/bloc/recurring_bill_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:iconsax/iconsax.dart';
import 'package:collection/collection.dart';

import '../helper/colors.dart';
import 'expenses/bloc/expense_bloc.dart';

class DashboardPage extends HookWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentMonth = formatDate(DateTime.now(), "MMMM yyyy");

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
                      Tooltip(
                        message:
                            'Total Expenses + Total Recurring Bills for the month of $currentMonth',
                        textAlign: TextAlign.center,
                        triggerMode: TooltipTriggerMode.tap,
                        child: Row(
                          children: [
                            Text("Total"),
                            Icon(
                              Iconsax.info_circle,
                              size: 18,
                            ),
                          ],
                        ),
                        showDuration: Duration(seconds: 3),
                      ),
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
              Text(
                "This month - $currentMonth",
                textAlign: TextAlign.center,
              ),
              _yourExpenses(currentMonth),
              _billsPaid(currentMonth),
            ],
          ),
        ),
      ),
    );
  }

  Widget _yourExpenses(String currentMonth) {
    return BlocBuilder<ExpenseBloc, ExpenseState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text("Your Expenses"),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: (state is ExpenseCategoryLoaded &&
                      state.expenseCategories.isNotEmpty)
                  ? Column(
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: state.expenseCategories.length,
                          itemBuilder: (context, index) {
                            final item = state.expenseCategories[index];
                            if (item.expenseTransactions != null &&
                                item.expenseTransactions!.isNotEmpty) {
                              return Row(
                                children: [
                                  Expanded(child: Text("${item.title}")),
                                  Text(
                                      "${item.getTotal(DateFilterType.monthly, DateTime.now())}")
                                ],
                              );
                            }
                          },
                        ),
                        Divider(),
                        Row(
                          children: [
                            Expanded(
                              child: Text("TOTAL"),
                            ),
                            Text("PHP ${state.total}"),
                          ],
                        ),
                      ],
                    )
                  : Center(
                      child: Text(
                          "Your expenses for $currentMonth will show here"),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _billsPaid(String currentMonth) {
    return BlocBuilder<RecurringBillBloc, RecurringBillState>(
        builder: (context, state) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text("Bills you've paid"),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: (state is RecurringBillsLoaded &&
                    state.paidRecurringBills.isNotEmpty)
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: state.paidRecurringBills.length,
                        itemBuilder: (context, index) {
                          final item = state.paidRecurringBills[index];
                          final txn = item.recurringBillTxns?.firstWhereOrNull(
                            (element) =>
                                element.datePaid?.month == DateTime.now().month,
                          );
                          return Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Text(item.title ?? "hello"),
                                    if (txn != null && txn.datePaid != null)
                                      Text(
                                          "paid ${formatDate(txn.datePaid!, "MMM dd, yyyy")}")
                                  ],
                                ),
                              ),
                              Text("${item.amount}"),
                            ],
                          );
                        },
                      ),
                      Divider(),
                      if (state.paidRecurringBills.isNotEmpty)
                        Row(
                          children: [
                            Expanded(
                              child: Text("TOTAL"),
                            ),
                            Text("PHP ${state.total}"),
                          ],
                        ),
                    ],
                  )
                : Center(
                    child: Text(
                        "Your bills paid for $currentMonth will show here"),
                  ),
          ),
        ],
      );
    });
  }
}

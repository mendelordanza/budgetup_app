import 'package:budgetup_app/helper/date_helper.dart';
import 'package:budgetup_app/presentation/custom/balance.dart';
import 'package:budgetup_app/presentation/dashboard/bloc/dashboard_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:iconsax/iconsax.dart';
import 'package:collection/collection.dart';

import '../../helper/colors.dart';

class DashboardPage extends HookWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentMonth = formatDate(DateTime.now(), "MMMM yyyy");

    useEffect(() {
      context.read<DashboardCubit>().getSummary();
      //context.read<RecurringBillBloc>().add(LoadRecurringBills());
    }, []);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "This month - $currentMonth",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(
                height: 20,
              ),
              BlocBuilder<DashboardCubit, DashboardState>(
                builder: (context, state) {
                  if (state is DashboardLoaded) {
                    return Balance(
                        headerLabel: Tooltip(
                          message:
                              'Total Expenses + Total Paid Recurring Bills for the month of $currentMonth',
                          textAlign: TextAlign.center,
                          triggerMode: TooltipTriggerMode.tap,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text("Total"),
                              SizedBox(
                                width: 5,
                              ),
                              Icon(
                                Iconsax.info_circle,
                                size: 16,
                              ),
                            ],
                          ),
                          showDuration: Duration(seconds: 3),
                        ),
                        total: "${state.overallTotal}");
                  }
                  return Balance(
                      headerLabel: Tooltip(
                        message:
                            'Total Expenses + Total Paid Recurring Bills for the month of $currentMonth',
                        textAlign: TextAlign.center,
                        triggerMode: TooltipTriggerMode.tap,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text("Total"),
                            SizedBox(
                              width: 5,
                            ),
                            Icon(
                              Iconsax.info_circle,
                              size: 16,
                            ),
                          ],
                        ),
                        showDuration: Duration(seconds: 3),
                      ),
                      total: "0.00");
                },
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _yourExpenses(currentMonth),
                    SizedBox(
                      height: 20,
                    ),
                    _billsPaid(currentMonth),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _yourExpenses(String currentMonth) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Your Expenses",
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w600,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: (state is DashboardLoaded &&
                      state.expensesCategories.isNotEmpty)
                  ? Column(
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          itemCount: state.expensesCategories.length,
                          itemBuilder: (context, index) {
                            final item = state.expensesCategories[index];
                            if (item.expenseTransactions != null &&
                                item.expenseTransactions!.isNotEmpty) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "${item.title}",
                                        style: TextStyle(
                                          fontSize: 14.0,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    Text(
                                        "${item.getTotalByDate(DateFilterType.monthly, DateTime.now())}")
                                  ],
                                ),
                              );
                            }
                          },
                        ),
                        Divider(),
                        if (state.expensesCategories.isNotEmpty)
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  "TOTAL",
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              Text(
                                "PHP ${state.expensesTotal}",
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w600,
                                  color: secondaryColor,
                                ),
                              ),
                            ],
                          ),
                      ],
                    )
                  : Center(
                      child: Text(
                        "Your expenses for $currentMonth will show here.\nGo to "
                        "transactions tab to start tracking",
                        textAlign: TextAlign.center,
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _billsPaid(String currentMonth) {
    return BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Bills you've paid",
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: (state is DashboardLoaded &&
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
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Text(
                                        item.title ?? "",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      if (txn != null && txn.datePaid != null)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 5.0),
                                          child: Text(
                                            "paid ${formatDate(txn.datePaid!, "MMM dd, yyyy")}",
                                            style: TextStyle(fontSize: 12.0),
                                          ),
                                        )
                                    ],
                                  ),
                                ),
                                Text("${item.amount}"),
                              ],
                            ),
                          );
                        },
                      ),
                      Divider(),
                      if (state.paidRecurringBills.isNotEmpty)
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                "TOTAL",
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Text(
                              "PHP ${state.recurringBillTotal}",
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w600,
                                color: secondaryColor,
                              ),
                            ),
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

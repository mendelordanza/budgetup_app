import 'dart:ui';

import 'package:budgetup_app/helper/date_helper.dart';
import 'package:budgetup_app/helper/string.dart';
import 'package:budgetup_app/injection_container.dart';
import 'package:budgetup_app/presentation/dashboard/bloc/dashboard_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iconsax/iconsax.dart';
import 'package:collection/collection.dart';

import '../../helper/colors.dart';
import '../../helper/shared_prefs.dart';

class SummaryDetailPage extends HookWidget {
  final DateTime date;

  const SummaryDetailPage({required this.date, super.key});

  @override
  Widget build(BuildContext context) {
    final currentMonth = formatDate(date, "MMMM yyyy");

    useEffect(() {
      context.read<DashboardCubit>().getSummary(date);
      return null;
    }, []);

    return Scaffold(
      appBar: AppBar(
        title: Text("$currentMonth Summary Report"),
        centerTitle: true,
        actions: [
          InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SvgPicture.asset(
                "assets/icons/ic_arrow_right.svg",
                height: 20.0,
              ),
            ),
          ),
        ],
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Column(
                  children: [
                    // BlocBuilder<DashboardCubit, DashboardState>(
                    //   builder: (context, state) {
                    //     if (state is DashboardLoaded) {
                    //       return Balance(
                    //           headerLabel: Tooltip(
                    //             message:
                    //                 'Total Spent + Total Paid Recurring Bills for the month of $currentMonth',
                    //             textAlign: TextAlign.center,
                    //             triggerMode: TooltipTriggerMode.tap,
                    //             showDuration: Duration(seconds: 3),
                    //             child: const Row(
                    //               crossAxisAlignment: CrossAxisAlignment.center,
                    //               mainAxisAlignment: MainAxisAlignment.center,
                    //               children: [
                    //                 Text("Total"),
                    //                 SizedBox(
                    //                   width: 5,
                    //                 ),
                    //                 Icon(
                    //                   Iconsax.info_circle,
                    //                   size: 16,
                    //                 ),
                    //               ],
                    //             ),
                    //           ),
                    //           totalAlign: TextAlign.center,
                    //           total: state.overallTotal);
                    //     }
                    //     return Balance(
                    //       headerLabel: Tooltip(
                    //         message:
                    //             'Total Spent + Total Paid Recurring Bills for the month of $currentMonth',
                    //         textAlign: TextAlign.center,
                    //         triggerMode: TooltipTriggerMode.tap,
                    //         showDuration: Duration(seconds: 3),
                    //         child: const Row(
                    //           crossAxisAlignment: CrossAxisAlignment.center,
                    //           mainAxisAlignment: MainAxisAlignment.center,
                    //           children: [
                    //             Text("Total"),
                    //             SizedBox(
                    //               width: 5,
                    //             ),
                    //             Icon(
                    //               Iconsax.info_circle,
                    //               size: 16,
                    //             ),
                    //           ],
                    //         ),
                    //       ),
                    //       totalAlign: TextAlign.center,
                    //       total: 0.00,
                    //     );
                    //   },
                    // ),
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    //   child: Row(
                    //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //     children: [
                    //       Column(
                    //         crossAxisAlignment: CrossAxisAlignment.start,
                    //         children: [
                    //           Text("Allocated Budget"),
                    //           Text(
                    //             "P10,000.00",
                    //             style: TextStyle(
                    //               fontSize: 18.0,
                    //               fontWeight: FontWeight.w600,
                    //             ),
                    //           ),
                    //         ],
                    //       ),
                    //       Column(
                    //         crossAxisAlignment: CrossAxisAlignment.end,
                    //         children: [
                    //           Text("Remaining"),
                    //           Text(
                    //             "P10,000.00",
                    //             style: TextStyle(
                    //               fontSize: 18.0,
                    //               fontWeight: FontWeight.w600,
                    //             ),
                    //           ),
                    //         ],
                    //       )
                    //     ],
                    //   ),
                    // ),
                  ],
                ),
              ),
              Stack(
                clipBehavior: Clip.none,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      color: Theme.of(context).cardColor,
                      child: Column(
                        children: [
                          _salary(),
                          Divider(),
                          _biggestCategory(),
                          Divider(),
                          // _biggestTransaction(),
                          // Divider(),
                          _yourExpenses(context, currentMonth),
                          Divider(),
                          _billsPaid(context, currentMonth),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: -10,
                    left: 0,
                    right: 0,
                    child: SvgPicture.asset(
                      "assets/icons/ic_receipt_up.svg",
                      width: MediaQuery.of(context).size.width,
                      color: Theme.of(context).cardColor,
                      fit: BoxFit.fill,
                    ),
                  ),
                ],
              ),
              SvgPicture.asset(
                "assets/icons/ic_receipt_down.svg",
                width: MediaQuery.of(context).size.width,
                color: Theme.of(context).cardColor,
                fit: BoxFit.fill,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _salary() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoaded) {
            final initialSalary =
                decimalFormatterWithSymbol(state.initialSalary);
            final total = decimalFormatterWithSymbol(state.overallTotal);
            final remainingSalary =
                decimalFormatterWithSymbol(state.remainingSalary);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Your Salary",
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(
                  height: 16.0,
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    color: Theme.of(context).scaffoldBackgroundColor,
                  ),
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      summaryItem(
                        left: Text("Initial Salary"),
                        right: Text(initialSalary),
                      ),
                      summaryItem(
                        left: const Tooltip(
                          message: 'Total Expense + Total Paid Bills',
                          textAlign: TextAlign.center,
                          triggerMode: TooltipTriggerMode.tap,
                          showDuration: Duration(seconds: 3),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Total"),
                              SizedBox(
                                width: 5,
                              ),
                              Icon(
                                Iconsax.info_circle,
                                size: 14,
                              ),
                            ],
                          ),
                        ),
                        right: Text(
                          "-$total",
                          style: TextStyle(
                            color: Colors.red,
                          ),
                        ),
                      ),
                      Divider(),
                      summaryItem(
                        left: Text("Remaining Salary"),
                        right: Text(remainingSalary),
                      )
                    ],
                  ),
                )
              ],
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Initial Salary"),
                  Text("0.00"),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Tooltip(
                    message: 'Total Expense + Total Paid Recurring Bills',
                    textAlign: TextAlign.center,
                    triggerMode: TooltipTriggerMode.tap,
                    showDuration: Duration(seconds: 3),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
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
                  ),
                  Text("0.00"),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Remaining Salary"),
                  Text("0.00"),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _biggestCategory() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoaded && state.mostSpentCategory != null) {
            final total = decimalFormatterWithSymbol(state.mostSpentCategory!
                .getTotalByDate(DateFilterType.monthly, date));
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Your Most Spent Category 😱",
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(
                  height: 16.0,
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    color: Theme.of(context).scaffoldBackgroundColor,
                  ),
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          "${state.mostSpentCategory!.icon} ${state.mostSpentCategory!.title}"),
                      Text(total),
                    ],
                  ),
                )
              ],
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Your Most Spent Category 😱",
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(
                height: 16.0,
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  color: Theme.of(context).scaffoldBackgroundColor,
                ),
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Most spent category for the month of ${formatDate(date, "MMMM yyyy")} will show here",
                ),
              )
            ],
          );
        },
      ),
    );
  }

  Widget _biggestTransaction() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Your Biggest Transaction 😱",
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(
            height: 16.0,
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              color: Colors.black54,
            ),
            padding: EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("on July 25, 2023"),
                Text("P10,000.00"),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _yourExpenses(BuildContext context, String currentMonth) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "Your Expenses",
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(
            height: 16.0,
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
            padding: EdgeInsets.all(16.0),
            child: BlocBuilder<DashboardCubit, DashboardState>(
              builder: (context, state) {
                if ((state is DashboardLoaded &&
                    state.expensesCategories.isNotEmpty)) {
                  state.expensesCategories.sort(
                    (a, b) => b
                        .getTotalByDate(DateFilterType.monthly, date)
                        .compareTo(
                            a.getTotalByDate(DateFilterType.monthly, date)),
                  );
                  return Column(
                    children: [
                      ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: state.expensesCategories.length,
                        itemBuilder: (context, index) {
                          final item = state.expensesCategories[index];
                          if (item.expenseTransactions != null &&
                              item.expenseTransactions!.isNotEmpty) {
                            return summaryItem(
                              left: Text(
                                "${item.title}",
                                style: const TextStyle(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              right: Text(
                                decimalFormatterWithSymbol(
                                  item.getTotalByDate(
                                      DateFilterType.monthly, date),
                                ),
                              ),
                            );
                          }
                          return Container();
                        },
                      ),
                      if (state.expensesCategories.isNotEmpty)
                        summaryItem(
                          left: Text(
                            "TOTAL",
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          right: Text(
                            decimalFormatterWithSymbol(state.expensesTotal),
                            style: const TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w600,
                              color: secondaryColor,
                            ),
                          ),
                        ),
                    ],
                  );
                } else {
                  return Center(
                    child: Text(
                      "Your expenses for $currentMonth will show here.",
                      textAlign: TextAlign.center,
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  convertAmount({required double amount}) {
    final sharedPrefs = getIt<SharedPrefs>();
    return sharedPrefs.getCurrencyCode() == "USD"
        ? amount
        : amount / sharedPrefs.getCurrencyRate();
  }

  Widget _billsPaid(BuildContext context, String currentMonth) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            "Bills you've paid",
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(
            height: 16.0,
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
            padding: EdgeInsets.all(16.0),
            child: BlocBuilder<DashboardCubit, DashboardState>(
              builder: (context, state) {
                if (state is DashboardLoaded &&
                    state.paidRecurringBills.isNotEmpty) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: state.paidRecurringBills.length,
                        itemBuilder: (context, index) {
                          final item = state.paidRecurringBills[index];
                          final txn = item.recurringBillTxns?.firstWhereOrNull(
                            (element) =>
                                getMonthFromDate(element.datePaid!) ==
                                getMonthFromDate(date),
                          );
                          return summaryItem(
                            left: Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    item.title ?? "",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  if (txn != null && txn.datePaid != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 3.0),
                                      child: Text(
                                        "paid ${formatDate(txn.datePaid!, "MMM dd, yyyy")}",
                                        style: TextStyle(fontSize: 12.0),
                                      ),
                                    )
                                ],
                              ),
                            ),
                            right: Text(
                              decimalFormatterWithSymbol(item.amount ?? 0.00),
                            ),
                          );
                        },
                      ),
                      if (state.paidRecurringBills.isNotEmpty)
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                "TOTAL",
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Text(
                              decimalFormatterWithSymbol(
                                  state.recurringBillTotal),
                              style: const TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w600,
                                color: secondaryColor,
                              ),
                            ),
                          ],
                        ),
                    ],
                  );
                } else {
                  return Center(
                    child: Text(
                      "Your bills paid for $currentMonth will show here.",
                      textAlign: TextAlign.center,
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget summaryItem({
    required Widget left,
    required Widget right,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          left,
          right,
        ],
      ),
    );
  }
}

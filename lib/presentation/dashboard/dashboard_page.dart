import 'dart:ui';

import 'package:budgetup_app/helper/date_helper.dart';
import 'package:budgetup_app/helper/string.dart';
import 'package:budgetup_app/injection_container.dart';
import 'package:budgetup_app/presentation/custom/balance.dart';
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

class DashboardPage extends HookWidget {
  final DateTime date;

  DashboardPage({required this.date, super.key});

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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              BlocBuilder<DashboardCubit, DashboardState>(
                builder: (context, state) {
                  if (state is DashboardLoaded) {
                    return Balance(
                        headerLabel: Tooltip(
                          message:
                              'Total Spent + Total Paid Recurring Bills for the month of $currentMonth',
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
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                        total: state.overallTotal);
                  }
                  return Balance(
                    headerLabel: Tooltip(
                      message:
                          'Total Spent + Total Paid Recurring Bills for the month of $currentMonth',
                      textAlign: TextAlign.center,
                      triggerMode: TooltipTriggerMode.tap,
                      showDuration: Duration(seconds: 3),
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
                    ),
                    total: 0.00,
                  );
                },
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: Column(
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.only(top: 20.0),
                              child: Container(
                                padding: const EdgeInsets.all(16.0),
                                color: Theme.of(context).cardColor,
                                child: Column(
                                  children: [
                                    _yourExpenses(currentMonth),
                                    SizedBox(
                                      height: 20,
                                    ),
                                    _billsPaid(currentMonth),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              top: -20,
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
              ),
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
                          physics: NeverScrollableScrollPhysics(),
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
                                    Text(decimalFormatterWithSymbol(
                                        item.getTotalByDate(
                                            DateFilterType.monthly, date))),
                                  ],
                                ),
                              );
                            }
                            return Container();
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
                                decimalFormatterWithSymbol(state.expensesTotal),
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
                        "Your expenses for $currentMonth will show here.",
                        textAlign: TextAlign.center,
                      ),
                    ),
            ),
          ],
        );
      },
    );
  }

  convertAmount({required double amount}) {
    final sharedPrefs = getIt<SharedPrefs>();
    return sharedPrefs.getCurrencyCode() == "USD"
        ? amount
        : amount / sharedPrefs.getCurrencyRate();
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
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
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
                                              const EdgeInsets.only(top: 3.0),
                                          child: Text(
                                            "paid ${formatDate(txn.datePaid!, "MMM dd, yyyy")}",
                                            style: TextStyle(fontSize: 12.0),
                                          ),
                                        )
                                    ],
                                  ),
                                ),
                                Text(
                                  decimalFormatterWithSymbol(
                                      item.amount ?? 0.00),
                                ),
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
                              decimalFormatterWithSymbol(
                                  state.recurringBillTotal),
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
                      "Your bills paid for $currentMonth will show here.",
                      textAlign: TextAlign.center,
                    ),
                  ),
          ),
        ],
      );
    });
  }
}

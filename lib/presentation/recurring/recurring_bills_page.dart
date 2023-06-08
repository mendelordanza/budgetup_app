import 'package:budgetup_app/helper/route_strings.dart';
import 'package:budgetup_app/presentation/recurring/bloc/recurring_bill_bloc.dart';
import 'package:budgetup_app/presentation/recurring_date_filter/recurring_date_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:collection/collection.dart';

import '../../domain/recurring_bill_txn.dart';
import '../../helper/date_helper.dart';
import '../../helper/shared_prefs.dart';
import '../../injection_container.dart';
import '../recurring_date_filter/bloc/recurring_date_filter_bloc.dart';

class RecurringBillsPage extends HookWidget {
  const RecurringBillsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sharedPrefs = getIt<SharedPrefs>();
    final currentSelectedDate =
        DateTime.parse(sharedPrefs.getRecurringSelectedDate());
    final currentDateFilterType =
        sharedPrefs.getRecurringSelectedDateFilterType();

    useEffect(() {
      context.read<RecurringBillBloc>().add(LoadRecurringBills());
    }, []);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            TextButton(
              onPressed: () {
                showModalBottomSheet(
                  backgroundColor: Colors.transparent,
                  context: context,
                  builder: (context) {
                    return RecurringDateBottomSheet();
                  },
                );
              },
              child: BlocBuilder<RecurringDateFilterBloc,
                  RecurringDateFilterState>(
                builder: (context, state) {
                  if (state is RecurringDateFilterSelected) {
                    return Text(
                        getMonthText(state.dateFilterType, state.selectedDate));
                  }
                  return Text(getMonthText(
                      enumFromString(currentDateFilterType),
                      currentSelectedDate));
                },
              ),
            ),
            Row(
              children: [
                Spacer(),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, RouteStrings.addRecurringBill);
                  },
                  child: Text("Add Recurring Bill"),
                ),
              ],
            ),
            Expanded(
              child: BlocBuilder<RecurringBillBloc, RecurringBillState>(
                builder: (context, state) {
                  if (state is RecurringBillsLoaded) {
                    if (state.recurringBills.isNotEmpty) {
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: state.recurringBills.length,
                        itemBuilder: (context, index) {
                          final item = state.recurringBills[index];
                          final txn = item.recurringBillTxns?.firstWhereOrNull(
                            (element) =>
                                element.datePaid?.month ==
                                currentSelectedDate.month,
                          );
                          return GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                RouteStrings.addRecurringBill,
                                arguments: item,
                              );
                            },
                            child: Row(
                              children: [
                                BlocBuilder<RecurringDateFilterBloc,
                                    RecurringDateFilterState>(
                                  builder: (context, state) {
                                    if (state is RecurringDateFilterSelected) {
                                      final txn = item.recurringBillTxns
                                          ?.firstWhereOrNull(
                                        (element) =>
                                            element.datePaid?.month ==
                                            state.selectedDate.month,
                                      );
                                      return Checkbox(
                                        value: item.isPaid(state.selectedDate)
                                            ? true
                                            : false,
                                        onChanged: (checked) async {
                                          if (item.isPaid(state.selectedDate)) {
                                            context
                                                .read<RecurringBillBloc>()
                                                .add(
                                                  RemoveRecurringBillTxn(
                                                    recurringBill: item,
                                                    recurringBillTxn: txn!,
                                                  ),
                                                );
                                          } else {
                                            final newRecurringTxn =
                                                RecurringBillTxn(
                                              isPaid: checked ?? false,
                                              datePaid: removeTimeFromDate(
                                                  state.selectedDate),
                                            );
                                            context
                                                .read<RecurringBillBloc>()
                                                .add(
                                                  AddRecurringBillTxn(
                                                    recurringBill: item,
                                                    recurringBillTxn:
                                                        newRecurringTxn,
                                                  ),
                                                );
                                          }
                                        },
                                      );
                                    }
                                    return Checkbox(
                                      value: item.isPaid(currentSelectedDate)
                                          ? true
                                          : false,
                                      onChanged: (checked) async {
                                        if (item.isPaid(currentSelectedDate)) {
                                          context.read<RecurringBillBloc>().add(
                                                RemoveRecurringBillTxn(
                                                  recurringBill: item,
                                                  recurringBillTxn: txn!,
                                                ),
                                              );
                                        } else {
                                          final newRecurringTxn =
                                              RecurringBillTxn(
                                            isPaid: checked ?? false,
                                            datePaid: removeTimeFromDate(
                                                currentSelectedDate),
                                          );
                                          context.read<RecurringBillBloc>().add(
                                                AddRecurringBillTxn(
                                                  recurringBill: item,
                                                  recurringBillTxn:
                                                      newRecurringTxn,
                                                ),
                                              );
                                        }
                                      },
                                    );
                                  },
                                ),
                                Expanded(child: Text(item.title ?? "hello")),
                                Text("${item.amount}"),
                                IconButton(
                                  onPressed: () {
                                    context.read<RecurringBillBloc>().add(
                                        RemoveRecurringBill(
                                            recurringBill: item));
                                  },
                                  icon: Icon(Icons.delete),
                                ),
                              ],
                            ),
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
            ),
          ],
        ),
      ),
    );
  }
}

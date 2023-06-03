import 'package:budgetup_app/helper/route_strings.dart';
import 'package:budgetup_app/presentation/recurring/bloc/recurring_bill_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:collection/collection.dart';

import '../../domain/recurring_bill_txn.dart';

class RecurringBillsPage extends HookWidget {
  const RecurringBillsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    useEffect(() {
      context.read<RecurringBillBloc>().add(LoadRecurringBills());
    }, []);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
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
                                item.createdAt?.month,
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
                                Checkbox(
                                  value: txn != null ? true : false,
                                  onChanged: (checked) async {
                                    if (txn != null) {
                                      context.read<RecurringBillBloc>().add(
                                            RemoveRecurringBillTxn(
                                              recurringBill: item,
                                              recurringBillTxn: txn,
                                            ),
                                          );
                                    } else {
                                      final newRecurringTxn = RecurringBillTxn(
                                        isPaid: checked ?? false,
                                        datePaid: DateTime.now(),
                                      );
                                      context.read<RecurringBillBloc>().add(
                                            AddRecurringBillTxn(
                                              recurringBill: item,
                                              recurringBillTxn: newRecurringTxn,
                                            ),
                                          );
                                    }
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

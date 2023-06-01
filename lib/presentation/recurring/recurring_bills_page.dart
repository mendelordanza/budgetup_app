import 'package:budgetup_app/helper/route_strings.dart';
import 'package:budgetup_app/presentation/recurring/bloc/recurring_bill_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:iconsax/iconsax.dart';
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
                    Navigator.pushNamed(context, RouteStrings.addCategory);
                  },
                  child: Text("Add Category"),
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
                                RouteStrings.transactions,
                                arguments: item,
                              );
                            },
                            child: Column(
                              children: [
                                Checkbox(
                                  value: txn != null ? txn.isPaid : false,
                                  onChanged: (value) {
                                    //When user tick, add a recurring bill txn
                                    final newRecurringTxn = RecurringBillTxn(
                                      isPaid: value ?? false,
                                      datePaid: DateTime.now(),
                                    );
                                    context.read<RecurringBillBloc>().add(
                                          AddRecurringBillTxn(
                                            recurringBill: item,
                                            recurringBillTxn: newRecurringTxn,
                                          ),
                                        );
                                  },
                                ),
                                Text(item.title ?? "hello"),
                                Text("${item.amount}")
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
      floatingActionButton: FloatingActionButton(
        elevation: 0,
        onPressed: () {
          //TODO Add transaction with category dropdown
        },
        shape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.circular(40.0),
        ),
        child: Icon(
          Iconsax.add,
          color: Colors.white,
        ),
      ),
    );
  }
}

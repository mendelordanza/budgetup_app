import 'package:budgetup_app/domain/recurring_bill.dart';
import 'package:budgetup_app/helper/colors.dart';
import 'package:budgetup_app/helper/route_strings.dart';
import 'package:budgetup_app/helper/string.dart';
import 'package:budgetup_app/presentation/custom/balance.dart';
import 'package:budgetup_app/presentation/recurring/bloc/recurring_bill_bloc.dart';
import 'package:budgetup_app/presentation/recurring_date_filter/recurring_date_bottom_sheet.dart';
import 'package:budgetup_app/presentation/recurring_modify/bloc/recurring_modify_bloc.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:collection/collection.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iconsax/iconsax.dart';

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
      context
          .read<RecurringBillBloc>()
          .add(LoadRecurringBills(currentSelectedDate));
      return null;
    }, []);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      backgroundColor: Colors.transparent,
                      context: context,
                      builder: (context) {
                        return RecurringDateBottomSheet();
                      },
                      isScrollControlled: true,
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      BlocBuilder<RecurringDateFilterBloc,
                          RecurringDateFilterState>(
                        builder: (context, state) {
                          if (state is RecurringDateFilterSelected) {
                            return Text(
                              getMonthText(
                                  state.dateFilterType, state.selectedDate),
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).primaryColor,
                              ),
                            );
                          }
                          return Text(
                            getMonthText(dateFilterTypeFromString(currentDateFilterType),
                                currentSelectedDate),
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context).primaryColor,
                            ),
                          );
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: SvgPicture.asset(
                          "assets/icons/ic_arrow_down.svg",
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              BlocBuilder<RecurringBillBloc, RecurringBillState>(
                builder: (context, state) {
                  if (state is RecurringBillsLoaded && state.total != null) {
                    return Balance(
                      headerLabel: Text("Total Paid Recurring Bills"),
                      total: state.total!,
                    );
                  }
                  return Text("No categories");
                },
              ),
              SizedBox(
                height: 27.0,
              ),
              Row(
                children: [
                  Spacer(),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                          context, RouteStrings.addRecurringBill);
                    },
                    child: Row(
                      children: [
                        Icon(
                          Iconsax.add,
                          size: 20.0,
                        ),
                        Text("Add Recurring Bill"),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 10.0,
              ),
              Expanded(
                  child:
                      BlocListener<RecurringModifyBloc, RecurringModifyState>(
                listener: (context, state) {
                  if (state is RecurringBillRemoved ||
                      state is RecurringBillEdited ||
                      state is RecurringBillAdded) {
                    Navigator.maybePop(context);
                  }
                },
                child: BlocBuilder<RecurringBillBloc, RecurringBillState>(
                  builder: (context, state) {
                    if (state is RecurringBillsLoaded) {
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
                          return _recurringBillItem(
                            context,
                            item: item,
                            txn: txn,
                            currentSelectedDate: currentSelectedDate,
                          );
                        },
                      );
                    }
                    return Text("No Recurring Bills");
                  },
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _recurringBillItem(
    BuildContext context, {
    required RecurringBill item,
    RecurringBillTxn? txn,
    required DateTime currentSelectedDate,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13.0),
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(
            context,
            RouteStrings.addRecurringBill,
            arguments: item,
          );
        },
        child: BlocBuilder<RecurringDateFilterBloc, RecurringDateFilterState>(
          builder: (context, state) {
            if (state is RecurringDateFilterSelected) {
              final txn = item.recurringBillTxns?.firstWhereOrNull(
                (element) =>
                    element.datePaid?.month == state.selectedDate.month,
              );
              return _checkboxItem(context,
                  selectedDate: state.selectedDate, item: item, txn: txn);
            }
            return _checkboxItem(
              context,
              selectedDate: currentSelectedDate,
              item: item,
              txn: txn,
            );
          },
        ),
      ),
    );
  }

  Widget _checkboxItem(
    BuildContext context, {
    required DateTime selectedDate,
    required RecurringBill item,
    RecurringBillTxn? txn,
  }) {
    return Slidable(
      // Specify a key if the Slidable is dismissible.
      key: ValueKey(item.id!),

      // The end action pane is the one at the right or the bottom side.
      endActionPane: ActionPane(
        motion: ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) {
              context.read<RecurringModifyBloc>().add(RemoveRecurringBill(
                  selectedDate: selectedDate, recurringBill: item));
            },
            autoClose: true,
            backgroundColor: red,
            foregroundColor: Colors.white,
            icon: Iconsax.trash,
            label: 'Delete',
            borderRadius: BorderRadius.all(
              Radius.circular(16.0),
            ),
          ),
        ],
      ),

      // The child of the Slidable is what the user sees when the
      // component is not dragged.
      child: Material(
        shape: SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius(
            cornerRadius: 16,
            cornerSmoothing: 1.0,
          ),
        ),
        color: Theme.of(context).cardColor,
        child: Row(
          children: [
            Container(
              height: 70.0,
              child: Checkbox(
                activeColor: secondaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    3.0,
                  ),
                ),
                value: item.isPaid(selectedDate) ? true : false,
                onChanged: (checked) async {
                  if (item.isPaid(selectedDate) && txn != null) {
                    context.read<RecurringModifyBloc>().add(
                          RemoveRecurringBillTxn(
                            selectedDate: selectedDate,
                            recurringBill: item,
                            recurringBillTxn: txn,
                          ),
                        );
                  } else {
                    final newRecurringTxn = RecurringBillTxn(
                      isPaid: true,
                      datePaid: removeTimeFromDate(selectedDate),
                    );
                    context.read<RecurringModifyBloc>().add(
                          AddRecurringBillTxn(
                            selectedDate: selectedDate,
                            recurringBill: item,
                            recurringBillTxn: newRecurringTxn,
                          ),
                        );
                  }
                },
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(item.title ?? "hello"),
                          if (item.isPaid(selectedDate) && txn != null)
                            Text(
                              "paid ${formatDate(txn.datePaid!, "MMM dd, yyyy")}",
                              style: TextStyle(
                                fontSize: 12.0,
                              ),
                            )
                          else if (item.reminderDate != null)
                            Text(
                              "every ${formatDate(item.reminderDate!, "dd")} of the month",
                              style: TextStyle(
                                fontSize: 12.0,
                              ),
                            ),
                        ],
                      ),
                    ),
                    Text(
                      decimalFormatter(item.amount ?? 0.00),
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:budgetup_app/domain/recurring_bill.dart';
import 'package:budgetup_app/helper/colors.dart';
import 'package:budgetup_app/helper/route_strings.dart';
import 'package:budgetup_app/helper/string.dart';
import 'package:budgetup_app/presentation/custom/balance.dart';
import 'package:budgetup_app/presentation/custom/date_filter_button.dart';
import 'package:budgetup_app/presentation/recurring/bloc/recurring_bill_bloc.dart';
import 'package:budgetup_app/presentation/recurring_modify/add_recurring_bill_page.dart';
import 'package:budgetup_app/presentation/recurring_modify/bloc/recurring_modify_bloc.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:collection/collection.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:iconsax/iconsax.dart';

import '../../domain/recurring_bill_txn.dart';
import '../../helper/date_helper.dart';
import '../../helper/shared_prefs.dart';
import '../../injection_container.dart';
import '../custom/date_filter_bottom_sheet.dart';
import '../recurring_date_filter/bloc/recurring_date_filter_bloc.dart';

class RecurringBillsPage extends HookWidget {
  RecurringBillsPage({Key? key}) : super(key: key);

  final types = [
    DateSelection(
      "Monthly",
      DateFilterType.monthly,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final sharedPrefs = getIt<SharedPrefs>();

    final selectedFilterType = useState<DateFilterType>(
        dateFilterTypeFromString(
            sharedPrefs.getRecurringSelectedDateFilterType()));
    final selectedDate = useState<DateTime>(
      sharedPrefs.getRecurringSelectedDate().isNotEmpty
          ? DateTime.parse(sharedPrefs.getRecurringSelectedDate())
          : DateTime.now(),
    );

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
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      backgroundColor: Colors.transparent,
                      context: context,
                      builder: (context) {
                        return StatefulBuilder(builder: (context, setState) {
                          return DateFilterBottomSheet(
                            types: types,
                            onSelectFilterType: (type) {
                              selectedFilterType.value = type;
                              context.read<RecurringDateFilterBloc>().add(
                                  RecurringSelectDate(
                                      type, selectedDate.value));
                              context.read<RecurringBillBloc>().add(
                                    LoadRecurringBills(selectedDate.value),
                                  );
                              setState(() {});
                            },
                            onSelectDate: (date) {
                              selectedDate.value = date;
                              context.read<RecurringDateFilterBloc>().add(
                                  RecurringSelectDate(
                                      selectedFilterType.value, date));
                              context.read<RecurringBillBloc>().add(
                                    LoadRecurringBills(date),
                                  );
                              setState(() {});
                            },
                            onSelectYear: (year) {
                              context
                                  .read<RecurringDateFilterBloc>()
                                  .add(RecurringSelectDate(
                                      selectedFilterType.value,
                                      DateTime(
                                        year,
                                        selectedDate.value.month,
                                        selectedDate.value.day,
                                      )));
                              context.read<RecurringBillBloc>().add(
                                    LoadRecurringBills(
                                      DateTime(
                                        year,
                                        selectedDate.value.month,
                                        selectedDate.value.day,
                                      ),
                                    ),
                                  );
                            },
                            selectedFilterType: selectedFilterType,
                            selectedDate: selectedDate,
                          );
                        });

                        //return RecurringDateBottomSheet();
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
                            return DateFilterButton(
                              text: getMonthText(
                                  state.dateFilterType, state.selectedDate),
                            );
                          }
                          return DateFilterButton(
                            text: getMonthText(
                                dateFilterTypeFromString(currentDateFilterType),
                                currentSelectedDate),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              BlocBuilder<RecurringBillBloc, RecurringBillState>(
                builder: (context, state) {
                  if (state is RecurringBillsLoaded && state.total != null) {
                    return Balance(
                      headerLabel: Tooltip(
                        message:
                            'Sum of all checked recurring bills for ${getMonthText(dateFilterTypeFromString(currentDateFilterType), currentSelectedDate)}',
                        textAlign: TextAlign.center,
                        triggerMode: TooltipTriggerMode.tap,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Total Paid"),
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
                      total: state.total!,
                    );
                  }
                  return Balance(
                    headerLabel: Text("Total Paid"),
                    total: 0.00,
                  );
                },
              ),
              Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
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
                      behavior: HitTestBehavior.translucent,
                    ),
                  ],
                ),
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
                    if (state is RecurringBillsLoaded &&
                        state.recurringBills.isNotEmpty) {
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
                    return Center(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text("No recurring bills"),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              "ex. Things you pay monthly, quarterly, or yearly – Internet, Phone Bill, Netflix etc.",
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
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
                    getMonthFromDate(element.datePaid!) ==
                    getMonthFromDate(state.selectedDate),
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
                          else if (item.reminderDate != null &&
                              item.interval !=
                                  RecurringBillInterval.yearly.name)
                            Text(
                              "every ${item.reminderDate!.day}${getDayOfMonthSuffix(item.reminderDate!.day)} ${item.interval}",
                              style: TextStyle(
                                fontSize: 12.0,
                              ),
                            )
                          else
                            Text(
                              "every ${formatDate(item.reminderDate!, "MMMM")} "
                              "${item.reminderDate!.day}${getDayOfMonthSuffix(item.reminderDate!.day)} "
                              "${item.interval}",
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

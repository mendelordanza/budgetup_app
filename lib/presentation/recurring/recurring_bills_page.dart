import 'package:budgetup_app/domain/recurring_bill.dart';
import 'package:budgetup_app/helper/colors.dart';
import 'package:budgetup_app/helper/route_strings.dart';
import 'package:budgetup_app/helper/string.dart';
import 'package:budgetup_app/presentation/custom/balance.dart';
import 'package:budgetup_app/presentation/custom/custom_action_dialog.dart';
import 'package:budgetup_app/presentation/custom/date_filter_button.dart';
import 'package:budgetup_app/presentation/recurring/bloc/recurring_bill_bloc.dart';
import 'package:budgetup_app/presentation/recurring/recurring_confirmation_dialog.dart';
import 'package:budgetup_app/presentation/recurring_modify/add_recurring_bill_page.dart';
import 'package:budgetup_app/presentation/recurring_modify/bloc/recurring_modify_bloc.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:collection/collection.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:home_widget/home_widget.dart';
import 'package:iconsax/iconsax.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../domain/recurring_bill_txn.dart';
import '../../helper/constant.dart';
import '../../helper/date_helper.dart';
import '../../helper/shared_prefs.dart';
import '../../injection_container.dart';
import '../custom/custom_button.dart';
import '../custom/date_filter_bottom_sheet.dart';
import '../custom/delete_dialog.dart';
import '../paywall/paywall.dart';
import '../recurring_date_filter/bloc/recurring_date_filter_bloc.dart';

class RecurringBillsPage extends HookWidget {
  RecurringBillsPage({Key? key}) : super(key: key);

  final types = [
    DateSelection(
      "Monthly",
      DateFilterType.monthly,
    ),
  ];

  Future _setWidget() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      final isSubscribed = customerInfo.entitlements.active[entitlementId] !=
              null &&
          customerInfo.entitlements.active[entitlementId]!.isSandbox == false;
      return Future.wait([
        HomeWidget.saveWidgetData<bool>('isSubscribed', isSubscribed),
      ]);
    } on PlatformException catch (exception) {
      debugPrint('Error Sending Data. $exception');
    }
  }

  Future _updateWidget() async {
    try {
      HomeWidget.updateWidget(
          name: 'UpcomingBillsWidgetProvider', iOSName: 'BillsWidget');
    } on PlatformException catch (exception) {
      debugPrint('Error Updating Widget. $exception');
    }
  }

  showPaywall(BuildContext context) async {
    try {
      final offerings = await Purchases.getOfferings();
      if (context.mounted && offerings.current != null) {
        await showModalBottomSheet(
          isDismissible: true,
          isScrollControlled: true,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
          ),
          context: context,
          builder: (BuildContext context) {
            return StatefulBuilder(
                builder: (BuildContext context, StateSetter setModalState) {
              return PaywallView(
                offering: offerings.current!,
              );
            });
          },
        );
      }
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

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

    final tabController = useTabController(
      initialLength: 4,
    );

    final isSubscribed = useState(false);
    useEffect(() {
      context
          .read<RecurringBillBloc>()
          .add(LoadRecurringBills(currentSelectedDate));
      Purchases.addCustomerInfoUpdateListener((customerInfo) {
        final entitlement = customerInfo.entitlements.active[entitlementId];
        isSubscribed.value =
            entitlement != null && entitlement.isSandbox == false;
        _setWidget();
        _updateWidget();
      });

      return null;
    }, []);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(
            16.0,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: BlocBuilder<RecurringBillBloc, RecurringBillState>(
                      builder: (context, state) {
                        if (state is RecurringBillsLoaded &&
                            state.total != null) {
                          return Balance(
                            headerLabel: Tooltip(
                              message:
                                  'Sum of all paid recurring bills for ${getMonthText(dateFilterTypeFromString(currentDateFilterType), currentSelectedDate)}',
                              textAlign: TextAlign.center,
                              triggerMode: TooltipTriggerMode.tap,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
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
                  ),
                  GestureDetector(
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
                                  dateFilterTypeFromString(
                                      currentDateFilterType),
                                  currentSelectedDate),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: TabBar(
                  controller: tabController,
                  tabs: RecurringBillInterval.values
                      .map(
                        (item) => Tab(
                            text:
                                "${item.name[0].toUpperCase()}${item.name.substring(1)}"),
                      )
                      .toList()
                    ..insert(
                      0,
                      Tab(text: "All"),
                    ),
                  isScrollable: false,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorColor: Theme.of(context).primaryColor,
                  labelColor: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              BlocBuilder<RecurringBillBloc, RecurringBillState>(
                builder: (context, state) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            final customerInfo =
                                await Purchases.getCustomerInfo();
                            final hasData = customerInfo
                                        .entitlements.active[entitlementId] !=
                                    null &&
                                customerInfo.entitlements.active[entitlementId]!
                                        .isSandbox ==
                                    false;

                            if (context.mounted) {
                              if (hasData ||
                                  (state is RecurringBillsLoaded &&
                                      state.recurringBills.length < 5)) {
                                Navigator.pushNamed(
                                    context, RouteStrings.addRecurringBill);
                              } else {
                                showPaywall(context);
                              }
                            }
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
                  );
                },
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
                      return TabBarView(
                        controller: tabController,
                        children: RecurringBillInterval.values.map((interval) {
                          final list = state.recurringBills
                              .where((bill) => bill.interval == interval.name)
                              .toList();
                          if (list.isNotEmpty) {
                            return ListView.builder(
                              shrinkWrap: true,
                              itemCount: list.length,
                              itemBuilder: (context, index) {
                                final item = list[index];
                                final txn =
                                    item.recurringBillTxns?.firstWhereOrNull(
                                  (element) =>
                                      element.datePaid?.month ==
                                      currentSelectedDate.month,
                                );
                                return _recurringBillItem(
                                  context,
                                  item: item,
                                  txn: txn,
                                  currentSelectedDate: currentSelectedDate,
                                  currentDateFilterType: currentDateFilterType,
                                );
                              },
                            );
                          }
                          return emptyList(
                            context,
                            interval: interval.name,
                            state: state,
                          );
                        }).toList()
                          ..insert(
                            0,
                            allTab(context,
                                state: state,
                                currentSelectedDate: currentSelectedDate,
                                currentDateFilterType: currentDateFilterType),
                          ),
                      );
                    }
                    return emptyList(context, state: state);
                  },
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget allTab(
    BuildContext context, {
    required RecurringBillState state,
    required DateTime currentSelectedDate,
    required String currentDateFilterType,
  }) {
    if (state is RecurringBillsLoaded && state.recurringBills.isNotEmpty) {
      return ListView.builder(
        shrinkWrap: true,
        itemCount: state.recurringBills.length,
        itemBuilder: (context, index) {
          final item = state.recurringBills[index];
          final txn = item.recurringBillTxns?.firstWhereOrNull(
            (element) => element.datePaid?.month == currentSelectedDate.month,
          );
          return _recurringBillItem(
            context,
            item: item,
            txn: txn,
            currentSelectedDate: currentSelectedDate,
            currentDateFilterType: currentDateFilterType,
          );
        },
      );
    }
    return emptyList(context, state: state);
  }

  Widget emptyList(
    BuildContext context, {
    String? interval,
    required RecurringBillState state,
  }) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Text(
              "No ${interval ?? ""} recurring bills yet",
              textAlign: TextAlign.center,
            ),
            TextButton(
              onPressed: () async {
                final customerInfo = await Purchases.getCustomerInfo();
                final hasData =
                    customerInfo.entitlements.active[entitlementId] != null &&
                        customerInfo.entitlements.active[entitlementId]!
                                .isSandbox ==
                            false;

                if (context.mounted) {
                  if (hasData ||
                      (state is RecurringBillsLoaded &&
                          state.recurringBills.length < 5)) {
                    Navigator.pushNamed(context, RouteStrings.addRecurringBill);
                  } else {
                    showPaywall(context);
                  }
                }
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Iconsax.add),
                  Text("Add your first recurring bill"),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _recurringBillItem(
    BuildContext context, {
    required RecurringBill item,
    RecurringBillTxn? txn,
    required DateTime currentSelectedDate,
    required String currentDateFilterType,
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
                  selectedDate: state.selectedDate,
                  currentDateFilterType: state.dateFilterType.name,
                  item: item,
                  txn: txn);
            }
            return _checkboxItem(
              context,
              selectedDate: currentSelectedDate,
              currentDateFilterType: currentDateFilterType,
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
    required String currentDateFilterType,
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
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return CustomActionDialog(
                    title: "Delete Recurring Bill",
                    description:
                        "Are you sure you want to delete this recurring bill?",
                    actions: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (item.archived == null || item.archived == false)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 14.0),
                                child: SizedBox(
                                  height: 44.0,
                                  child: OutlinedButton(
                                    onPressed: () {
                                      //to remove the first dialog
                                      Navigator.pop(context);
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return DeleteDialog(
                                            title: "Delete",
                                            description:
                                                "This will only delete the selected and future schedule of this bill. Are you sure you want to delete this bill?",
                                            onPositive: () {
                                              context
                                                  .read<RecurringModifyBloc>()
                                                  .add(ArchiveRecurringBill(
                                                    selectedDate: selectedDate,
                                                    recurringBill: item,
                                                  ));
                                            },
                                            onNegative: () {
                                              Navigator.pop(context);
                                            },
                                          );
                                        },
                                      );
                                    },
                                    child: Text(
                                      "for ${getMonthText(dateFilterTypeFromString(currentDateFilterType), selectedDate)} and following months",
                                      style: TextStyle(
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      side: BorderSide(
                                        width: 1.0,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                      elevation: 0,
                                    ),
                                  ),
                                ),
                              ),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 14.0),
                              child: SizedBox(
                                height: 44.0,
                                child: OutlinedButton(
                                  onPressed: () {
                                    //to remove the first dialog
                                    Navigator.pop(context);
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return DeleteDialog(
                                          title: "Delete All",
                                          description:
                                              "This will also delete previous transactions made under this bill. Are you sure you want to delete this bill?",
                                          onPositive: () {
                                            context
                                                .read<RecurringModifyBloc>()
                                                .add(RemoveRecurringBill(
                                                  selectedDate: selectedDate,
                                                  recurringBill: item,
                                                ));
                                          },
                                          onNegative: () {
                                            Navigator.pop(context);
                                          },
                                        );
                                      },
                                    );
                                  },
                                  child: Text(
                                    "Delete all",
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    side: BorderSide(
                                      width: 1.0,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                    elevation: 0,
                                  ),
                                ),
                              ),
                            ),
                            CustomButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                "Cancel",
                                style: TextStyle(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  );
                },
              );
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
        child: Container(
          height: 70,
          child: Row(
            children: [
              Checkbox(
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
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return RecurringConfirmationDialog();
                      },
                    ).then((datePaid) {
                      if (datePaid != null) {
                        final newRecurringTxn = RecurringBillTxn(
                          isPaid: true,
                          datePaid: removeTimeFromDate(datePaid),
                        );
                        context.read<RecurringModifyBloc>().add(
                              AddRecurringBillTxn(
                                selectedDate: selectedDate,
                                recurringBill: item,
                                recurringBillTxn: newRecurringTxn,
                              ),
                            );
                      }
                    });
                  }
                },
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Text(item.title ?? "hello"),
                                if (item.archived == true)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 4.0),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 4.0,
                                        vertical: 2.0,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                          4.0,
                                        ),
                                        color: secondaryColor,
                                      ),
                                      child: Text(
                                        "Archived",
                                        style: TextStyle(
                                          fontSize: 10.0,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onInverseSurface,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            if (item.isPaid(selectedDate) && txn != null)
                              Text(
                                "paid ${formatDate(txn.datePaid!, "MMM dd, yyyy")}",
                                style: TextStyle(
                                  fontSize: 12.0,
                                ),
                              )
                            else if (item.reminderDate != null &&
                                item.interval ==
                                    RecurringBillInterval.weekly.name)
                              Text(
                                "every ${formatDate(item.reminderDate!, "EEEE")}",
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
                        decimalFormatterWithSymbol(item.amount ?? 0.00),
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
      ),
    );
  }
}

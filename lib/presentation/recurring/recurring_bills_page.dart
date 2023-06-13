import 'package:budgetup_app/domain/recurring_bill.dart';
import 'package:budgetup_app/helper/colors.dart';
import 'package:budgetup_app/helper/route_strings.dart';
import 'package:budgetup_app/helper/string.dart';
import 'package:budgetup_app/presentation/custom/balance.dart';
import 'package:budgetup_app/presentation/recurring/bloc/recurring_bill_bloc.dart';
import 'package:budgetup_app/presentation/recurring_date_filter/recurring_date_bottom_sheet.dart';
import 'package:budgetup_app/presentation/recurring_modify/bloc/recurring_modify_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:collection/collection.dart';
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
                            getMonthText(enumFromString(currentDateFilterType),
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
                  return Text("Empty categories");
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
                child: BlocBuilder<RecurringBillBloc, RecurringBillState>(
                  builder: (context, state) {
                    if (state is RecurringBillsLoaded) {
                      if (state.recurringBills.isNotEmpty) {
                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: state.recurringBills.length,
                          itemBuilder: (context, index) {
                            final item = state.recurringBills[index];
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
                            );
                          },
                        );
                      } else {
                        return Center(
                          child: Text("Empty Recurring Bills"),
                        );
                      }
                    }
                    return Text("Empty Recurring Bills");
                  },
                ),
              ),
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
        child: Material(
          shape: ContinuousRectangleBorder(
            borderRadius: BorderRadius.circular(30.0),
          ),
          color: Theme.of(context).cardColor,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 16.0,
              horizontal: 21.0,
            ),
            child:
                BlocBuilder<RecurringDateFilterBloc, RecurringDateFilterState>(
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
    return Row(
      children: [
        SizedBox(
          height: 20,
          width: 20,
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
                  isPaid: checked ?? false,
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
        SizedBox(
          width: 10.0,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(item.title ?? "hello"),
              if (item.isPaid(selectedDate) && txn != null)
                Text("paid ${formatDate(txn.datePaid!, "MMM dd, yyyy")}")
              else if (item.reminderDate != null)
                Text("due ${formatDate(item.reminderDate!, "MMM dd")}")
            ],
          ),
        ),
        Text(
          "USD ${decimalFormatter(item.amount ?? 0.00)}",
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

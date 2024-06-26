import 'package:budgetup_app/domain/expense_category.dart';
import 'package:budgetup_app/helper/colors.dart';
import 'package:budgetup_app/helper/route_strings.dart';
import 'package:budgetup_app/helper/string.dart';
import 'package:budgetup_app/presentation/expense_date_filter/bloc/date_filter_bloc.dart';
import 'package:budgetup_app/presentation/expenses_modify/bloc/expenses_modify_bloc.dart';
import 'package:budgetup_app/presentation/transactions_modify/add_expense_txn_page.dart';
import 'package:emoji_data/emoji_data.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:home_widget/home_widget.dart';
import 'package:iconsax/iconsax.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../helper/constant.dart';
import '../../helper/date_helper.dart';
import '../../helper/shared_prefs.dart';
import '../../injection_container.dart';
import '../custom/balance.dart';
import '../custom/custom_floating_button.dart';
import '../custom/delete_dialog.dart';
import '../paywall/paywall.dart';
import 'bloc/expense_bloc.dart';

class ExpensesPage extends HookWidget {
  ExpensesPage({Key? key}) : super(key: key);

  final types = [
    DateSelection(
      "Daily",
      DateFilterType.daily,
    ),
    DateSelection(
      "Weekly",
      DateFilterType.weekly,
    ),
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
      return HomeWidget.updateWidget(
          name: 'UpcomingBillsWidgetProvider', iOSName: 'BudgetUpWidget');
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

    final currentSelectedDate = DateTime.parse(sharedPrefs.getSelectedDate());
    final currentDateFilterType = sharedPrefs.getSelectedDateFilterType();

    final editMode = useState(false);

    //Validate if subscribed
    final isSubscribed = useState(false);

    useEffect(() {
      context
          .read<ExpenseBloc>()
          .add(LoadExpenseCategories(selectedDate: currentSelectedDate));

      Purchases.addCustomerInfoUpdateListener((customerInfo) {
        final entitlement = customerInfo.entitlements.active[entitlementId];
        isSubscribed.value =
            entitlement != null && entitlement.isSandbox == false;
        _setWidget();
        _updateWidget();
      });
      return null;
    }, []);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (editMode.value) {
          editMode.value = false;
        }
      },
      child: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: BlocBuilder<ExpenseBloc, ExpenseState>(
                        builder: (context, state) {
                          if (state is ExpenseCategoryLoaded) {
                            return Balance(
                              headerLabel: Tooltip(
                                message:
                                    'Sum of all the categories for ${getMonthText(dateFilterTypeFromString(currentDateFilterType), currentSelectedDate)}',
                                textAlign: TextAlign.center,
                                triggerMode: TooltipTriggerMode.tap,
                                child: const Row(
                                  children: [
                                    Text("Total Spent"),
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
                              total: state.total,
                              budget: state.totalBudget,
                            );
                          }
                          return Balance(
                            headerLabel: Text("Total Spent"),
                            total: 0.00,
                            budget: 0.00,
                          );
                        },
                      ),
                    ),
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(vertical: 8.0),
                    //   child: GestureDetector(
                    //     behavior: HitTestBehavior.translucent,
                    //     onTap: () {
                    //       showModalBottomSheet(
                    //         isScrollControlled: true,
                    //         backgroundColor: Colors.transparent,
                    //         context: context,
                    //         builder: (context) {
                    //           return StatefulBuilder(
                    //               builder: (context, setState) {
                    //             return DateFilterBottomSheet(
                    //               types: types,
                    //               onSelectFilterType: (type) {
                    //                 selectedFilterType.value = type;
                    //                 context.read<ExpenseDateFilterBloc>().add(
                    //                     ExpenseSelectDate(
                    //                         type, selectedDate.value));
                    //                 context.read<ExpenseBloc>().add(
                    //                       LoadExpenseCategories(
                    //                         dateFilterType: type,
                    //                         selectedDate: selectedDate.value,
                    //                       ),
                    //                     );
                    //                 setState(() {});
                    //               },
                    //               onSelectDate: (date) {
                    //                 selectedDate.value = date;
                    //                 context.read<ExpenseDateFilterBloc>().add(
                    //                     ExpenseSelectDate(
                    //                         selectedFilterType.value, date));
                    //                 context.read<ExpenseBloc>().add(
                    //                       LoadExpenseCategories(
                    //                         dateFilterType:
                    //                             selectedFilterType.value,
                    //                         selectedDate: date,
                    //                       ),
                    //                     );
                    //                 setState(() {});
                    //               },
                    //               onSelectYear: (year) {
                    //                 context
                    //                     .read<ExpenseDateFilterBloc>()
                    //                     .add(ExpenseSelectDate(
                    //                         selectedFilterType.value,
                    //                         DateTime(
                    //                           year,
                    //                           selectedDate.value.month,
                    //                           selectedDate.value.day,
                    //                         )));
                    //                 context.read<ExpenseBloc>().add(
                    //                       LoadExpenseCategories(
                    //                         dateFilterType:
                    //                             selectedFilterType.value,
                    //                         selectedDate: DateTime(
                    //                           year,
                    //                           selectedDate.value.month,
                    //                           selectedDate.value.day,
                    //                         ),
                    //                       ),
                    //                     );
                    //               },
                    //               selectedFilterType: selectedFilterType,
                    //               selectedDate: selectedDate,
                    //             );
                    //           });
                    //
                    //           //return ExpenseDateBottomSheet();
                    //         },
                    //       );
                    //     },
                    //     child: Row(
                    //       mainAxisAlignment: MainAxisAlignment.center,
                    //       children: [
                    //         BlocBuilder<ExpenseDateFilterBloc,
                    //             ExpenseDateFilterState>(
                    //           builder: (context, state) {
                    //             if (state is ExpenseDateFilterSelected) {
                    //               return DateFilterButton(
                    //                 text: getMonthText(state.dateFilterType,
                    //                     state.selectedDate),
                    //               );
                    //             }
                    //             return DateFilterButton(
                    //               text: getMonthText(
                    //                   dateFilterTypeFromString(
                    //                       currentDateFilterType),
                    //                   currentSelectedDate),
                    //             );
                    //           },
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
                BlocBuilder<ExpenseBloc, ExpenseState>(
                  builder: (context, state) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (state is ExpenseCategoryLoaded &&
                              state.expenseCategories.isNotEmpty)
                            GestureDetector(
                              onTap: () async {
                                Navigator.pushNamed(
                                    context, RouteStrings.allTxns);
                              },
                              behavior: HitTestBehavior.translucent,
                              child: const Row(
                                children: [
                                  Icon(
                                    Iconsax.document_text,
                                    size: 18.0,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    "All Transactions",
                                  ),
                                ],
                              ),
                            ),
                          GestureDetector(
                            onTap: () async {
                              final customerInfo =
                                  await Purchases.getCustomerInfo();
                              final hasData = customerInfo
                                          .entitlements.active[entitlementId] !=
                                      null &&
                                  customerInfo.entitlements
                                          .active[entitlementId]!.isSandbox ==
                                      false;

                              if (context.mounted) {
                                if (hasData ||
                                    (state is ExpenseCategoryLoaded &&
                                        state.expenseCategories.length < 5)) {
                                  isSubscribed.value = true;
                                  Navigator.pushNamed(
                                      context, RouteStrings.addCategory);
                                } else {
                                  showPaywall(context);
                                }
                              }
                            },
                            behavior: HitTestBehavior.translucent,
                            child: const Row(
                              children: [
                                Icon(
                                  Iconsax.add,
                                  size: 20.0,
                                ),
                                Text(
                                  "Add Category",
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                BlocListener<ModifyExpensesBloc, ModifyExpensesState>(
                  listener: (context, state) {
                    if (state is ExpenseEdited) {
                      Navigator.pop(context);
                    } else if (state is ExpenseAdded) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Category added")));
                      Navigator.popUntil(context, (route) => route.isFirst);
                    } else if (state is ExpenseRemoved) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Category removed")));
                      Navigator.popUntil(context, (route) => route.isFirst);
                    }
                  },
                  child: BlocBuilder<ExpenseBloc, ExpenseState>(
                    builder: (context, state) {
                      if (state is ExpenseCategoryLoaded &&
                          state.expenseCategories.isNotEmpty) {
                        return GridView.builder(
                          padding: EdgeInsets.only(bottom: 100.0),
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: state.expenseCategories.length,
                          itemBuilder: (context, index) {
                            final item = state.expenseCategories[index];
                            return _categoryItem(
                              context,
                              item: item,
                              editMode: editMode.value,
                              onLongPress: () {
                                HapticFeedback.selectionClick();
                                editMode.value = !editMode.value;
                              },
                            );
                          },
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisSpacing: 15.0,
                            crossAxisSpacing: 15.0,
                          ),
                        );
                      }
                      return Container(
                        height: 500,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "No categories yet",
                              textAlign: TextAlign.center,
                            ),
                            TextButton(
                              onPressed: () async {
                                final customerInfo =
                                    await Purchases.getCustomerInfo();
                                final hasData = customerInfo.entitlements
                                            .active[entitlementId] !=
                                        null &&
                                    customerInfo.entitlements
                                            .active[entitlementId]!.isSandbox ==
                                        false;

                                if (context.mounted) {
                                  if (hasData ||
                                      (state is ExpenseCategoryLoaded &&
                                          state.expenseCategories.length < 5)) {
                                    isSubscribed.value = true;
                                    Navigator.pushNamed(
                                        context, RouteStrings.addCategory);
                                  } else {
                                    showPaywall(context);
                                  }
                                }
                              },
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Iconsax.add),
                                  Text("Add your first category"),
                                ],
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: BlocBuilder<ExpenseBloc, ExpenseState>(
          builder: (context, state) {
            if (state is ExpenseCategoryLoaded &&
                state.expenseCategories.isNotEmpty) {
              return CustomFloatingButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    RouteStrings.addTransaction,
                    arguments: ExpenseTxnArgs(
                      expenseCategory: null,
                    ),
                  );
                },
              );
            }
            return Container();
          },
        ),
      ),
    );
  }

  Widget _categoryItem(
    BuildContext context, {
    required ExpenseCategory item,
    required bool editMode,
    required Function() onLongPress,
  }) {
    final sharedPrefs = getIt<SharedPrefs>();
    final currentSelectedDate = DateTime.parse(sharedPrefs.getSelectedDate());
    final currentDateFilterType = sharedPrefs.getSelectedDateFilterType();

    return Stack(
      children: [
        Material(
          shape: SmoothRectangleBorder(
            borderRadius: SmoothBorderRadius(
              cornerRadius: 24,
              cornerSmoothing: 1.0,
            ),
          ),
          color: Theme.of(context).cardColor,
          child: GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                context,
                RouteStrings.transactions,
                arguments: item,
              );
            },
            onLongPress: onLongPress,
            behavior: HitTestBehavior.translucent,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 8.0,
                horizontal: 16.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(
                        item.icon ?? Emoji.objects[49],
                        style: const TextStyle(
                          fontSize: 20.0,
                        ),
                      ),
                      Text(
                        item.title ?? "Category",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      BlocBuilder<ExpenseDateFilterBloc,
                          ExpenseDateFilterState>(
                        builder: (context, state) {
                          if (state is ExpenseDateFilterSelected) {
                            return Text(
                              decimalFormatterWithSymbol(
                                number: item.getTotalByDate(
                                    state.dateFilterType, state.selectedDate),
                              ),
                              style: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.w600,
                              ),
                            );
                          }
                          return Text(
                            decimalFormatterWithSymbol(
                                number: item.getTotalByDate(
                                    dateFilterTypeFromString(
                                        currentDateFilterType),
                                    currentSelectedDate)),
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.w600,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        "Monthly Budget",
                        style: TextStyle(
                          fontSize: 12.0,
                        ),
                      ),
                      Text(
                        decimalFormatterWithSymbol(number: item.budget ?? 0.00),
                        style: TextStyle(
                          fontSize: 12.0,
                        ),
                      ),
                    ],
                  ),
                  BlocBuilder<ExpenseDateFilterBloc, ExpenseDateFilterState>(
                    builder: (context, state) {
                      if (state is ExpenseDateFilterSelected) {
                        final percentage = item.getTotalPercentage(
                            state.dateFilterType, state.selectedDate);
                        return _budgetProgress(
                          value: percentage.isNaN ? 0.0 : percentage,
                          isExceeded: item.isExceeded(
                              state.dateFilterType, state.selectedDate),
                          isHalf: item.isMoreThanEighty(
                              state.dateFilterType, state.selectedDate),
                        );
                      }
                      final percentage = item.getTotalPercentage(
                          dateFilterTypeFromString(currentDateFilterType),
                          currentSelectedDate);
                      return _budgetProgress(
                          value: percentage.isNaN ? 0.0 : percentage,
                          isHalf: item.isMoreThanEighty(
                              dateFilterTypeFromString(currentDateFilterType),
                              currentSelectedDate),
                          isExceeded: item.isExceeded(
                              dateFilterTypeFromString(currentDateFilterType),
                              currentSelectedDate));
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        if (editMode)
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return DeleteDialog(
                      title: "Delete Category",
                      description:
                          "This will also delete transactions under this category. Are you sure you want to delete this category?",
                      onPositive: () {
                        context
                            .read<ModifyExpensesBloc>()
                            .add(RemoveExpenseCategory(expenseCategory: item));
                      },
                      onNegative: () {
                        Navigator.pop(context);
                      },
                    );
                  },
                );
              },
              icon: Icon(Iconsax.close_circle),
            ),
          ),
      ],
    );
  }

  Widget _budgetProgress({
    required double value,
    required bool isExceeded,
    required bool isHalf,
  }) {
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: 12,
              child: LinearProgressIndicator(
                value: value,
                color: isExceeded
                    ? red
                    : isHalf
                        ? secondaryColor
                        : green,
              ),
            ),
          ),
        ),
        if (isExceeded)
          Padding(
            padding: const EdgeInsets.only(left: 5.0),
            child: SvgPicture.asset(
              "assets/icons/ic_warning.svg",
              color: red,
              height: 16.0,
            ),
          ),
      ],
    );
  }
}

import 'package:budgetup_app/domain/expense_category.dart';
import 'package:budgetup_app/helper/colors.dart';
import 'package:budgetup_app/helper/route_strings.dart';
import 'package:budgetup_app/helper/string.dart';
import 'package:budgetup_app/presentation/custom/date_filter_bottom_sheet.dart';
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
import 'package:workmanager/workmanager.dart';

import '../../helper/constant.dart';
import '../../helper/date_helper.dart';
import '../../helper/shared_prefs.dart';
import '../../injection_container.dart';
import '../custom/balance.dart';
import '../custom/date_filter_button.dart';
import '../paywall/paywall.dart';
import 'bloc/expense_bloc.dart';

@pragma("vm:entry-point")
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) {
    return Future.wait<bool?>([
      HomeWidget.saveWidgetData(
        'total',
        '\$100.50',
      ),
      HomeWidget.updateWidget(
        name: 'HomeWidgetExampleProvider',
        iOSName: 'BudgetUpWidgetExtension',
      ),
    ]).then((value) {
      return !value.contains(false);
    });
  });
}

@pragma("vm:entry-point")
Future<void> backgroundCallback(Uri? uri) async {
  print("URI: $uri");

  final customerInfo = await Purchases.getCustomerInfo();
  final isSubscribed = customerInfo.entitlements.active[entitlementId] != null;
  HomeWidget.saveWidgetData<String>('total', "\$100.50");
  HomeWidget.saveWidgetData<bool>('isSubscribed', isSubscribed);
  await HomeWidget.updateWidget(
      //this must the class name used in .Kt
      name: 'HomeWidgetExampleProvider',
      iOSName: 'BudgetUpWidgetExtension');
}

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

  void _checkForWidgetLaunch() {
    HomeWidget.initiallyLaunchedFromHomeWidget()
        .then((uri) => _launchedFromWidget);
  }

  void _launchedFromWidget(Uri? uri) {
    if (uri != null) {
      print("URI: $uri");
    }
  }

  Future _loadData(
    Function(String) dateCallback,
    Function(bool) isSubscribed,
  ) async {
    try {
      return Future.wait([
        HomeWidget.getWidgetData<String>('filter', defaultValue: "")
            .then((value) => print(value)),
        HomeWidget.getWidgetData<String>('total', defaultValue: 'Default Title')
            .then((value) => dateCallback(value ?? "")),
        HomeWidget.getWidgetData<bool>('isSubscribed', defaultValue: false)
            .then((value) => isSubscribed(value ?? false)),
      ]);
    } on PlatformException catch (exception) {
      debugPrint('Error Getting Data. $exception');
    }
  }

  Future _sendDataFilter({
    required String filter,
  }) async {
    try {
      return Future.wait([
        HomeWidget.saveWidgetData<String>('filter', filter),
      ]);
    } on PlatformException catch (exception) {
      debugPrint('Error Sending Data. $exception');
    }
  }

  Future _sendData({
    required String total,
  }) async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      final isSubscribed =
          customerInfo.entitlements.active[entitlementId] != null;
      print("SEND!");
      return Future.wait([
        HomeWidget.saveWidgetData<String>('total', total),
        HomeWidget.saveWidgetData<bool>('isSubscribed', isSubscribed),
      ]);
    } on PlatformException catch (exception) {
      debugPrint('Error Sending Data. $exception');
    }
  }

  Future _updateWidget() async {
    try {
      return HomeWidget.updateWidget(
          name: 'HomeWidgetExampleProvider',
          iOSName: 'BudgetUpWidgetExtension');
    } on PlatformException catch (exception) {
      debugPrint('Error Updating Widget. $exception');
    }
  }

  Future<void> _sendAndUpdate({
    required String total,
  }) async {
    await _sendData(total: total);
    await _updateWidget();
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
        dateFilterTypeFromString(sharedPrefs.getSelectedDateFilterType()));
    final selectedDate = useState<DateTime>(
      sharedPrefs.getExpenseSelectedDate().isNotEmpty
          ? DateTime.parse(sharedPrefs.getExpenseSelectedDate())
          : DateTime.now(),
    );
    final currentSelectedDate =
        DateTime.parse(sharedPrefs.getExpenseSelectedDate());
    final currentDateFilterType = sharedPrefs.getSelectedDateFilterType();

    //Validate if subscribed
    final isSubscribed = useState(false);

    useEffect(() {
      Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
      HomeWidget.setAppGroupId('group.G53UVF44L3.com.ralphordanza.budgetupapp');
      HomeWidget.registerBackgroundCallback(backgroundCallback);
      _loadData((p0) {
        print("DATE: $p0");
      }, (p1) {
        print("IS SUBSCRIBED: $p1");
      });
      //_sendAndUpdate();

      context
          .read<ExpenseBloc>()
          .add(LoadExpenseCategories(selectedDate: currentSelectedDate));

      Purchases.addCustomerInfoUpdateListener((customerInfo) {
        final entitlement = customerInfo.entitlements.active[entitlementId];
        isSubscribed.value = entitlement != null;
        //_sendAndUpdate();
      });
      return null;
    }, []);

    useEffect(() {
      _checkForWidgetLaunch();
      HomeWidget.widgetClicked.listen(_launchedFromWidget);
      return () {};
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
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    showModalBottomSheet(
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      context: context,
                      builder: (context) {
                        return StatefulBuilder(builder: (context, setState) {
                          return DateFilterBottomSheet(
                            types: types,
                            onSelectFilterType: (type) {
                              selectedFilterType.value = type;
                              context.read<ExpenseDateFilterBloc>().add(
                                  ExpenseSelectDate(type, selectedDate.value));
                              context.read<ExpenseBloc>().add(
                                    LoadExpenseCategories(
                                      dateFilterType: type,
                                      selectedDate: selectedDate.value,
                                    ),
                                  );
                              setState(() {});
                            },
                            onSelectDate: (date) {
                              selectedDate.value = date;
                              context.read<ExpenseDateFilterBloc>().add(
                                  ExpenseSelectDate(
                                      selectedFilterType.value, date));
                              context.read<ExpenseBloc>().add(
                                    LoadExpenseCategories(
                                      dateFilterType: selectedFilterType.value,
                                      selectedDate: date,
                                    ),
                                  );
                              setState(() {});
                            },
                            onSelectYear: (year) {
                              context
                                  .read<ExpenseDateFilterBloc>()
                                  .add(ExpenseSelectDate(
                                      selectedFilterType.value,
                                      DateTime(
                                        year,
                                        selectedDate.value.month,
                                        selectedDate.value.day,
                                      )));
                              context.read<ExpenseBloc>().add(
                                    LoadExpenseCategories(
                                      dateFilterType: selectedFilterType.value,
                                      selectedDate: DateTime(
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

                        //return ExpenseDateBottomSheet();
                      },
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      BlocBuilder<ExpenseDateFilterBloc,
                          ExpenseDateFilterState>(
                        builder: (context, state) {
                          if (state is ExpenseDateFilterSelected) {
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
              BlocBuilder<ExpenseBloc, ExpenseState>(
                builder: (context, state) {
                  if (state is ExpenseCategoryLoaded) {
                    _sendAndUpdate(
                        total: decimalFormatterWithSymbol(state.total));
                    return Balance(
                      headerLabel: Tooltip(
                        message:
                            'Sum of all the categories for ${getMonthText(dateFilterTypeFromString(currentDateFilterType), currentSelectedDate)}',
                        textAlign: TextAlign.center,
                        triggerMode: TooltipTriggerMode.tap,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
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
                        showDuration: Duration(seconds: 3),
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
              Divider(),
              BlocBuilder<ExpenseBloc, ExpenseState>(
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
                                null;

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
                          child: Row(
                            children: [
                              Icon(
                                Iconsax.add,
                                size: 20.0,
                              ),
                              Text("Add Category"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              Expanded(
                  child: BlocListener<ModifyExpensesBloc, ModifyExpensesState>(
                listener: (context, state) {
                  if (state is ExpenseEdited) {
                    Navigator.pop(context);
                  } else if (state is ExpenseAdded || state is ExpenseRemoved) {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  }
                },
                child: BlocBuilder<ExpenseBloc, ExpenseState>(
                  builder: (context, state) {
                    if (state is ExpenseCategoryLoaded &&
                        state.expenseCategories.isNotEmpty) {
                      return GridView.builder(
                        shrinkWrap: true,
                        itemCount: state.expenseCategories.length,
                        itemBuilder: (context, index) {
                          final item = state.expenseCategories[index];
                          return _categoryItem(context, item);
                        },
                        padding: EdgeInsets.only(bottom: 16.0),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 15.0,
                          crossAxisSpacing: 15.0,
                        ),
                      );
                    }
                    return Center(
                      child: SingleChildScrollView(
                        child: Text(
                          "No categories yet\nTap + to add",
                          textAlign: TextAlign.center,
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
      // floatingActionButton: CustomFloatingButton(
      //   onPressed: () {
      //     Navigator.pushNamed(
      //       context,
      //       RouteStrings.addTransaction,
      //     );
      //   },
      // ),
    );
  }

  Widget _categoryItem(
    BuildContext context,
    ExpenseCategory item,
  ) {
    final sharedPrefs = getIt<SharedPrefs>();
    final currentSelectedDate =
        DateTime.parse(sharedPrefs.getExpenseSelectedDate());
    final currentDateFilterType = sharedPrefs.getSelectedDateFilterType();

    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(
              context,
              RouteStrings.addTransaction,
              arguments: ExpenseTxnArgs(
                expenseCategory: item,
                from: From.expensePage,
              ),
            );
          },
          child: Material(
            shape: SmoothRectangleBorder(
              borderRadius: SmoothBorderRadius(
                cornerRadius: 24,
                cornerSmoothing: 1.0,
              ),
            ),
            color: Theme.of(context).cardColor,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Column(
                      children: [
                        Text(
                          item.icon ?? Emoji.objects[49],
                          style: TextStyle(
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
                                  item.getTotalByDate(
                                      state.dateFilterType, state.selectedDate),
                                ),
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              );
                            }
                            return Text(
                              decimalFormatterWithSymbol(item.getTotalByDate(
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
                        decimalFormatterWithSymbol(item.budget ?? 0.00),
                        style: TextStyle(
                          fontSize: 12.0,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: BlocBuilder<ExpenseDateFilterBloc,
                            ExpenseDateFilterState>(
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
                                    dateFilterTypeFromString(
                                        currentDateFilterType),
                                    currentSelectedDate),
                                isExceeded: item.isExceeded(
                                    dateFilterTypeFromString(
                                        currentDateFilterType),
                                    currentSelectedDate));
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        // Align(
        //   alignment: Alignment.topRight,
        //   child: IconButton(
        //       onPressed: () {
        //         //TODO show are you sure you want to delete
        //         context
        //             .read<ModifyExpensesBloc>()
        //             .add(RemoveExpenseCategory(expenseCategory: item));
        //       },
        //       icon: Icon(Iconsax.close_circle)),
        // ),
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

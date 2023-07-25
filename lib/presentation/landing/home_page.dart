import 'package:budgetup_app/helper/route_strings.dart';
import 'package:budgetup_app/presentation/recurring/bloc/recurring_bill_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconsax/iconsax.dart';

import '../../helper/colors.dart';
import '../../helper/date_helper.dart';
import '../../helper/shared_prefs.dart';
import '../../injection_container.dart';
import '../custom/date_filter_bottom_sheet.dart';
import '../custom/date_filter_button.dart';
import '../custom/whats_new_dialog.dart';
import '../expense_date_filter/bloc/date_filter_bloc.dart';
import '../expenses/bloc/expense_bloc.dart';
import '../expenses/expenses_page.dart';
import '../recurring/recurring_bills_page.dart';

class HomePage extends HookWidget {
  HomePage({super.key});

  final _pages = [
    ExpensesPage(),
    RecurringBillsPage(),
    //TransactionsPage(),
  ];

  showWhatsNew(BuildContext context) async {
    final sharedPrefs = getIt<SharedPrefs>();
    final hasSeen = sharedPrefs.getSeenWhatsNew() ?? false;
    final isFinishedOnboarding = sharedPrefs.getFinishedOnboarding() ?? false;
    if (!hasSeen && isFinishedOnboarding) {
      //SHOW POPUP
      await showDialog(
          context: context,
          builder: (context) {
            return WhatsNewDialog();
          }).then((seen) {
        if (seen) {
          sharedPrefs.setSeenWhatsNew(true);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final _selectedIndex = useState<int>(0);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showWhatsNew(context);
      });
      return null;
    }, []);

    return Scaffold(
      // appBar: AppBar(
      //   title:
      //   centerTitle: true,
      //   elevation: 0,
      //   backgroundColor: Colors.transparent,
      //   leading: IconButton(
      //     onPressed: () {
      //       Navigator.pushNamed(context, RouteStrings.summary);
      //     },
      //     icon: SvgPicture.asset(
      //       "assets/icons/ic_summary_thin.svg",
      //       height: 24.0,
      //       color: Theme.of(context).colorScheme.onSurface,
      //     ),
      //   ),
      //   actions: [
      //     IconButton(
      //       onPressed: () {
      //         Navigator.pushNamed(context, RouteStrings.settings);
      //       },
      //       icon: SvgPicture.asset(
      //         "assets/icons/ic_setting.svg",
      //         height: 24.0,
      //         color: Theme.of(context).colorScheme.onSurface,
      //       ),
      //     ),
      //   ],
      // ),
      body: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pushNamed(context, RouteStrings.summary);
                  },
                  icon: Icon(
                    Iconsax.menu_board,
                  ),
                ),
                Expanded(child: DateFilter()),
                IconButton(
                  onPressed: () {
                    Navigator.pushNamed(context, RouteStrings.settings);
                  },
                  icon: SvgPicture.asset(
                    "assets/icons/ic_setting.svg",
                    height: 24.0,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                children: [
                  Text("Jul 2023 Salary"),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "P 1,000.00",
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      SizedBox(
                        width: 5.0,
                      ),
                      Icon(
                        Iconsax.edit,
                        size: 14,
                      )
                    ],
                  ),
                ],
              ),
            ),
            Divider(),
            Expanded(
              child: IndexedStack(
                index: _selectedIndex.value,
                children: _pages,
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: secondaryColor,
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Iconsax.money_send,
              color: _selectedIndex.value == 0
                  ? secondaryColor
                  : Theme.of(context).colorScheme.onSurface,
            ),
            label: 'Expenses',
          ),
          BottomNavigationBarItem(
            icon: SvgPicture.asset(
              "assets/icons/ic_recurring.svg",
              color: _selectedIndex.value == 1
                  ? secondaryColor
                  : Theme.of(context).colorScheme.onSurface,
            ),
            label: 'Recurring Bills',
          ),
        ],
        currentIndex: _selectedIndex.value,
        onTap: (index) {
          _selectedIndex.value = index;
        },
      ),
    );
  }
}

class DateFilter extends HookWidget {
  DateFilter({super.key});

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

    return GestureDetector(
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
                  context
                      .read<ExpenseDateFilterBloc>()
                      .add(ExpenseSelectDate(type, selectedDate.value));
                  context.read<ExpenseBloc>().add(
                        LoadExpenseCategories(
                          dateFilterType: type,
                          selectedDate: selectedDate.value,
                        ),
                      );
                  context.read<RecurringBillBloc>().add(LoadRecurringBills());
                  setState(() {});
                },
                onSelectDate: (date) {
                  selectedDate.value = date;
                  context
                      .read<ExpenseDateFilterBloc>()
                      .add(ExpenseSelectDate(selectedFilterType.value, date));
                  context.read<ExpenseBloc>().add(
                        LoadExpenseCategories(
                          dateFilterType: selectedFilterType.value,
                          selectedDate: date,
                        ),
                      );
                  context.read<RecurringBillBloc>().add(LoadRecurringBills());

                  setState(() {});
                },
                onSelectYear: (year) {
                  context.read<ExpenseDateFilterBloc>().add(ExpenseSelectDate(
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
                  context.read<RecurringBillBloc>().add(LoadRecurringBills());
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
          BlocBuilder<ExpenseDateFilterBloc, ExpenseDateFilterState>(
            builder: (context, state) {
              if (state is ExpenseDateFilterSelected) {
                return DateFilterButton(
                  text: getMonthText(state.dateFilterType, state.selectedDate),
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
    );
  }
}

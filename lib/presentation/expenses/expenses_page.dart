import 'package:budgetup_app/domain/expense_category.dart';
import 'package:budgetup_app/helper/route_strings.dart';
import 'package:budgetup_app/helper/string.dart';
import 'package:budgetup_app/presentation/expense_date_filter/bloc/date_filter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconsax/iconsax.dart';

import '../../helper/date_helper.dart';
import '../../helper/shared_prefs.dart';
import '../../injection_container.dart';
import '../custom/balance.dart';
import '../custom/custom_floating_button.dart';
import '../expense_date_filter/date_bottom_sheet.dart';
import '../transactions_modify/add_expense_txn_page.dart';
import 'bloc/expense_bloc.dart';

class ExpensesPage extends HookWidget {
  const ExpensesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sharedPrefs = getIt<SharedPrefs>();
    final currentSelectedDate =
        DateTime.parse(sharedPrefs.getExpenseSelectedDate());
    final currentDateFilterType = sharedPrefs.getSelectedDateFilterType();

    useEffect(() {
      context
          .read<ExpenseBloc>()
          .add(LoadExpenseCategories(selectedDate: currentSelectedDate));
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
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      context: context,
                      builder: (context) {
                        return ExpenseDateBottomSheet();
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
              BlocBuilder<ExpenseBloc, ExpenseState>(
                builder: (context, state) {
                  if (state is ExpenseCategoryLoaded && state.total != null) {
                    return Balance(
                      headerLabel: Text("Total Expenses"),
                      total: state.total,
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
                      Navigator.pushNamed(context, RouteStrings.addCategory);
                    },
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
              SizedBox(
                height: 10.0,
              ),
              Expanded(
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
                    return Center(child: Text("Empty categories"));
                  },
                ),
              ),
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

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          RouteStrings.transactions,
          arguments: item,
        );
      },
      child: Material(
        shape: ContinuousRectangleBorder(
          borderRadius: BorderRadius.circular(40.0),
        ),
        color: Theme.of(context).cardColor,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 8.0,
            horizontal: 24.0,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Icon(
                Iconsax.car,
                size: 30.0,
              ),
              Column(
                children: [
                  Text(
                    item.title ?? "hello",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  BlocBuilder<ExpenseDateFilterBloc, ExpenseDateFilterState>(
                    builder: (context, state) {
                      if (state is ExpenseDateFilterSelected) {
                        return Text(
                          "USD ${decimalFormatter(item.getTotalByDate(state.dateFilterType, state.selectedDate))}",
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w700,
                          ),
                        );
                      }
                      return Text(
                        "USD ${decimalFormatter(item.getTotalByDate(enumFromString(currentDateFilterType), currentSelectedDate))}",
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.w700,
                        ),
                      );
                    },
                  ),
                  SizedBox(
                    height: 10.0,
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
                        "${item.budget}",
                        style: TextStyle(
                          fontSize: 12.0,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  BlocBuilder<ExpenseDateFilterBloc, ExpenseDateFilterState>(
                    builder: (context, state) {
                      if (state is ExpenseDateFilterSelected) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            height: 12,
                            child: LinearProgressIndicator(
                              value: item.getTotalPercentage(
                                  state.dateFilterType, state.selectedDate),
                              color: item.isExceeded(
                                      state.dateFilterType, state.selectedDate)
                                  ? Colors.red
                                  : null,
                            ),
                          ),
                        );
                      }
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          height: 12,
                          child: LinearProgressIndicator(
                            value: item.getTotalPercentage(
                                enumFromString(currentDateFilterType),
                                currentSelectedDate),
                            color: item.isExceeded(
                                    enumFromString(currentDateFilterType),
                                    currentSelectedDate)
                                ? Colors.red
                                : null,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:budgetup_app/domain/expense_category.dart';
import 'package:budgetup_app/helper/route_strings.dart';
import 'package:budgetup_app/presentation/expense_date_filter/bloc/date_filter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../helper/colors.dart';
import '../../helper/date_helper.dart';
import '../../helper/shared_prefs.dart';
import '../../injection_container.dart';
import '../expense_date_filter/date_bottom_sheet.dart';
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
      context.read<ExpenseBloc>().add(LoadExpenseCategories());
    }, []);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextButton(
              onPressed: () {
                showModalBottomSheet(
                  backgroundColor: Colors.transparent,
                  context: context,
                  builder: (context) {
                    return ExpenseDateBottomSheet();
                  },
                );
              },
              child: BlocBuilder<ExpenseDateFilterBloc, ExpenseDateFilterState>(
                builder: (context, state) {
                  if (state is ExpenseDateFilterSelected) {
                    return Text(
                        getMonthText(state.dateFilterType, state.selectedDate));
                  }
                  return Text(getMonthText(
                      enumFromString(currentDateFilterType),
                      currentSelectedDate));
                },
              ),
            ),
            Material(
              shape: ContinuousRectangleBorder(
                borderRadius: BorderRadius.circular(40.0),
              ),
              color: Theme.of(context).cardColor,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Total Expenses"),
                    Text("PHP 1,000.00"),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 4.0,
                      ),
                      decoration: BoxDecoration(
                        color: red.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: Text("PHP 30.00 higher than last month"),
                    )
                  ],
                ),
              ),
            ),
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
              child: BlocBuilder<ExpenseBloc, ExpenseState>(
                builder: (context, state) {
                  if (state is ExpenseCategoryLoaded) {
                    if (state.expenseCategories.isNotEmpty) {
                      return GridView.builder(
                        shrinkWrap: true,
                        itemCount: state.expenseCategories.length,
                        itemBuilder: (context, index) {
                          final item = state.expenseCategories[index];
                          return _categoryItem(context, item);
                        },
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2),
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
      child: Column(
        children: [
          Row(
            children: [
              Flexible(
                child: Column(
                  children: [
                    Text(item.title ?? "hello"),
                    Text("${item.budget}"),
                    BlocBuilder<ExpenseDateFilterBloc, ExpenseDateFilterState>(
                      builder: (context, state) {
                        if (state is ExpenseDateFilterSelected) {
                          return Text(
                              "${item.getTotal(state.dateFilterType, state.selectedDate)}");
                        }
                        return Text(
                            "${item.getTotal(enumFromString(currentDateFilterType), currentSelectedDate)}");
                      },
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  context.read<ExpenseBloc>().add(
                        RemoveExpenseCategory(expenseCategory: item),
                      );
                },
                icon: Icon(Icons.delete),
              ),
              IconButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    RouteStrings.addCategory,
                    arguments: item,
                  );
                },
                icon: Icon(Icons.edit),
              ),
            ],
          ),
          BlocBuilder<ExpenseDateFilterBloc, ExpenseDateFilterState>(
            builder: (context, state) {
              if (state is ExpenseDateFilterSelected) {
                return LinearProgressIndicator(
                  value: item.getTotalPercentage(
                      state.dateFilterType, state.selectedDate),
                );
              }
              return LinearProgressIndicator(
                value: item.getTotalPercentage(
                    enumFromString(currentDateFilterType), currentSelectedDate),
              );
            },
          ),
        ],
      ),
    );
  }
}

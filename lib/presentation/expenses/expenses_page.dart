import 'package:budgetup_app/helper/route_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../helper/shared_prefs.dart';
import '../../injection_container.dart';
import '../custom/custom_floating_button.dart';
import 'bloc/expense_bloc.dart';

class ExpensesPage extends HookWidget {
  const ExpensesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sharedPrefs = getIt<SharedPrefs>();
    final currentSelectedDate = DateTime.parse(sharedPrefs.getSelectedDate());
    useEffect(() {
      context
          .read<ExpenseBloc>()
          .add(LoadExpenseCategories(currentSelectedDate));
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
              child: BlocBuilder<ExpenseBloc, ExpenseState>(
                builder: (context, state) {
                  if (state is ExpenseCategoryLoaded) {
                    if (state.expenseCategories.isNotEmpty) {
                      return GridView.builder(
                        shrinkWrap: true,
                        itemCount: state.expenseCategories.length,
                        itemBuilder: (context, index) {
                          final item = state.expenseCategories[index];
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
                                          Text("${item.getTotal()}"),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        context.read<ExpenseBloc>().add(
                                              RemoveExpenseCategory(
                                                  expenseCategory: item),
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
                                LinearProgressIndicator(
                                  value: item.getTotalPercentage(),
                                )
                              ],
                            ),
                          );
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
      floatingActionButton: CustomFloatingButton(
        onPressed: () {},
      ),
    );
  }
}

import 'package:budgetup_app/helper/route_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/expense_bloc.dart';

class ExpensesPage extends StatelessWidget {
  const ExpensesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: BlocBuilder<ExpenseBloc, ExpenseState>(
                builder: (context, state) {
                  if (state is ExpenseCategoryLoaded) {
                    return ListView.builder(
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
                                    Column(
                                      children: [
                                        Text(item.title ?? "hello"),
                                        Text("${item.getTotal()}"),
                                      ],
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
                                          RouteStrings.addExpense,
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
                            ));
                      },
                    );
                  }
                  return Text("Empty categories");
                },
              ),
            ),
            ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, RouteStrings.addExpense);
                },
                child: Text("ADD"))
          ],
        ),
      ),
    );
  }
}

import 'package:budgetup_app/domain/expense_category.dart';
import 'package:budgetup_app/helper/route_strings.dart';
import 'package:budgetup_app/presentation/transactions/add_expense_txn_page.dart';
import 'package:budgetup_app/presentation/transactions/bloc/expense_txn_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../expenses/bloc/expense_bloc.dart';

class ExpenseTxnPage extends HookWidget {
  final ExpenseCategory expenseCategory;

  const ExpenseTxnPage({required this.expenseCategory, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final modifySuccess = useState<bool>(false);

    useEffect(() {
      context
          .read<ExpenseTxnBloc>()
          .add(LoadExpenseTxns(categoryId: expenseCategory.id!));
    }, []);

    useEffect(() {
      if (modifySuccess.value) {
        context
            .read<ExpenseTxnBloc>()
            .add(LoadExpenseTxns(categoryId: expenseCategory.id!));
        context.read<ExpenseBloc>().add(LoadExpenseCategories());
      }
    }, [modifySuccess.value]);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: BlocBuilder<ExpenseTxnBloc, ExpenseTxnState>(
                builder: (context, state) {
                  if (state is ExpenseTxnLoaded) {
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: state.expenseTxns.length,
                      itemBuilder: (context, index) {
                        final item = state.expenseTxns[index];
                        return Column(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text("${item.updatedAt}"),
                                Text("${item.amount}"),
                              ],
                            ),
                            IconButton(
                              onPressed: () {
                                context.read<ExpenseTxnBloc>().add(
                                      RemoveExpenseTxn(expenseTxn: item),
                                    );
                                modifySuccess.value = true;
                              },
                              icon: Icon(Icons.delete),
                            ),
                            IconButton(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  RouteStrings.addTransaction,
                                  arguments: ExpenseTxnArgs(
                                    expenseCategory: expenseCategory,
                                    expenseTxn: item,
                                  ),
                                );
                              },
                              icon: Icon(Icons.edit),
                            ),
                          ],
                        );
                      },
                    );
                  }
                  return Text("Empty transactions");
                },
              ),
            ),
            ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    RouteStrings.addTransaction,
                    arguments: ExpenseTxnArgs(
                      expenseCategory: expenseCategory,
                    ),
                  );
                },
                child: Text("ADD"))
          ],
        ),
      ),
    );
  }
}

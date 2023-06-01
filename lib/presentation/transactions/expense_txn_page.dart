import 'package:budgetup_app/domain/expense_category.dart';
import 'package:budgetup_app/domain/expense_txn.dart';
import 'package:budgetup_app/presentation/expenses/bloc/expense_bloc.dart';
import 'package:budgetup_app/presentation/transactions/bloc/expense_txn_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ExpenseTxnPage extends StatelessWidget {
  final ExpenseCategory expenseCategory;

  const ExpenseTxnPage({required this.expenseCategory, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                            Text("${item.createdAt}"),
                            Text("${item.amount}"),
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
                  final newTxn = ExpenseTxn(
                    notes: "Grab",
                    amount: 100,
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  );
                  context.read<ExpenseTxnBloc>().add(
                        AddExpenseTxn(
                          expenseCategory: expenseCategory,
                          expenseTxn: newTxn,
                        ),
                      );
                  context.read<ExpenseBloc>().add(LoadExpenseCategories());
                },
                child: Text("ADD"))
          ],
        ),
      ),
    );
  }
}

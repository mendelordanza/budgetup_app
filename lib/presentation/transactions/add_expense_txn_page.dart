import 'package:budgetup_app/domain/expense_category.dart';
import 'package:budgetup_app/domain/expense_txn.dart';
import 'package:budgetup_app/presentation/expenses/bloc/expense_bloc.dart';
import 'package:budgetup_app/presentation/transactions/bloc/expense_txn_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class ExpenseTxnArgs {
  final ExpenseCategory expenseCategory;
  final ExpenseTxn? expenseTxn;

  ExpenseTxnArgs({required this.expenseCategory, this.expenseTxn});
}

class AddExpenseTxnPage extends HookWidget {
  final ExpenseTxnArgs args;

  const AddExpenseTxnPage({required this.args, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final notesTextController = useTextEditingController(
        text: args.expenseTxn != null ? args.expenseTxn!.notes : "");
    final amountTextController = useTextEditingController(
        text: args.expenseTxn != null ? "${args.expenseTxn!.amount}" : "");
    final added = useState<bool>(false);

    useEffect(() {
      if (added.value) {
        context
            .read<ExpenseTxnBloc>()
            .add(LoadExpenseTxns(categoryId: args.expenseCategory.id!));
        context
            .read<ExpenseBloc>()
            .add(LoadExpenseCategories());
      }
    }, [added.value]);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            TextField(
              controller: notesTextController,
            ),
            TextField(
              controller: amountTextController,
            ),
            ElevatedButton(
              onPressed: () {
                if (args.expenseTxn != null) {
                  //Edit
                  final editedTxn = args.expenseTxn!.copy(
                    amount: double.parse(amountTextController.text),
                    notes: notesTextController.text,
                    updatedAt: DateTime.now(),
                  );
                  context
                      .read<ExpenseTxnBloc>()
                      .add(EditExpenseTxn(expenseTxn: editedTxn));
                } else {
                  //Add
                  final newTxn = ExpenseTxn(
                    amount: double.parse(amountTextController.text),
                    notes: notesTextController.text,
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  );
                  context.read<ExpenseTxnBloc>().add(
                        AddExpenseTxn(
                          expenseTxn: newTxn,
                          expenseCategory: args.expenseCategory,
                        ),
                      );
                }
                added.value = true;
              },
              child: Text(
                args.expenseTxn != null ? "Edit" : "Add",
              ),
            ),
          ],
        ),
      ),
    );
  }
}

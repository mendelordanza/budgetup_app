import 'package:budgetup_app/domain/expense_category.dart';
import 'package:budgetup_app/domain/expense_txn.dart';
import 'package:budgetup_app/helper/date_helper.dart';
import 'package:budgetup_app/presentation/transactions_modify/bloc/transactions_modify_bloc.dart';
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
  final _formKey = GlobalKey<FormState>();

  AddExpenseTxnPage({required this.args, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final notesTextController = useTextEditingController(
        text: args.expenseTxn != null ? args.expenseTxn!.notes : "");
    final amountTextController = useTextEditingController(
        text: args.expenseTxn != null ? "${args.expenseTxn!.amount}" : "");

    final dateTextController = useTextEditingController();
    final currentSelectedDate = useState<DateTime>(
        args.expenseTxn != null && args.expenseTxn!.updatedAt != null
            ? args.expenseTxn!.updatedAt!
            : DateTime.now());
    final added = useState<bool>(false);

    useEffect(() {
      if (added.value) {
        // context
        //     .read<ExpenseTxnBloc>()
        //     .add(LoadExpenseTxns(categoryId: args.expenseCategory.id!));
        //context.read<ExpenseBloc>().add(LoadExpenseCategories());
        //context.read<DashboardCubit>().getSummary();
      }
    }, [added.value]);

    useEffect(() {
      dateTextController.text =
          formatDate(currentSelectedDate.value, "MMM dd, yyyy");
    }, [currentSelectedDate.value]);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: notesTextController,
                  ),
                  TextFormField(
                    controller: amountTextController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: dateTextController,
                    onTap: () async {
                      await showDatePicker(
                        context: context,
                        initialDate: currentSelectedDate.value,
                        firstDate: DateTime(2015, 8),
                        lastDate: DateTime(2101),
                      ).then((date) {
                        if (date != null) {
                          currentSelectedDate.value = date;
                        }
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  if (args.expenseTxn != null) {
                    //Edit
                    final editedTxn = args.expenseTxn!.copy(
                      amount: double.parse(amountTextController.text),
                      notes: notesTextController.text,
                      updatedAt: removeTimeFromDate(currentSelectedDate.value),
                    );
                    context.read<TransactionsModifyBloc>().add(EditExpenseTxn(
                        expenseCategory: args.expenseCategory,
                        expenseTxn: editedTxn));
                  } else {
                    //Add
                    final newTxn = ExpenseTxn(
                      amount: double.parse(amountTextController.text),
                      notes: notesTextController.text,
                      createdAt: removeTimeFromDate(currentSelectedDate.value),
                      updatedAt: removeTimeFromDate(currentSelectedDate.value),
                    );
                    context.read<TransactionsModifyBloc>().add(
                          AddExpenseTxn(
                            expenseTxn: newTxn,
                            expenseCategory: args.expenseCategory,
                          ),
                        );
                  }
                  added.value = true;
                }
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

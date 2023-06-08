import 'package:budgetup_app/helper/date_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../domain/expense_category.dart';
import 'bloc/expense_bloc.dart';

class AddExpenseCategoryPage extends HookWidget {
  final ExpenseCategory? expenseCategory;
  final _formKey = GlobalKey<FormState>();

  AddExpenseCategoryPage({this.expenseCategory, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final titleTextController = useTextEditingController(
        text: expenseCategory != null ? expenseCategory!.title : "");
    final budgetTextController = useTextEditingController(
        text: expenseCategory != null ? "${expenseCategory!.budget}" : "");

    final added = useState<bool>(false);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (added.value) {
          Navigator.pop(context);
        }
      });
    }, [added.value]);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: titleTextController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: budgetTextController,
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
                  if (expenseCategory != null) {
                    //Edit
                    final editedCategory = expenseCategory!.copy(
                      title: titleTextController.text,
                      budget: double.parse(budgetTextController.text),
                      updatedAt: removeTimeFromDate(DateTime.now()),
                    );
                    context.read<ExpenseBloc>().add(
                        EditExpenseCategory(expenseCategory: editedCategory));
                  } else {
                    //Add
                    final newCategory = ExpenseCategory(
                      title: titleTextController.text,
                      budget: double.parse(budgetTextController.text),
                      createdAt: removeTimeFromDate(DateTime.now()),
                      updatedAt: removeTimeFromDate(DateTime.now()),
                    );
                    context
                        .read<ExpenseBloc>()
                        .add(AddExpenseCategory(expenseCategory: newCategory));
                  }
                  context.read<ExpenseBloc>().add(LoadExpenseCategories());

                  //Pop page
                  added.value = true;
                }
              },
              child: Text(
                expenseCategory != null ? "Edit" : "Add",
              ),
            ),
          ],
        ),
      ),
    );
  }
}

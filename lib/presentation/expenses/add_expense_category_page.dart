import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../domain/expense_category.dart';
import '../../helper/shared_prefs.dart';
import '../../injection_container.dart';
import 'bloc/expense_bloc.dart';

class AddExpenseCategoryPage extends HookWidget {
  final ExpenseCategory? expenseCategory;

  AddExpenseCategoryPage({this.expenseCategory, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sharedPrefs = getIt<SharedPrefs>();
    final currentSelectedDate = DateTime.parse(sharedPrefs.getSelectedDate());
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
            TextField(
              controller: titleTextController,
            ),
            TextField(
              controller: budgetTextController,
            ),
            ElevatedButton(
              onPressed: () {
                if (expenseCategory != null) {
                  //Edit
                  final editedCategory = expenseCategory!.copy(
                    title: titleTextController.text,
                    budget: double.parse(budgetTextController.text),
                    updatedAt: DateTime.now(),
                  );
                  context.read<ExpenseBloc>().add(
                      EditExpenseCategory(expenseCategory: editedCategory));
                } else {
                  //Add
                  final newCategory = ExpenseCategory(
                    title: titleTextController.text,
                    budget: double.parse(budgetTextController.text),
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  );
                  context
                      .read<ExpenseBloc>()
                      .add(AddExpenseCategory(expenseCategory: newCategory));
                }
                context
                    .read<ExpenseBloc>()
                    .add(LoadExpenseCategories(currentSelectedDate));

                //Pop page
                added.value = true;
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

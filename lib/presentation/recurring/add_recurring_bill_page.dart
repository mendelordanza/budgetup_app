import 'package:budgetup_app/domain/recurring_bill.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'bloc/recurring_bill_bloc.dart';

class AddRecurringBillPage extends HookWidget {
  final RecurringBill? recurringBill;

  AddRecurringBillPage({this.recurringBill, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final titleTextController = useTextEditingController(
        text: recurringBill != null ? recurringBill!.title : "");
    final amountTextController = useTextEditingController(
        text: recurringBill != null ? "${recurringBill!.amount}" : "");

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
              controller: amountTextController,
            ),
            ElevatedButton(
              onPressed: () {
                if (recurringBill != null) {
                  //Edit
                  final editedRecurringBill = recurringBill!.copy(
                    title: titleTextController.text,
                    amount: double.parse(amountTextController.text),
                    reminderDate: DateTime.now(),
                  );
                  context.read<RecurringBillBloc>().add(
                      EditRecurringBill(recurringBill: editedRecurringBill));
                } else {
                  //Add
                  final newRecurringBill = RecurringBill(
                    title: titleTextController.text,
                    amount: double.parse(amountTextController.text),
                    reminderDate: DateTime.now(),
                    createdAt: DateTime.now(),
                    updatedAt: DateTime.now(),
                  );
                  context
                      .read<RecurringBillBloc>()
                      .add(AddRecurringBill(recurringBill: newRecurringBill));
                }
                context.read<RecurringBillBloc>().add(LoadRecurringBills());

                //Pop page
                added.value = true;
              },
              child: Text(
                recurringBill != null ? "Edit" : "Add",
              ),
            ),
          ],
        ),
      ),
    );
  }
}

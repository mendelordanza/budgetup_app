import 'package:budgetup_app/domain/recurring_bill.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../helper/date_helper.dart';
import 'bloc/recurring_bill_bloc.dart';

class AddRecurringBillPage extends HookWidget {
  final RecurringBill? recurringBill;
  final _formKey = GlobalKey<FormState>();

  AddRecurringBillPage({this.recurringBill, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final titleTextController = useTextEditingController(
        text: recurringBill != null ? recurringBill!.title : "");
    final amountTextController = useTextEditingController(
        text: recurringBill != null ? "${recurringBill!.amount}" : "");

    final dateTextController = useTextEditingController();
    final currentSelectedDate = useState<DateTime>(
        recurringBill != null && recurringBill!.reminderDate != null
            ? recurringBill!.reminderDate!
            : DateTime.now());

    final added = useState<bool>(false);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (added.value) {
          Navigator.pop(context);
        }
      });
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
                    controller: titleTextController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
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
                  Text("Remind me to pay every..."),
                  TextFormField(
                    controller: dateTextController,
                    onTap: () async {
                      await showDatePicker(
                        context: context,
                        initialDate: currentSelectedDate.value,
                        firstDate: DateTime(2015, 8),
                        lastDate: DateTime(2101),
                      ).then((date) {
                        currentSelectedDate.value = date!;
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
                  if (recurringBill != null) {
                    //Edit
                    final editedRecurringBill = recurringBill!.copy(
                      title: titleTextController.text,
                      amount: double.parse(amountTextController.text),
                      reminderDate: currentSelectedDate.value,
                    );
                    context.read<RecurringBillBloc>().add(
                        EditRecurringBill(recurringBill: editedRecurringBill));
                  } else {
                    //Add
                    final newRecurringBill = RecurringBill(
                      title: titleTextController.text,
                      amount: double.parse(amountTextController.text),
                      reminderDate: currentSelectedDate.value,
                      createdAt: DateTime.now(),
                      updatedAt: DateTime.now(),
                    );
                    context
                        .read<RecurringBillBloc>()
                        .add(AddRecurringBill(recurringBill: newRecurringBill));
                  }
                  context
                      .read<RecurringBillBloc>()
                      .add(LoadRecurringBills(currentSelectedDate.value));

                  //Pop page
                  added.value = true;
                }
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

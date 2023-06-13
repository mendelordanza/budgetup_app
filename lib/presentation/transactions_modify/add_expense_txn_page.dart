import 'package:budgetup_app/domain/expense_category.dart';
import 'package:budgetup_app/domain/expense_txn.dart';
import 'package:budgetup_app/helper/date_helper.dart';
import 'package:budgetup_app/presentation/custom/custom_button.dart';
import 'package:budgetup_app/presentation/custom/custom_text_field.dart';
import 'package:budgetup_app/presentation/transactions_modify/bloc/transactions_modify_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iconsax/iconsax.dart';

import '../../helper/string.dart';

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
        text: args.expenseTxn != null
            ? decimalFormatter(args.expenseTxn!.amount ?? 0.00)
            : "");

    final dateTextController = useTextEditingController();
    final currentSelectedDate = useState<DateTime>(
        args.expenseTxn != null && args.expenseTxn!.updatedAt != null
            ? args.expenseTxn!.updatedAt!
            : DateTime.now());

    useEffect(() {
      dateTextController.text =
          formatDate(currentSelectedDate.value, "MMM dd, yyyy");
    }, [currentSelectedDate.value]);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          args.expenseTxn != null ? "Edit Transaction" : "Add Transaction",
        ),
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SvgPicture.asset(
              "assets/icons/ic_arrow_left.svg",
            ),
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      CustomTextField(
                        controller: amountTextController,
                        textInputType:
                            TextInputType.numberWithOptions(decimal: true),
                        label: "Amount",
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          NumberInputFormatter(),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Amount is required';
                          }
                          return null;
                        },
                      ),
                      CustomTextField(
                        controller: notesTextController,
                        label: "Notes (optional)",
                        maxLines: 3,
                      ),
                      CustomTextField(
                        controller: dateTextController,
                        textInputType: TextInputType.datetime,
                        label: "Date",
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
                      ),
                    ],
                  ),
                ),
              ),
              CustomButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    if (args.expenseTxn != null) {
                      //Edit
                      final editedTxn = args.expenseTxn!.copy(
                        amount: double.parse(
                            removeFormatting(amountTextController.text)),
                        notes: notesTextController.text,
                        updatedAt:
                            removeTimeFromDate(currentSelectedDate.value),
                      );
                      context.read<TransactionsModifyBloc>().add(EditExpenseTxn(
                          expenseCategory: args.expenseCategory,
                          expenseTxn: editedTxn));
                    } else {
                      //Add
                      final newTxn = ExpenseTxn(
                        amount: double.parse(
                            removeFormatting(amountTextController.text)),
                        notes: notesTextController.text,
                        createdAt:
                            removeTimeFromDate(currentSelectedDate.value),
                        updatedAt:
                            removeTimeFromDate(currentSelectedDate.value),
                      );
                      context.read<TransactionsModifyBloc>().add(
                            AddExpenseTxn(
                              expenseTxn: newTxn,
                              expenseCategory: args.expenseCategory,
                            ),
                          );
                    }
                  }
                },
                child: Text(
                  args.expenseTxn != null ? "Edit" : "Add",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

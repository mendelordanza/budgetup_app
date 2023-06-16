import 'package:budgetup_app/domain/expense_category.dart';
import 'package:budgetup_app/domain/expense_txn.dart';
import 'package:budgetup_app/helper/date_helper.dart';
import 'package:budgetup_app/helper/shared_prefs.dart';
import 'package:budgetup_app/injection_container.dart';
import 'package:budgetup_app/presentation/custom/custom_button.dart';
import 'package:budgetup_app/presentation/custom/custom_text_field.dart';
import 'package:budgetup_app/presentation/transactions_modify/bloc/transactions_modify_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iconsax/iconsax.dart';

import '../../helper/route_strings.dart';
import '../../helper/string.dart';

class ExpenseTxnArgs {
  final ExpenseCategory expenseCategory;
  final ExpenseTxn? expenseTxn;
  final From from;

  ExpenseTxnArgs({
    required this.expenseCategory,
    this.expenseTxn,
    required this.from,
  });
}

enum From {
  expensePage,
  txnPage,
}

class AddExpenseTxnPage extends HookWidget {
  final ExpenseTxnArgs args;
  final _formKey = GlobalKey<FormState>();

  AddExpenseTxnPage({required this.args, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sharedPrefs = getIt<SharedPrefs>();

    final notesTextController = useTextEditingController(
        text: args.expenseTxn != null ? args.expenseTxn!.notes : "");
    final amountTextController = useTextEditingController(
        text: args.expenseTxn != null
            ? decimalFormatter(args.expenseTxn!.amount ?? 0.00)
            : "${sharedPrefs.getCurrencySymbol()} 0.00");

    final dateTextController = useTextEditingController();
    final currentSelectedDate = useState<DateTime>(
        args.expenseTxn != null && args.expenseTxn!.updatedAt != null
            ? args.expenseTxn!.updatedAt!
            : DateTime.now());

    useEffect(() {
      dateTextController.text =
          formatDate(currentSelectedDate.value, "MMM dd, yyyy");
      return null;
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
        actions: args.from == From.expensePage
            ? [
                IconButton(
                  onPressed: () {
                    Navigator.pushNamed(context, RouteStrings.transactions,
                        arguments: args.expenseCategory);
                  },
                  icon: Icon(Iconsax.layer),
                )
              ]
            : null,
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
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Column(
                            children: [
                              Text(
                                "${args.expenseCategory.icon} ${args.expenseCategory.title}",
                                style: TextStyle(
                                  fontSize: 16.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              TextFormField(
                                controller: amountTextController,
                                decoration: InputDecoration(
                                  fillColor: Colors.transparent,
                                  filled: true,
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.zero,
                                ),
                                style: TextStyle(
                                  fontSize: 24.0,
                                  fontWeight: FontWeight.w600,
                                ),
                                autofocus: true,
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                  NumberInputFormatter(),
                                ],
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Amount is required';
                                  } else if (value == "0.00") {
                                    return 'Please enter a valid number';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
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
                        CustomTextField(
                          controller: notesTextController,
                          label: "Notes (optional)",
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              CustomButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    if (args.expenseTxn != null) {
                      //Edit
                      final editedTxn = args.expenseTxn!.copy(
                        amount: convertAmount(sharedPrefs,
                            amount: amountTextController.text),
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
                        amount: convertAmount(sharedPrefs,
                            amount: amountTextController.text),
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

                    Navigator.pushReplacementNamed(
                        context, RouteStrings.transactions,
                        arguments: args.expenseCategory);
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

  convertAmount(SharedPrefs sharedPrefs, {required String amount}) {
    return sharedPrefs.getCurrencyCode() == "USD"
        ? double.parse(removeFormatting(amount))
        : double.parse(removeFormatting(amount)) /
            sharedPrefs.getCurrencyRate();
  }
}

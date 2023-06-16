import 'package:budgetup_app/domain/recurring_bill.dart';
import 'package:budgetup_app/helper/shared_prefs.dart';
import 'package:budgetup_app/helper/string.dart';
import 'package:budgetup_app/injection_container.dart';
import 'package:budgetup_app/presentation/custom/custom_button.dart';
import 'package:budgetup_app/presentation/custom/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';

import '../../helper/date_helper.dart';
import 'bloc/recurring_modify_bloc.dart';

class AddRecurringBillPage extends HookWidget {
  final RecurringBill? recurringBill;
  final _formKey = GlobalKey<FormState>();

  AddRecurringBillPage({this.recurringBill, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sharedPrefs = getIt<SharedPrefs>();

    final titleTextController = useTextEditingController(
        text: recurringBill != null ? recurringBill!.title : "");
    final amountTextController = useTextEditingController(
        text: recurringBill != null
            ? decimalFormatter(recurringBill!.amount ?? 0.00)
            : "0.00");

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
      return null;
    }, [added.value]);

    useEffect(() {
      dateTextController.text = formatDate(currentSelectedDate.value, "MMM dd");
      return null;
    }, [currentSelectedDate.value]);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          recurringBill != null ? "Edit Recurring Bill" : "Add Recurring Bill",
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
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Column(
                            children: [
                              Text("${sharedPrefs.getCurrencyCode()}"),
                              TextField(
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
                              ),
                            ],
                          ),
                        ),
                        CustomTextField(
                          label: "Title",
                          controller: titleTextController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Title is required';
                            }
                            return null;
                          },
                        ),
                        // CustomTextField(
                        //   label: "Amount",
                        //   inputFormatters: [
                        //     FilteringTextInputFormatter.digitsOnly,
                        //     NumberInputFormatter(),
                        //   ],
                        //   controller: amountTextController,
                        //   validator: (value) {
                        //     if (value == null || value.isEmpty) {
                        //       return 'Amount is required';
                        //     }
                        //     return null;
                        //   },
                        // ),
                        // CustomTextField(
                        //   label: "Interval",
                        //   controller: amountTextController,
                        //   validator: (value) {
                        //     if (value == null || value.isEmpty) {
                        //       return 'Amount is required';
                        //     }
                        //     return null;
                        //   },
                        // ),
                        CustomTextField(
                          label: "Remind me to pay every...",
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
                ),
              ),
              CustomButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    if (recurringBill != null) {
                      //Edit
                      final editedRecurringBill = recurringBill!.copy(
                        title: titleTextController.text,
                        amount: convertRecurringBill(sharedPrefs,
                            amount: amountTextController.text),
                        reminderDate: currentSelectedDate.value,
                      );
                      context.read<RecurringModifyBloc>().add(EditRecurringBill(
                          selectedDate: currentSelectedDate.value,
                          recurringBill: editedRecurringBill));
                    } else {
                      //Add
                      final newRecurringBill = RecurringBill(
                        title: titleTextController.text,
                        amount: convertRecurringBill(sharedPrefs,
                            amount: amountTextController.text),
                        reminderDate: currentSelectedDate.value,
                        createdAt: DateTime.now(),
                        updatedAt: DateTime.now(),
                      );
                      context.read<RecurringModifyBloc>().add(AddRecurringBill(
                          selectedDate: currentSelectedDate.value,
                          recurringBill: newRecurringBill));
                    }

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
      ),
    );
  }

  convertRecurringBill(SharedPrefs sharedPrefs, {required String amount}) {
    return sharedPrefs.getCurrencyCode() == "USD"
        ? double.parse(removeFormatting(amount))
        : double.parse(removeFormatting(amount)) /
            sharedPrefs.getCurrencyRate();
  }
}

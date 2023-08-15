import 'package:budgetup_app/domain/salary.dart';
import 'package:budgetup_app/helper/date_helper.dart';
import 'package:budgetup_app/presentation/salary/bloc/salary_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:keyboard_actions/keyboard_actions.dart';

import '../../helper/keyboard_helper.dart';
import '../../helper/shared_prefs.dart';
import '../../helper/string.dart';
import '../../injection_container.dart';
import '../custom/custom_button.dart';
import '../custom/custom_text_field.dart';

class InputSalary extends HookWidget {
  final Salary? currSalary;

  InputSalary({this.currSalary, super.key});

  @override
  Widget build(BuildContext context) {
    final sharedPrefs = getIt<SharedPrefs>();
    final currentSelectedDate = DateTime.parse(sharedPrefs.getSelectedDate());
    final salaryTextController = useTextEditingController(
        text: currSalary != null
            ? decimalFormatterWithSymbol(number: currSalary!.amount ?? 0.00)
            : "0.00");
    final _numberNode = useFocusNode();

    useEffect(() {
      context
          .read<SalaryBloc>()
          .add(LoadSalary(selectedDate: currentSelectedDate));
      return null;
    }, []);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 80.0,
              child: KeyboardActions(
                tapOutsideBehavior: TapOutsideBehavior.translucentDismiss,
                config: buildConfig(_numberNode, context),
                child: CustomTextField(
                  focusNode: _numberNode,
                  controller: salaryTextController,
                  label:
                      "${formatDate(currentSelectedDate, "MMM yyyy")} Received Salary",
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    NumberInputFormatter(),
                  ],
                  // onChanged: (value) {
                  //   final salary = Salary(
                  //     amount: double.parse(removeFormatting(value)),
                  //     month: currentSelectedDate.month,
                  //     year: currentSelectedDate.year,
                  //     createdAt: DateTime.now(),
                  //     updatedAt: DateTime.now(),
                  //   );
                  //   context.read<SalaryBloc>().add(AddSalary(
                  //       salary: salary, selectedDate: currentSelectedDate));
                  // },
                  autofocus: true,
                  textInputType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    } else if (removeFormatting(value) == "0.00") {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
              ),
            ),
            BlocBuilder<SalaryBloc, SalaryState>(
              builder: (context, state) {
                if (state is SalaryLoaded) {
                  return breakdown(
                    totalExpense: state.totalExpense,
                    totalPaidBills: state.totalPaidBills,
                    remainingSalary: state.remainingSalary,
                  );
                }
                return breakdown(
                  totalExpense: 0.00,
                  totalPaidBills: 0.00,
                  remainingSalary: 0.00,
                );
              },
            ),
            CustomButton(
              onPressed: () {
                final salary = Salary(
                  id: currSalary?.id,
                  amount: convertAmount(sharedPrefs,
                      amount: salaryTextController.text),
                  month: currentSelectedDate.month,
                  year: currentSelectedDate.year,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                );
                context.read<SalaryBloc>().add(AddSalary(
                    salary: salary, selectedDate: currentSelectedDate));
                Navigator.pop(context, true);
              },
              child: Text(
                currSalary != null ? "Update" : "Save",
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget breakdown({
    required double totalExpense,
    required double totalPaidBills,
    required double remainingSalary,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: Text("Total Expenses")),
              Text(
                "– ${decimalFormatterWithSymbol(number: totalExpense)}",
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 16.0,
          ),
          Row(
            children: [
              Expanded(child: Text("Total Paid Bills")),
              Text(
                "– ${decimalFormatterWithSymbol(number: totalPaidBills)}",
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 16.0,
          ),
          Divider(),
          SizedBox(
            height: 16.0,
          ),
          Row(
            children: [
              Expanded(child: Text("Remaining Salary")),
              Text(
                "${decimalFormatterWithSymbol(number: remainingSalary)}",
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
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

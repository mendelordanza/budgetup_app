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
import '../expenses/bloc/single_category_cubit.dart';

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

    final focusNode = useFocusNode();
    final notesTextController = useTextEditingController(
        text: args.expenseTxn != null ? args.expenseTxn!.notes : "");
    final amountTextController = useTextEditingController(
        text: args.expenseTxn != null
            ? decimalFormatterWithSymbol(args.expenseTxn!.amount ?? 0.00)
            : "${sharedPrefs.getCurrencySymbol()} 0.00");
    final dateTextController = useTextEditingController();
    final currentTransactionDate = useState<DateTime>(
        args.expenseTxn != null && args.expenseTxn!.updatedAt != null
            ? args.expenseTxn!.updatedAt!
            : DateTime.now());

    // final currentSelectedDate =
    //     DateTime.parse(sharedPrefs.getExpenseSelectedDate());
    // final currentDateFilterType = sharedPrefs.getSelectedDateFilterType();
    // final currentProgress = useState(args.expenseCategory.getTotalPercentage(
    //     dateFilterTypeFromString(currentDateFilterType), currentSelectedDate));
    // final newProgress = useState(0.0);
    // final isExceeded = useState(false);
    // final isMoreThanEighty = useState(false);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<SingleCategoryCubit>().getCategory(args.expenseCategory);
      });

      // amountTextController.addListener(() {
      //   final amountValue =
      //       double.parse(removeFormatting(amountTextController.text));
      //   newProgress.value = amountValue / (args.expenseCategory.budget ?? 0.00);
      //   isExceeded.value = newProgress.value + currentProgress.value > 1.0;
      //   isMoreThanEighty.value =
      //       newProgress.value + currentProgress.value >= 0.8;
      //
      //   print("VL:${newProgress.value}");
      // });
      return null;
    }, []);

    useEffect(() {
      dateTextController.text =
          formatDate(currentTransactionDate.value, "MMM dd, yyyy");
      return null;
    }, [currentTransactionDate.value]);

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
                  icon: Icon(Iconsax.document_text),
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
                              BlocBuilder<SingleCategoryCubit,
                                      SingleCategoryState>(
                                  builder: (context, state) {
                                if (state is SingleCategoryLoaded) {
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.pushNamed(
                                        context,
                                        RouteStrings.addCategory,
                                        arguments: state.expenseCategory,
                                      );
                                    },
                                    behavior: HitTestBehavior.translucent,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          "${state.expenseCategory.icon} ${state.expenseCategory.title}",
                                        ),
                                        SizedBox(
                                          width: 5.0,
                                        ),
                                        Icon(
                                          Iconsax.edit,
                                          size: 12,
                                        )
                                      ],
                                    ),
                                  );
                                }
                                return Text("No category");
                              }),
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
                                  } else if (removeFormatting(value) == "0.0") {
                                    return 'Please enter a valid number';
                                  }
                                  return null;
                                },
                              ),
                              // Padding(
                              //   padding:
                              //       const EdgeInsets.symmetric(vertical: 16.0),
                              //   child: _budgetProgress(
                              //     value:
                              //         newProgress.value + currentProgress.value,
                              //     isExceeded: isExceeded.value,
                              //     isHalf: isMoreThanEighty.value,
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                        CustomTextField(
                          focusNode: focusNode,
                          controller: dateTextController,
                          textInputType: TextInputType.datetime,
                          label: "Transaction Date",
                          prefixIcon: Icon(
                            Iconsax.calendar,
                            size: 16,
                          ),
                          onTap: () async {
                            focusNode.unfocus();
                            await showDatePicker(
                              context: context,
                              initialDate: currentTransactionDate.value,
                              firstDate: DateTime(2015, 8),
                              lastDate: DateTime(2101),
                            ).then((date) {
                              if (date != null) {
                                currentTransactionDate.value = date;
                              }
                            });
                          },
                        ),
                        CustomTextField(
                          controller: notesTextController,
                          label: "Notes (optional)",
                          maxLines: null,
                          prefixIcon: Icon(
                            Iconsax.receipt_edit,
                            size: 16,
                          ),
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
                            removeTimeFromDate(currentTransactionDate.value),
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
                            removeTimeFromDate(currentTransactionDate.value),
                        updatedAt:
                            removeTimeFromDate(currentTransactionDate.value),
                      );
                      context.read<TransactionsModifyBloc>().add(
                            AddExpenseTxn(
                              expenseTxn: newTxn,
                              expenseCategory: args.expenseCategory,
                            ),
                          );
                      Navigator.pushNamed(
                        context,
                        RouteStrings.transactions,
                        arguments: args.expenseCategory,
                      );
                    }

                    //Clear textfields
                    amountTextController.text =
                        "${sharedPrefs.getCurrencySymbol()} 0.00";
                    notesTextController.clear();
                  }
                },
                child: Text(
                  "Save",
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

// Widget _budgetProgress({
//   required double value,
//   required bool isExceeded,
//   required bool isHalf,
// }) {
//   return Row(
//     children: [
//       Expanded(
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(8),
//           child: SizedBox(
//             height: 12,
//             child: LinearProgressIndicator(
//               value: value,
//               color: isExceeded
//                   ? red
//                   : isHalf
//                       ? secondaryColor
//                       : green,
//             ),
//           ),
//         ),
//       ),
//       if (isExceeded)
//         Padding(
//           padding: const EdgeInsets.only(left: 5.0),
//           child: SvgPicture.asset(
//             "assets/icons/ic_warning.svg",
//             color: red,
//             height: 16.0,
//           ),
//         ),
//     ],
//   );
// }
}

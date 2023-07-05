import 'package:budgetup_app/domain/expense_category.dart';
import 'package:budgetup_app/domain/expense_txn.dart';
import 'package:budgetup_app/helper/date_helper.dart';
import 'package:budgetup_app/helper/keyboard_helper.dart';
import 'package:budgetup_app/helper/shared_prefs.dart';
import 'package:budgetup_app/injection_container.dart';
import 'package:budgetup_app/presentation/custom/custom_button.dart';
import 'package:budgetup_app/presentation/custom/custom_text_field.dart';
import 'package:budgetup_app/presentation/transactions_modify/bloc/transactions_modify_bloc.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iconsax/iconsax.dart';
import 'package:keyboard_actions/keyboard_actions.dart';

import '../../helper/colors.dart';
import '../../helper/route_strings.dart';
import '../../helper/string.dart';
import '../expenses/bloc/expense_bloc.dart';
import '../expenses/bloc/single_category_cubit.dart';

class ExpenseTxnArgs {
  final ExpenseCategory? expenseCategory;
  final ExpenseTxn? expenseTxn;

  ExpenseTxnArgs({
    required this.expenseCategory,
    this.expenseTxn,
  });
}

class AddExpenseTxnPage extends HookWidget {
  final ExpenseTxnArgs args;

  AddExpenseTxnPage({required this.args, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (args.expenseCategory != null) {
          context
              .read<SingleCategoryCubit>()
              .getCategory(args.expenseCategory!);
        }
      });
      return null;
    }, []);

    return AddTransaction(args: args);
  }
}

class AddTransaction extends HookWidget {
  final ExpenseTxnArgs args;
  final _formKey = GlobalKey<FormState>();

  AddTransaction({required this.args, super.key});

  @override
  Widget build(BuildContext context) {
    final sharedPrefs = getIt<SharedPrefs>();
    final dateFocusNode = useFocusNode();
    final amountFocusNode = useFocusNode();
    final notesFocusNode = useFocusNode();
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
    final selectedCategory = useState<ExpenseCategory?>(null);

    useEffect(() {
      dateTextController.text =
          formatDate(currentTransactionDate.value, "MMM dd, yyyy");
      return null;
    }, [currentTransactionDate.value]);

    // useEffect(() {
    //   pageController?.addListener(() {
    //     if (pageController?.page == 1) {
    //       amountFocusNode.unfocus();
    //       notesFocusNode.unfocus();
    //     }
    //   });
    //   return null;
    // }, []);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          args.expenseTxn != null ? "Edit Transaction" : "Add Transaction",
        ),
        centerTitle: true,
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: Column(
                                children: [
                                  if (args.expenseCategory != null)
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
                                                style: TextStyle(
                                                  fontSize: 16.0,
                                                ),
                                              ),
                                              SizedBox(
                                                width: 5.0,
                                              ),
                                              Icon(
                                                Iconsax.edit,
                                                size: 14,
                                              )
                                            ],
                                          ),
                                        );
                                      }
                                      return Text("No category");
                                    }),
                                  SizedBox(
                                    height: 5.0,
                                  ),
                                  SizedBox(
                                    height: 70.0,
                                    child: KeyboardActions(
                                      config:
                                          buildConfig(amountFocusNode, context),
                                      child: TextFormField(
                                        focusNode: amountFocusNode,
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
                                        textAlign: TextAlign.center,
                                        textInputAction: TextInputAction.next,
                                        keyboardType: TextInputType.number,
                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                          NumberInputFormatter(),
                                        ],
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Amount is required';
                                          } else if (removeFormatting(value) ==
                                              "0.0") {
                                            return 'Please enter a valid number';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
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
                              focusNode: dateFocusNode,
                              readOnly: true,
                              controller: dateTextController,
                              textInputType: TextInputType.datetime,
                              label: "Transaction Date",
                              prefixIcon: Icon(
                                Iconsax.calendar,
                                size: 16,
                              ),
                              onTap: () async {
                                dateFocusNode.unfocus();
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
                              focusNode: notesFocusNode,
                              controller: notesTextController,
                              textInputAction: TextInputAction.done,
                              label: "Notes (optional)",
                              maxLines: null,
                              prefixIcon: Icon(
                                Iconsax.receipt_edit,
                                size: 16,
                              ),
                            ),
                            if (args.expenseCategory == null)
                              BlocBuilder<ExpenseBloc, ExpenseState>(
                                builder: (context, state) {
                                  if (state is ExpenseCategoryLoaded &&
                                      state.expenseCategories.isNotEmpty) {
                                    return categoryDropdown(context,
                                        items: state.expenseCategories,
                                        onChanged: (categoryId) {
                                      selectedCategory.value = state
                                          .expenseCategories
                                          .singleWhere((element) =>
                                              element.id == categoryId);
                                    });
                                  }
                                  return categoryDropdown(context, items: [],
                                      onChanged: (category) {
                                    selectedCategory.value = null;
                                  });
                                },
                              ),
                          ],
                        ),
                      ),
                      // if (args.expenseTxn == null)
                      //   Row(
                      //     mainAxisAlignment: MainAxisAlignment.center,
                      //     children: [
                      //       SvgPicture.asset(
                      //         "assets/icons/ic_double_arrow_up.svg",
                      //         color: Theme.of(context).colorScheme.onSurface,
                      //       ),
                      //       SizedBox(
                      //         width: 5.0,
                      //       ),
                      //       Text(
                      //         "Swipe up to view transactions",
                      //         textAlign: TextAlign.center,
                      //       ),
                      //     ],
                      //   ),
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
                        amount: convertAmount(sharedPrefs,
                            amount: amountTextController.text),
                        notes: notesTextController.text,
                        updatedAt:
                            removeTimeFromDate(currentTransactionDate.value),
                      );
                      if (args.expenseCategory != null) {
                        context.read<TransactionsModifyBloc>().add(
                            EditExpenseTxn(
                                expenseCategory: args.expenseCategory!,
                                expenseTxn: editedTxn));
                      } else if (selectedCategory.value != null) {
                        context.read<TransactionsModifyBloc>().add(
                            EditExpenseTxn(
                                expenseCategory: selectedCategory.value!,
                                expenseTxn: editedTxn));
                      }
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
                      if (args.expenseCategory != null) {
                        context.read<TransactionsModifyBloc>().add(
                              AddExpenseTxn(
                                expenseTxn: newTxn,
                                expenseCategory: args.expenseCategory!,
                              ),
                            );
                      } else if (selectedCategory.value != null) {
                        context.read<TransactionsModifyBloc>().add(
                              AddExpenseTxn(
                                expenseTxn: newTxn,
                                expenseCategory: selectedCategory.value!,
                              ),
                            );
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Transaction added")));

                      if (args.expenseCategory != null) {
                        Navigator.pop(context);
                      } else {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          RouteStrings.transactions,
                          (route) => route.isFirst,
                          arguments: selectedCategory.value,
                        );
                      }
                    }

                    //Clear textfields
                    amountTextController.text =
                        "${sharedPrefs.getCurrencySymbol()} 0.00";
                    amountTextController.selection = TextSelection.collapsed(
                        offset: amountTextController.text.length);
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

  Widget categoryDropdown(BuildContext context,
      {ExpenseCategory? selectedCategory,
      required List<ExpenseCategory> items,
      required Function(int) onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            "Category",
          ),
        ),
        DropdownButtonFormField2(
          decoration: InputDecoration(
            hintText: "Select Category",
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(8.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: secondaryColor, width: 2.0),
              borderRadius: BorderRadius.circular(8.0),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFC62F3A), width: 2.0),
              borderRadius: BorderRadius.circular(8.0),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFC62F3A), width: 2.0),
              borderRadius: BorderRadius.circular(8.0),
            ),
            filled: true,
            fillColor: Theme.of(context).cardColor,
            contentPadding: EdgeInsets.all(16.0),
            prefixIcon: Icon(
              Iconsax.category,
              size: 15.0,
            ),
          ),
          isExpanded: true,
          // hint: Text(
          //   selectedCategory != null
          //       ? selectedCategory.title!
          //       : 'Select category',
          // ),
          items: items
              .map(
                (item) => DropdownMenuItem<int>(
                  value: item.id,
                  child: Text(
                    item.title ?? "",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
              .toList(),
          validator: (value) {
            if (value == null) {
              return 'Please select category.';
            }
            return null;
          },
          onChanged: (value) {
            if (value != null) {
              onChanged(value);
            }
          },
          iconStyleData: IconStyleData(
            icon: SvgPicture.asset(
              "assets/icons/ic_arrow_down.svg",
            ),
          ),
          dropdownStyleData: DropdownStyleData(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        ),
      ],
    );
  }
}

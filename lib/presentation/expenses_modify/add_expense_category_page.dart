import 'package:budgetup_app/helper/date_helper.dart';
import 'package:budgetup_app/helper/shared_prefs.dart';
import 'package:budgetup_app/presentation/custom/custom_button.dart';
import 'package:budgetup_app/presentation/custom/custom_emoji_picker.dart';
import 'package:budgetup_app/presentation/custom/custom_text_field.dart';
import 'package:budgetup_app/presentation/expenses_modify/bloc/expenses_modify_bloc.dart';
import 'package:emoji_data/emoji_data.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iconsax/iconsax.dart';
import 'package:keyboard_actions/keyboard_actions.dart';

import '../../domain/expense_category.dart';
import '../../helper/keyboard_helper.dart';
import '../../helper/string.dart';
import '../../injection_container.dart';
import '../custom/delete_dialog.dart';

class AddExpenseCategoryPage extends HookWidget {
  final ExpenseCategory? expenseCategory;
  final _formKey = GlobalKey<FormState>();
  final FocusNode _numberNode = FocusNode();

  AddExpenseCategoryPage({this.expenseCategory, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sharedPrefs = getIt<SharedPrefs>();

    final titleTextController = useTextEditingController(
        text: expenseCategory != null ? expenseCategory!.title : "");
    final budgetTextController = useTextEditingController(
        text: expenseCategory != null
            ? decimalFormatterWithSymbol(number: expenseCategory!.budget ?? 0.00)
            : "${sharedPrefs.getCurrencySymbol()} 0.00");
    final selectedEmoji = useState(
        expenseCategory != null && expenseCategory!.icon != null
            ? expenseCategory!.icon!
            : Emoji.travelPlaces[0]);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          expenseCategory != null ? "Edit Category" : "Add Category",
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
        actions: [
          if (expenseCategory != null)
            IconButton(
              icon: Icon(Iconsax.trash),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return DeleteDialog(
                      title: "Delete Category",
                      description:
                          "This will also delete transactions under this category. Are you sure you want to delete this category?",
                      onPositive: () {
                        context.read<ModifyExpensesBloc>().add(
                            RemoveExpenseCategory(
                                expenseCategory: expenseCategory!));
                      },
                      onNegative: () {
                        Navigator.pop(context);
                      },
                    );
                  },
                );
              },
            )
        ],
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
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text("Select Emoji Icon"),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: GestureDetector(
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                backgroundColor: Colors.transparent,
                                builder: (context) {
                                  return CustomEmojiPicker();
                                },
                                isScrollControlled: true,
                              ).then((value) {
                                if (value != null) {
                                  selectedEmoji.value = value;
                                }
                              });
                            },
                            child: Material(
                              shape: SmoothRectangleBorder(
                                borderRadius: SmoothBorderRadius(
                                  cornerRadius: 16,
                                  cornerSmoothing: 1.0,
                                ),
                              ),
                              child: Padding(
                                child: Text(
                                  selectedEmoji.value,
                                  style: TextStyle(
                                    fontSize: 30.0,
                                  ),
                                ),
                                padding: EdgeInsets.symmetric(
                                  vertical: 10.0,
                                  horizontal: 16.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                        CustomTextField(
                          controller: titleTextController,
                          label: "Title",
                          hintText: "eg. Transporation",
                          maxLines: 1,
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter some text';
                            }
                            return null;
                          },
                        ),
                        SizedBox(
                          height: 100.0,
                          child: KeyboardActions(
                            tapOutsideBehavior: TapOutsideBehavior.translucentDismiss,
                            config: buildConfig(_numberNode, context),
                            child: CustomTextField(
                              focusNode: _numberNode,
                              controller: budgetTextController,
                              label: "Monthly Budget",
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                NumberInputFormatter(),
                              ],
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
                      ],
                    ),
                  ),
                ),
              ),
              CustomButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    if (expenseCategory != null) {
                      //Edit
                      final editedCategory = expenseCategory!.copy(
                        title: titleTextController.text,
                        icon: selectedEmoji.value,
                        budget: convertBudget(sharedPrefs,
                            budget: budgetTextController.text),
                        updatedAt: removeTimeFromDate(DateTime.now()),
                      );
                      context.read<ModifyExpensesBloc>().add(
                          EditExpenseCategory(expenseCategory: editedCategory));
                    } else {
                      //Add
                      final newCategory = ExpenseCategory(
                        title: titleTextController.text,
                        icon: selectedEmoji.value,
                        budget: convertBudget(sharedPrefs,
                            budget: budgetTextController.text),
                        createdAt: removeTimeFromDate(DateTime.now()),
                        updatedAt: removeTimeFromDate(DateTime.now()),
                      );
                      context.read<ModifyExpensesBloc>().add(
                          AddExpenseCategory(expenseCategory: newCategory));
                    }
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

  convertBudget(SharedPrefs sharedPrefs, {required String budget}) {
    return sharedPrefs.getCurrencyCode() == "USD"
        ? double.parse(removeFormatting(budget))
        : double.parse(removeFormatting(budget)) /
            sharedPrefs.getCurrencyRate();
  }
}

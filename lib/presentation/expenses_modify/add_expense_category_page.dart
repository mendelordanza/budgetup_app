import 'package:budgetup_app/helper/date_helper.dart';
import 'package:budgetup_app/presentation/custom/custom_button.dart';
import 'package:budgetup_app/presentation/custom/custom_emoji_picker.dart';
import 'package:budgetup_app/presentation/custom/custom_text_field.dart';
import 'package:budgetup_app/presentation/expenses_modify/bloc/expenses_modify_bloc.dart';
import 'package:emoji_data/emoji_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';

import '../../domain/expense_category.dart';
import '../../helper/string.dart';

class AddExpenseCategoryPage extends HookWidget {
  final ExpenseCategory? expenseCategory;
  final _formKey = GlobalKey<FormState>();

  AddExpenseCategoryPage({this.expenseCategory, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final titleTextController = useTextEditingController(
        text: expenseCategory != null ? expenseCategory!.title : "");
    final budgetTextController = useTextEditingController(
        text: expenseCategory != null ? "${expenseCategory!.budget}" : "");
    final selectedEmoji = useState(Emoji.objects[49]);

    final added = useState<bool>(false);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (added.value) {
          Navigator.pop(context);
        }
      });
    }, [added.value]);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          expenseCategory != null ? "Edit Category" : "Add Category",
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
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text("Select Emoji Icon"),
                      ),
                      GestureDetector(
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
                          shape: ContinuousRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                      ),
                      CustomTextField(
                        controller: titleTextController,
                        label: "Title",
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter some text';
                          }
                          return null;
                        },
                      ),
                      CustomTextField(
                        controller: budgetTextController,
                        label: "Monthly Budget",
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          NumberInputFormatter(),
                        ],
                        textInputType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
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
              CustomButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    if (expenseCategory != null) {
                      //Edit
                      final editedCategory = expenseCategory!.copy(
                        title: titleTextController.text,
                        icon: selectedEmoji.value,
                        budget: double.parse(
                            removeFormatting(budgetTextController.text)),
                        updatedAt: removeTimeFromDate(DateTime.now()),
                      );
                      context.read<ModifyExpensesBloc>().add(
                          EditExpenseCategory(expenseCategory: editedCategory));
                    } else {
                      //Add
                      final newCategory = ExpenseCategory(
                        title: titleTextController.text,
                        icon: selectedEmoji.value,
                        budget: double.parse(
                            removeFormatting(budgetTextController.text)),
                        createdAt: removeTimeFromDate(DateTime.now()),
                        updatedAt: removeTimeFromDate(DateTime.now()),
                      );
                      context.read<ModifyExpensesBloc>().add(
                          AddExpenseCategory(expenseCategory: newCategory));
                    }

                    //Pop page
                    added.value = true;
                  }
                },
                child: Text(
                  expenseCategory != null ? "Edit" : "Add",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

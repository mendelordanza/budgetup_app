import 'package:budgetup_app/domain/recurring_bill.dart';
import 'package:budgetup_app/helper/shared_prefs.dart';
import 'package:budgetup_app/helper/string.dart';
import 'package:budgetup_app/injection_container.dart';
import 'package:budgetup_app/presentation/custom/custom_button.dart';
import 'package:budgetup_app/presentation/custom/custom_text_field.dart';
import 'package:budgetup_app/presentation/recurring/recurring_bills_page.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iconsax/iconsax.dart';
import 'package:keyboard_actions/keyboard_actions.dart';

import '../../helper/colors.dart';
import '../../helper/date_helper.dart';
import '../../helper/keyboard_helper.dart';
import '../custom/delete_dialog.dart';
import 'bloc/recurring_modify_bloc.dart';

enum RecurringBillInterval {
  weekly,
  monthly,
  //quarterly,
  yearly,
}

class AddRecurringBillPage extends HookWidget {
  final AddRecurringBillArgs args;
  final _formKey = GlobalKey<FormState>();

  AddRecurringBillPage({required this.args, Key? key}) : super(key: key);

  final intervals = [
    RecurringBillInterval.weekly,
    RecurringBillInterval.monthly,
    //RecurringBillInterval.quarterly,
    RecurringBillInterval.yearly,
  ];

  @override
  Widget build(BuildContext context) {
    final sharedPrefs = getIt<SharedPrefs>();

    final titleTextController = useTextEditingController(
        text: args.recurringBill != null ? args.recurringBill!.title : "");
    final amountTextController = useTextEditingController(
        text: args.recurringBill != null
            ? decimalFormatterWithSymbol(args.recurringBill!.amount ?? 0.00)
            : "0.00");
    final amountFocusNode = FocusNode();
    final dateFocusNode = FocusNode();
    final timeFocusNode = FocusNode();

    final dateTextController = useTextEditingController();
    final currentSelectedDate = useState<DateTime>(
        args.recurringBill != null && args.recurringBill!.reminderDate != null
            ? args.recurringBill!.reminderDate!
            : DateTime.now());

    final timeTextController = useTextEditingController();
    final currentSelectedTime = useState<TimeOfDay>(
        args.recurringBill != null && args.recurringBill!.reminderDate != null
            ? TimeOfDay.fromDateTime(args.recurringBill!.reminderDate!)
            : TimeOfDay.now());

    final selectedInterval = useState<RecurringBillInterval>(
      args.recurringBill != null && args.recurringBill!.interval != null
          ? RecurringBillInterval.values.firstWhere(
              (element) => element.name == args.recurringBill!.interval)
          : RecurringBillInterval.monthly,
    );

    useEffect(() {
      dateTextController.text = formatDate(currentSelectedDate.value, "MMMM d");
      return null;
    }, [currentSelectedDate.value]);

    useEffect(() {
      timeTextController.text =
          "${currentSelectedTime.value.hour.toString().padLeft(2, "0")}:${currentSelectedTime.value.minute.toString().padLeft(2, "0")}";
      return null;
    }, [currentSelectedTime.value]);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          args.recurringBill != null
              ? "Edit Recurring Bill"
              : "Add Recurring Bill",
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
          if (args.recurringBill != null)
            IconButton(
              icon: Icon(Iconsax.trash),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return DeleteDialog(
                      title: "Delete Recurring Bill",
                      description:
                          "Are you sure you want to delete this recurring bill?",
                      onPositive: () {
                        context.read<RecurringModifyBloc>().add(
                            RemoveRecurringBill(
                                selectedDate: currentSelectedDate.value,
                                recurringBill: args.recurringBill!));
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
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Column(
                              children: [
                                Text("${sharedPrefs.getCurrencyCode()}"),
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
                                        FilteringTextInputFormatter.digitsOnly,
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
                              ],
                            ),
                          ),
                          CustomTextField(
                            label: "Title",
                            controller: titleTextController,
                            textInputAction: TextInputAction.done,
                            hintText: "eg. Internet",
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Title is required';
                              }
                              return null;
                            },
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: CustomTextField(
                                  focusNode: dateFocusNode,
                                  readOnly: true,
                                  label: "Remind me starting on...",
                                  controller: dateTextController,
                                  prefixIcon: Icon(
                                    Iconsax.notification,
                                    size: 18,
                                  ),
                                  onTap: () async {
                                    dateFocusNode.unfocus();
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
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: CustomTextField(
                                  focusNode: timeFocusNode,
                                  readOnly: true,
                                  label: "at...",
                                  controller: timeTextController,
                                  prefixIcon: Icon(
                                    Iconsax.clock,
                                    size: 18,
                                  ),
                                  onTap: () async {
                                    timeFocusNode.unfocus();
                                    await showTimePicker(
                                            context: context,
                                            initialTime:
                                                currentSelectedTime.value)
                                        .then((time) {
                                      if (time != null) {
                                        currentSelectedTime.value = time;
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
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(bottom: 8.0),
                                child: Text("Every..."),
                              ),
                              DropdownButtonFormField2(
                                decoration: InputDecoration(
                                  hintText: "Select inteval",
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: secondaryColor, width: 2.0),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Color(0xFFC62F3A), width: 2.0),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Color(0xFFC62F3A), width: 2.0),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  filled: true,
                                  fillColor: Theme.of(context).cardColor,
                                  contentPadding: EdgeInsets.all(16.0),
                                  prefixIcon: Icon(
                                    Iconsax.refresh,
                                    size: 15.0,
                                  ),
                                ),
                                isExpanded: true,
                                value: selectedInterval.value,
                                items: intervals
                                    .map(
                                      (item) => DropdownMenuItem<
                                          RecurringBillInterval>(
                                        value: item,
                                        child: Text(
                                          "${item.name[0].toUpperCase()}${item.name.substring(1)}",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                                validator: (value) {
                                  if (value == null) {
                                    return 'Please select interval.';
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  if (value != null) {
                                    selectedInterval.value = value;
                                  }
                                },
                                iconStyleData: IconStyleData(
                                  icon: SvgPicture.asset(
                                    "assets/icons/ic_arrow_down.svg",
                                    color: secondaryColor,
                                  ),
                                ),
                                dropdownStyleData: DropdownStyleData(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                              ),

                              // Row(
                              //   mainAxisAlignment:
                              //       MainAxisAlignment.spaceEvenly,
                              //   children: intervals.map((element) {
                              //     return _tab(
                              //       context,
                              //       label:
                              //           "${element.name[0].toUpperCase()}${element.name.substring(1)}",
                              //       isSelected:
                              //           selectedInterval.value == element,
                              //       onSelect: () {
                              //         selectedInterval.value = element;
                              //       },
                              //     );
                              //   }).toList(),
                              // ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              CustomButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    if (args.recurringBill != null) {
                      //Edit
                      final editedRecurringBill = args.recurringBill!.copy(
                        title: titleTextController.text,
                        amount: convertRecurringBill(sharedPrefs,
                            amount: amountTextController.text),
                        interval: selectedInterval.value.name,
                        reminderDate: currentSelectedDate.value.copyWith(
                            hour: currentSelectedTime.value.hour,
                            minute: currentSelectedTime.value.minute),
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
                        interval: selectedInterval.value.name,
                        reminderDate: currentSelectedDate.value.copyWith(
                            hour: currentSelectedTime.value.hour,
                            minute: currentSelectedTime.value.minute),
                        createdAt: DateTime.now(),
                        updatedAt: DateTime.now(),
                      );
                      context.read<RecurringModifyBloc>().add(AddRecurringBill(
                          selectedDate: currentSelectedDate.value,
                          recurringBill: newRecurringBill));
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

  convertRecurringBill(SharedPrefs sharedPrefs, {required String amount}) {
    return sharedPrefs.getCurrencyCode() == "USD"
        ? double.parse(removeFormatting(amount))
        : double.parse(removeFormatting(amount)) /
            sharedPrefs.getCurrencyRate();
  }

  Widget _tab(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required Function() onSelect,
  }) {
    return GestureDetector(
      onTap: onSelect,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: 5.0,
          horizontal: 16.0,
        ),
        decoration: BoxDecoration(
          color: isSelected ? secondaryColor : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(30.0),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

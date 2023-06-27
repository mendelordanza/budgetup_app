
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
import 'package:iconsax/iconsax.dart';

import '../../data/notification_service.dart';
import '../../helper/colors.dart';
import '../../helper/date_helper.dart';
import 'bloc/recurring_modify_bloc.dart';

enum RecurringBillInterval {
  monthly,
  //quarterly,
  yearly,
}

class AddRecurringBillPage extends HookWidget {
  final RecurringBill? recurringBill;
  final _formKey = GlobalKey<FormState>();

  AddRecurringBillPage({this.recurringBill, Key? key}) : super(key: key);

  final intervals = [
    RecurringBillInterval.monthly,
    //RecurringBillInterval.quarterly,
    RecurringBillInterval.yearly,
  ];

  @override
  Widget build(BuildContext context) {
    final sharedPrefs = getIt<SharedPrefs>();

    final titleTextController = useTextEditingController(
        text: recurringBill != null ? recurringBill!.title : "");
    final amountTextController = useTextEditingController(
        text: recurringBill != null
            ? decimalFormatterWithSymbol(recurringBill!.amount ?? 0.00)
            : "0.00");
    final focusNode = FocusNode();

    final dateTextController = useTextEditingController();
    final currentSelectedDate = useState<DateTime>(
        recurringBill != null && recurringBill!.reminderDate != null
            ? recurringBill!.reminderDate!
            : DateTime.now());

    final timeTextController = useTextEditingController();
    final currentSelectedTime = useState<TimeOfDay>(
        recurringBill != null && recurringBill!.reminderDate != null
            ? TimeOfDay.fromDateTime(recurringBill!.reminderDate!)
            : TimeOfDay.now());

    final selectedInterval = useState<RecurringBillInterval>(
      recurringBill != null && recurringBill!.interval != null
          ? RecurringBillInterval.values
              .firstWhere((element) => element.name == recurringBill!.interval)
          : RecurringBillInterval.monthly,
    );

    useEffect(() {
      dateTextController.text = formatDate(currentSelectedDate.value, "MMMM d");
      return null;
    }, [currentSelectedDate.value]);

    useEffect(() {
      timeTextController.text =
          "${currentSelectedTime.value.hour}:${currentSelectedTime.value.minute}";
      return null;
    }, [currentSelectedTime.value]);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          recurringBill != null ? "Edit Recurring Bill" : "Add Recurring Bill",
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
          if (recurringBill != null)
            IconButton(
              icon: Icon(Iconsax.trash),
              onPressed: () {
                context.read<RecurringModifyBloc>().add(RemoveRecurringBill(
                    selectedDate: currentSelectedDate.value,
                    recurringBill: recurringBill!));
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
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: Column(
                            children: [
                              Text("${sharedPrefs.getCurrencyCode()}"),
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
                            ],
                          ),
                        ),
                        CustomTextField(
                          label: "Title",
                          controller: titleTextController,
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
                                focusNode: focusNode,
                                label: "Remind me starting on...",
                                controller: dateTextController,
                                prefixIcon: Icon(
                                  Iconsax.notification,
                                  size: 18,
                                ),
                                onTap: () async {
                                  focusNode.unfocus();
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
                                focusNode: focusNode,
                                label: "at...",
                                controller: timeTextController,
                                prefixIcon: Icon(
                                  Iconsax.clock,
                                  size: 18,
                                ),
                                onTap: () async {
                                  focusNode.unfocus();
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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: intervals.map((element) {
                                return _tab(
                                  context,
                                  label:
                                      "${element.name[0].toUpperCase()}${element.name.substring(1)}",
                                  isSelected: selectedInterval.value == element,
                                  onSelect: () {
                                    selectedInterval.value = element;
                                  },
                                );
                              }).toList(),
                            ),
                          ],
                        )
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

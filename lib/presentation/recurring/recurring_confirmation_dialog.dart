import 'package:budgetup_app/presentation/custom/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:iconsax/iconsax.dart';

import '../../helper/date_helper.dart';
import '../../helper/shared_prefs.dart';
import '../../injection_container.dart';
import '../custom/custom_text_field.dart';

class RecurringConfirmationDialog extends HookWidget {
  const RecurringConfirmationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final sharedPrefs = getIt<SharedPrefs>();
    final selectedDate = useState<DateTime>(
      sharedPrefs.getSelectedDate().isNotEmpty
          ? DateTime.parse(sharedPrefs.getSelectedDate())
          : DateTime.now(),
    );

    final focusNode = useFocusNode();
    final dateTextController = useTextEditingController();
    final currentTransactionDate = useState<DateTime>(DateTime(
        selectedDate.value.year, selectedDate.value.month, DateTime.now().day));

    useEffect(() {
      dateTextController.text =
          formatDate(currentTransactionDate.value, "MMM dd, yyyy");
      return null;
    }, [currentTransactionDate.value]);

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      title: Text("Confirm"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomTextField(
            focusNode: focusNode,
            readOnly: true,
            controller: dateTextController,
            textInputType: TextInputType.datetime,
            label: "Date Paid",
            prefixIcon: Icon(
              Iconsax.calendar,
              size: 16,
            ),
            onTap: () async {
              focusNode.unfocus();
              await showDatePicker(
                context: context,
                initialDate: currentTransactionDate.value,
                firstDate: DateTime(
                    selectedDate.value.year, selectedDate.value.month, 1),
                lastDate: DateTime(
                    selectedDate.value.year, selectedDate.value.month + 1, 0),
              ).then((date) {
                if (date != null) {
                  currentTransactionDate.value = date;
                }
              });
            },
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            8.0,
            0.0,
            8.0,
            8.0,
          ),
          child: Container(
            width: double.infinity,
            child: CustomButton(
              onPressed: () {
                Navigator.pop(context, currentTransactionDate.value);
              },
              child: Text(
                "Mark as paid",
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

import 'package:budgetup_app/helper/shared_prefs.dart';
import 'package:budgetup_app/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

String decimalFormatter(double number) {
  final sharedPrefs = getIt<SharedPrefs>();
  double roundedNumber = double.parse(number.toStringAsFixed(2));
  final formatter = NumberFormat("#,##0.00");
  return "${sharedPrefs.getCurrencySymbol()} ${formatter.format(roundedNumber)}";
}

removeFormatting(String formattedValue) {
  final sharedPrefs = getIt<SharedPrefs>();
  final numberFormat = NumberFormat('#,##0.###');
  return numberFormat
      .parse(
          formattedValue.replaceAll('${sharedPrefs.getCurrencySymbol()}', ''))
      .toString();
}

class NumberInputFormatter extends TextInputFormatter {
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    final number = int.tryParse(newValue.text);

    if (number == null) {
      return oldValue;
    }

    final formatter = NumberFormat('#,##0.00');
    final newText = formatter.format(number / 100);

    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}

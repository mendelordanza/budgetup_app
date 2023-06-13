import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

String decimalFormatter(double number) {
  double roundedNumber = double.parse(number.toStringAsFixed(2));
  NumberFormat formatter = NumberFormat("#,##0.00");
  return formatter.format(roundedNumber);
}

removeFormatting(String formattedValue) {
  final numberFormat = NumberFormat('#,##0.###');
  final parsedValue = numberFormat.parse(formattedValue);
  return parsedValue.toString();
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

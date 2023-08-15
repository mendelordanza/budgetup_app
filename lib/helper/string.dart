import 'package:budgetup_app/helper/shared_prefs.dart';
import 'package:budgetup_app/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

String decimalFormatterWithSymbol(
    {required double number, String? currencySymbol}) {
  final sharedPrefs = getIt<SharedPrefs>();
  double roundedNumber = double.parse(number.toStringAsFixed(2));
  final formatter = NumberFormat("#,##0.00");
  var symbol = sharedPrefs.getCurrencySymbol();

  if (currencySymbol != null) {
    symbol = currencySymbol;
  } else {
    symbol = sharedPrefs.getCurrencySymbol();
  }

  if (number.isNegative) {
    return "–$symbol${formatter.format(roundedNumber.abs())}";
  }
  return "$symbol${formatter.format(roundedNumber)}";
}

String decimalFormatter(double number) {
  double roundedNumber = double.parse(number.toStringAsFixed(2));
  final formatter = NumberFormat("#,##0.00");
  return "${formatter.format(roundedNumber)}";
}

removeFormatting(String formattedValue) {
  String unformattedAmount = formattedValue.replaceAll(RegExp(r'[^0-9.]'), '');
  double amount = double.parse(unformattedAmount);
  String result = amount.toStringAsFixed(2);
  return result;
}

class NumberInputFormatter extends TextInputFormatter {
  final sharedPrefs = getIt<SharedPrefs>();
  final String? currentCurrencySymbol;

  NumberInputFormatter({this.currentCurrencySymbol});

  @override
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
    var newText = "";

    if (currentCurrencySymbol != null) {
      newText = "$currentCurrencySymbol${formatter.format(number / 100)}";
    } else {
      newText =
          "${sharedPrefs.getCurrencySymbol()}${formatter.format(number / 100)}";
    }

    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}

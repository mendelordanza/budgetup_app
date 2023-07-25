import 'package:budgetup_app/helper/string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class Balance extends HookWidget {
  final Widget headerLabel;
  final double total;
  final double? budget;
  final TextAlign? totalAlign;

  Balance(
      {required this.headerLabel,
      required this.total,
      this.budget,
      this.totalAlign = TextAlign.start,
      super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        headerLabel,
        SizedBox(
          height: 5.0,
        ),
        Text(
          decimalFormatterWithSymbol(total),
          textAlign: totalAlign,
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
          style: TextStyle(
            fontSize: 28.0,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

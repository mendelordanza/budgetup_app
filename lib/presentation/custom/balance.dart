import 'package:budgetup_app/helper/string.dart';
import 'package:flutter/material.dart';

import '../../helper/colors.dart';

class Balance extends StatelessWidget {
  final Widget headerLabel;
  final double total;

  Balance({required this.headerLabel, required this.total, super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      shape: ContinuousRectangleBorder(
        borderRadius: BorderRadius.circular(40.0),
      ),
      color: Theme.of(context).cardColor,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            headerLabel,
            Text(
              "PHP ${decimalFormatter(total)}",
              style: TextStyle(
                fontSize: 36.0,
                fontWeight: FontWeight.w700,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 4.0,
              ),
              decoration: BoxDecoration(
                color: red.withOpacity(0.5),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: Text(
                "Total Monthly Budget: PHP 10,000.00",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onInverseSurface,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

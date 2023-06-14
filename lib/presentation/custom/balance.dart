import 'package:budgetup_app/helper/string.dart';
import 'package:flutter/material.dart';

import '../../helper/colors.dart';

class Balance extends StatelessWidget {
  final Widget headerLabel;
  final double total;
  final double? budget;

  Balance(
      {required this.headerLabel, required this.total, this.budget, super.key});

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
            SizedBox(
              height: 5.0,
            ),
            Text(
              "PHP ${decimalFormatter(total)}",
              style: TextStyle(
                fontSize: 36.0,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (budget != null)
              Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 4.0,
                  ),
                  decoration: BoxDecoration(
                    color: total > budget!
                        ? red.withOpacity(0.7)
                        : green.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(
                    "Total Monthly Budget: PHP ${decimalFormatter(budget!)}",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }
}

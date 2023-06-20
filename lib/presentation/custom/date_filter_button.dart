import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../helper/colors.dart';

class DateFilterButton extends StatelessWidget {
  final String text;

  DateFilterButton({required this.text, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5.0),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 10.0,
          vertical: 8.0,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
                color: secondaryColor,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: SvgPicture.asset(
                "assets/icons/ic_arrow_down.svg",
                color: secondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../helper/colors.dart';

class DateFilterButton extends StatelessWidget {
  final String text;

  DateFilterButton({required this.text, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: SvgPicture.asset(
              "assets/icons/ic_calendar.svg",
              color: Theme.of(context).primaryColor,
            ),
          ),
          Text(
            text,
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

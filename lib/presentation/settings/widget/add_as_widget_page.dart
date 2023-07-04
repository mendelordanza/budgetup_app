import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Item {
  final String icon;
  final String description;

  Item(this.icon, this.description);
}

class AddAsWidgetPage extends StatelessWidget {
  final list = [
    Item("assets/Widget1.svg",
        "Hold down on any app to edit Home Screen"),
    Item("assets/Widget2.svg",
        "Tap the add button on the upper left corner"),
    Item("assets/Widget3.svg", "Search or look for BudgetUp"),
    Item("assets/Widget4.svg", "Add BudgetUp as a widget"),
  ];

  final androidList = [
    Item("assets/AndroidWidget1.svg", "Hold down on the Home Screen"),
    Item("assets/AndroidWidget2.svg",
        "Tap the widget button on the lower part"),
    Item("assets/AndroidWidget3.svg", "Search or look for BudgetUp"),
    Item("assets/AndroidWidget4.svg", "Add Once as a widget"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "How to add a widget",
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
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            24.0,
            0.0,
            24.0,
            24.0,
          ),
          child: PageView.builder(
            itemBuilder: (context, index) {
              final item =
                  Platform.isAndroid ? androidList[index] : list[index];
              return PageItem(item);
            },
            itemCount: Platform.isAndroid ? androidList.length : list.length,
          ),
        ),
      ),
    );
  }
}

class PageItem extends StatelessWidget {
  final Item item;

  PageItem(this.item);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
            child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SvgPicture.asset(item.icon),
        )),
        Text(
          item.description,
          style: TextStyle(
            fontSize: 24.0,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

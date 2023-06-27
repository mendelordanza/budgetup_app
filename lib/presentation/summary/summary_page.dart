import 'package:budgetup_app/helper/date_helper.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';

import '../../helper/route_strings.dart';

class SummaryPage extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final _currentYear = useState(DateTime.now().year);

    return Scaffold(
      appBar: AppBar(
        title: Text("Summary Reports"),
        actions: [
          InkWell(
            onTap: () {
              Navigator.pop(context);
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SvgPicture.asset(
                "assets/icons/ic_arrow_right.svg",
                height: 20.0,
              ),
            ),
          ),
        ],
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        _currentYear.value = _currentYear.value - 1;
                      },
                      icon: SvgPicture.asset(
                        "assets/icons/ic_arrow_left.svg",
                      ),
                    ),
                    Text("${_currentYear.value}"),
                    IconButton(
                      onPressed: () {
                        if (_currentYear.value != DateTime.now().year) {
                          _currentYear.value = _currentYear.value + 1;
                        }
                      },
                      icon: SvgPicture.asset(
                        "assets/icons/ic_arrow_right.svg",
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: getPrevMonths(_currentYear.value).length,
                  itemBuilder: (context, index) {
                    final date = getPrevMonths(_currentYear.value)[index];
                    return _summaryItem(
                      context,
                      date: date,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryItem(
    BuildContext context, {
    required DateTime date,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: GestureDetector(
        onTap: () {
          Navigator.pushNamed(
            context,
            RouteStrings.summaryDetail,
            arguments: date,
          );
        },
        child: Material(
          shape: SmoothRectangleBorder(
            borderRadius: SmoothBorderRadius(
              cornerRadius: 16,
              cornerSmoothing: 1.0,
            ),
          ),
          color: Theme.of(context).cardColor,
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Text(
              formatDate(
                date,
                "MMMM yyyy",
              ),
            ),
          ),
        ),
      ),
    );
  }
}

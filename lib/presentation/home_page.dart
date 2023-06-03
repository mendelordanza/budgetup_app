import 'package:budgetup_app/presentation/expenses/expenses_page.dart';
import 'package:budgetup_app/presentation/recurring/recurring_bills_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:iconsax/iconsax.dart';

import '../helper/colors.dart';
import 'date_filter/date_bottom_sheet.dart';

class HomePage extends HookWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tabController = useTabController(initialLength: 2);
    final _currentIndex = useState<int>(0);

    useEffect(() {
      tabController.addListener(() {
        _currentIndex.value = tabController.index;
      });
    }, []);

    return Scaffold(
      appBar: AppBar(
        title: Text("BudgetUp"),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Iconsax.setting),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextButton(
                onPressed: () {
                  showModalBottomSheet(
                    backgroundColor: Colors.transparent,
                    context: context,
                    builder: (context) {
                      return DateBottomSheet();
                    },
                  );
                },
                child: Text(
                  "This Month",
                ),
              ),
              Material(
                shape: ContinuousRectangleBorder(
                  borderRadius: BorderRadius.circular(40.0),
                ),
                color: Theme.of(context).cardColor,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Total Expenses"),
                      Text("PHP 1,000.00"),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 4.0,
                        ),
                        decoration: BoxDecoration(
                          color: red.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: Text("PHP 30.00 higher than last month"),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 32.0,
              ),
              Container(
                height: 45,
                decoration: BoxDecoration(
                  color: Color(0xFFB7B7B7),
                  borderRadius: BorderRadius.circular(30.0),
                ),
                child: TabBar(
                  controller: tabController,
                  tabs: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Iconsax.money_send,
                          size: 18,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          " Expenses",
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Iconsax.money_send,
                          size: 18,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          "Recurring",
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                  unselectedLabelColor: Colors.white,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(30.0),
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              SizedBox(
                height: 32.0,
              ),
              Expanded(
                child: TabBarView(
                  controller: tabController,
                  children: [
                    ExpensesPage(),
                    RecurringBillsPage(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

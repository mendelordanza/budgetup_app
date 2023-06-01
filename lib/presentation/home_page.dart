import 'package:budgetup_app/presentation/expenses/expenses_page.dart';
import 'package:budgetup_app/presentation/recurring/recurring_bills_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../helper/colors.dart';

class HomePage extends HookWidget {
  HomePage({Key? key}) : super(key: key);

  final tabs = ["Expenses", "Recurring Bills"];

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
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text("This Month"),
              SizedBox(
                height: 8,
              ),
              Material(
                shape: ContinuousRectangleBorder(
                  borderRadius: BorderRadius.circular(28.0),
                ),
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
              // Tabs(
              //   tabController: tabController,
              //   tabs: [
              //     "Expenses",
              //     "Recurring Bills"
              //   ],
              // ),
              TabBar(
                controller: tabController,
                tabs: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Text("Expenses"),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Text("Recurring Bills"),
                  ),
                ],
                unselectedLabelColor:
                    Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(30.0),
                  color: Theme.of(context).primaryColor,
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

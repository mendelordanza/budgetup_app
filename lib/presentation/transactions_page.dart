import 'package:budgetup_app/presentation/expenses/expenses_page.dart';
import 'package:budgetup_app/presentation/recurring/recurring_bills_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:iconsax/iconsax.dart';

class TransactionsPage extends HookWidget {
  TransactionsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tabController = useTabController(initialLength: 2);
    final _currentIndex = useState<int>(0);

    useEffect(() {
      tabController.addListener(() {
        _currentIndex.value = tabController.index;
      });
      return null;
    }, []);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                16.0,
                16.0,
                16.0,
                0.0,
              ),
              child: Container(
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
    );
  }
}

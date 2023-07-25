import 'package:budgetup_app/presentation/expenses/expenses_page.dart';
import 'package:budgetup_app/presentation/recurring/bloc/recurring_bill_bloc.dart';
import 'package:budgetup_app/presentation/recurring/recurring_bills_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:home_widget/home_widget.dart';
import 'package:iconsax/iconsax.dart';

import '../helper/shared_prefs.dart';
import '../injection_container.dart';
import 'expenses/bloc/expense_bloc.dart';

class TransactionsPage extends HookWidget {
  TransactionsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tabController = useTabController(initialLength: 2);
    final tabPadding = useState(EdgeInsets.zero);
    final _currentIndex = useState<int>(0);

    final sharedPrefs = getIt<SharedPrefs>();
    final expensesCurrentSelectedDate =
        DateTime.parse(sharedPrefs.getExpenseSelectedDate());

    useEffect(() {
      context.read<ExpenseBloc>().add(
          LoadExpenseCategories(selectedDate: expensesCurrentSelectedDate));
      context
          .read<RecurringBillBloc>()
          .add(LoadRecurringBills());

      HomeWidget.setAppGroupId('group.G53UVF44L3.com.ralphordanza.budgetupapp');

      tabController.addListener(() {
        if (tabController.indexIsChanging) {
          tabPadding.value = EdgeInsets.only(right: 8.0);
        }
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
                height: 45.0,
                decoration: BoxDecoration(
                  color: Color(0xFFB7B7B7),
                  borderRadius: BorderRadius.circular(30.0),
                ),
                child: TabBar(
                  controller: tabController,
                  tabs: [
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Iconsax.money_send,
                            color: Colors.white,
                            size: 18,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            " Expenses",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Tab(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            "assets/icons/ic_recurring.svg",
                            color: Colors.white,
                            height: 18.0,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text(
                            "Recurring Bills",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  unselectedLabelColor: Colors.white,
                  indicatorSize: TabBarIndicatorSize.tab,
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

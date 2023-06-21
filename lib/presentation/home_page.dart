import 'package:budgetup_app/helper/route_strings.dart';
import 'package:budgetup_app/presentation/settings/currency/bloc/convert_currency_cubit.dart';
import 'package:budgetup_app/presentation/transactions_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomePage extends HookWidget {
  HomePage({super.key});

  final _pages = [
    // ExpensesPage(),
    // RecurringBillsPage(),
    TransactionsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final _selectedIndex = useState<int>(0);

    useEffect(() {
      context.read<ConvertCurrencyCubit>().loadCurrencies();
      return null;
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "BudgetUp",
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {
            Navigator.pushNamed(context, RouteStrings.settings);
          },
          icon: SvgPicture.asset(
            "assets/icons/ic_setting.svg",
            height: 24.0,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, RouteStrings.summary);
            },
            icon: SvgPicture.asset(
              "assets/icons/ic_summary_thin.svg",
              height: 24.0,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex.value,
        children: _pages,
      ),
      // bottomNavigationBar: BottomNavigationBar(
      //   selectedItemColor: secondaryColor,
      //   items: [
      //     BottomNavigationBarItem(
      //       icon: Icon(
      //         Iconsax.money_send,
      //         color: _selectedIndex.value == 0
      //             ? secondaryColor
      //             : Theme.of(context).colorScheme.onSurface,
      //       ),
      //       label: 'Expenses',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: SvgPicture.asset(
      //         "assets/icons/ic_recurring.svg",
      //         color: _selectedIndex.value == 1
      //             ? secondaryColor
      //             : Theme.of(context).colorScheme.onSurface,
      //       ),
      //       label: 'Recurring Bills',
      //     ),
      //   ],
      //   currentIndex: _selectedIndex.value,
      //   onTap: (index) {
      //     _selectedIndex.value = index;
      //   },
      // ),
    );
  }
}

import 'package:budgetup_app/helper/colors.dart';
import 'package:budgetup_app/presentation/custom/custom_floating_button.dart';
import 'package:budgetup_app/presentation/dashboard_page.dart';
import 'package:budgetup_app/presentation/transactions_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:iconsax/iconsax.dart';

class HomePage extends HookWidget {
  HomePage({super.key});

  final _pages = [
    DashboardPage(),
    TransactionsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final _selectedIndex = useState<int>(0);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "BudgetUp",
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Iconsax.setting),
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex.value,
        children: _pages,
      ),
      floatingActionButton: CustomFloatingButton(
        onPressed: () {},
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: secondaryColor,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Iconsax.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Iconsax.dollar_circle),
            label: 'Transactions',
          ),
        ],
        currentIndex: _selectedIndex.value,
        onTap: (index) {
          _selectedIndex.value = index;
        },
      ),
    );
  }
}

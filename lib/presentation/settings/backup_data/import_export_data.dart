
import 'package:budgetup_app/data/local/isar_service.dart';
import 'package:budgetup_app/helper/shared_prefs.dart';
import 'package:budgetup_app/presentation/expenses/bloc/expense_bloc.dart';
import 'package:budgetup_app/presentation/recurring/bloc/recurring_bill_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iconsax/iconsax.dart';

import '../../../injection_container.dart';
import '../settings_page.dart';

class ImportExportData extends StatelessWidget {
  const ImportExportData({super.key});

  @override
  Widget build(BuildContext context) {
    final isarService = getIt<IsarService>();
    final sharedPrefs = getIt<SharedPrefs>();
    final selectedDate = DateTime.parse(sharedPrefs.getRecurringSelectedDate());

    return Scaffold(
      appBar: AppBar(
        title: Text("Import / Export Data"),
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
          padding: const EdgeInsets.all(16.0),
          child: SettingsContainer(
            settingItems: [
              SettingItem(
                onTap: () {
                  isarService.importFromJson().then((value) {
                    if (value) {
                      context.read<ExpenseBloc>().add(LoadExpenseCategories());
                      context
                          .read<RecurringBillBloc>()
                          .add(LoadRecurringBills(selectedDate));
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text("Data imported successfully")));
                    }
                  });
                },
                icon: Icon(Iconsax.import),
                iconBackgroundColor: Colors.transparent,
                label: "Import Data",
                subtitle:
                    "Import previously exported file to continue with your budgeting",
              ),
              Divider(),
              SettingItem(
                onTap: () {
                  isarService.exportToJson().then((value) {
                    if (value) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text(
                              "Data exported successfully in your files")));
                    }
                  });
                },
                icon: Icon(Iconsax.export),
                iconBackgroundColor: Colors.transparent,
                label: "Export Data",
                subtitle:
                    "Want to continue your budgeting on other device? Export your data into a file",
              ),
            ],
          ),
        ),
      ),
    );
  }
}

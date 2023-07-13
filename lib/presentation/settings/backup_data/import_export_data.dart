import 'package:budgetup_app/data/local/isar_service.dart';
import 'package:budgetup_app/helper/shared_prefs.dart';
import 'package:budgetup_app/presentation/expenses/bloc/expense_bloc.dart';
import 'package:budgetup_app/presentation/recurring/bloc/recurring_bill_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:iconsax/iconsax.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../../helper/constant.dart';
import '../../../injection_container.dart';
import '../../paywall/paywall.dart';
import '../settings_page.dart';

class ImportExportData extends HookWidget {
  const ImportExportData({super.key});

  showPaywall(BuildContext context) async {
    try {
      final offerings = await Purchases.getOfferings();
      if (context.mounted && offerings.current != null) {
        await showModalBottomSheet(
          isDismissible: true,
          isScrollControlled: true,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
          ),
          context: context,
          builder: (BuildContext context) {
            return StatefulBuilder(
                builder: (BuildContext context, StateSetter setModalState) {
              return PaywallView(
                offering: offerings.current!,
              );
            });
          },
        );
      }
    } on PlatformException catch (e) {
      print(e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isarService = getIt<IsarService>();
    final sharedPrefs = getIt<SharedPrefs>();
    final selectedDate = DateTime.parse(sharedPrefs.getRecurringSelectedDate());

    final isSubscribed = useState(false);
    useEffect(() {
      Purchases.addCustomerInfoUpdateListener((customerInfo) {
        final entitlement = customerInfo.entitlements.active[entitlementId];
        isSubscribed.value =
            entitlement != null && entitlement.isSandbox == false;
      });
      return null;
    }, []);

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
                onTap: () async {
                  final customerInfo = await Purchases.getCustomerInfo();
                  if (customerInfo.entitlements.active[entitlementId] != null &&
                      customerInfo
                              .entitlements.active[entitlementId]!.isSandbox ==
                          false) {
                    isSubscribed.value = true;
                    isarService.importFromJson().then((value) {
                      if (value) {
                        context
                            .read<ExpenseBloc>()
                            .add(LoadExpenseCategories());
                        context
                            .read<RecurringBillBloc>()
                            .add(LoadRecurringBills(selectedDate));
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text("Data imported successfully")));
                      }
                    });
                  } else if (context.mounted) {
                    showPaywall(context);
                  }
                },
                icon: Icon(Iconsax.import),
                iconBackgroundColor: Colors.transparent,
                label: "Import Data",
                subtitle:
                    "Import previously exported file to continue with your budgeting",
              ),
              Divider(),
              SettingItem(
                onTap: () async {
                  final customerInfo = await Purchases.getCustomerInfo();
                  if (customerInfo.entitlements.active[entitlementId] != null &&
                      customerInfo
                              .entitlements.active[entitlementId]!.isSandbox ==
                          false) {
                    isSubscribed.value = true;
                    isarService.exportToJson().then((value) {
                      if (value) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text(
                                "Data exported successfully in your files")));
                      }
                    });
                  } else if (context.mounted) {
                    showPaywall(context);
                  }
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
